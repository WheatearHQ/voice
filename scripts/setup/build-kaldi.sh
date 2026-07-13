#!/bin/bash

set -e

HERE=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
. $HERE/paths.sh
cd $SERENADE_LIBRARY_ROOT

osx_version="11.0"
gpu=false
while [[ $# -gt 0 ]]; do
  case $1 in
    --gpu)
      gpu=true
      ;;
    --cpu)
      gpu=false
      ;;
    *)
      echo "Unknown argument: $1"
      exit 1
      ;;
  esac
  shift
done

mkdir kaldi
cd kaldi
git init -q
git remote add origin https://github.com/kaldi-asr/kaldi
git fetch --depth 1 origin 3ec108da76e3d9dba901fb69f046d0e46170b8e7
git checkout -q FETCH_HEAD
git apply $SERENADE_SOURCE_ROOT/patches/kaldi/stateless.patch
cd tools
if [[ `uname` == 'Darwin' ]] ; then
  perl -i -pe"s/-g -O2/-g -O2 -mmacosx-version-min=$osx_version/g" Makefile
fi
make -j2
cd ../src
if [[ `uname` == 'Darwin' ]] ; then
  ./configure --shared --use-cuda=no
  perl -i -pe"s/-O1/-O3 -DNDEBUG -mmacosx-version-min=$osx_version/g" kaldi.mk
else
  ./configure --shared --mathlib=MKL --mkl-root=/opt/intel/oneapi/mkl/latest --use-cuda=no
  perl -i -pe's/-O1/-O3 -DNDEBUG/g' kaldi.mk
fi
perl -i -pe's/-g //g' kaldi.mk
make -j clean depend
make -j2
cd ../tools
./extras/install_phonetisaurus.sh
cd ../..
