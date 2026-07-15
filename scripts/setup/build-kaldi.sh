#!/bin/bash

set -e

HERE=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
. $HERE/paths.sh
cd $SERENADE_LIBRARY_ROOT

osx_version="11.0"
gpu=false
jobs=2
while [[ $# -gt 0 ]]; do
  case $1 in
    --gpu)
      gpu=true
      ;;
    --cpu)
      gpu=false
      ;;
    --jobs=*)
      jobs="${1#--jobs=}"
      ;;
    *)
      echo "Unknown argument: $1"
      exit 1
      ;;
  esac
  shift
done

export MAKEFLAGS=-s

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
if [[ `uname` != 'Darwin' && `uname -m` != 'x86_64' ]] ; then
  mkdir -p /opt/openblas-shim/lib /opt/openblas-shim/include
  ln -sf /usr/lib/$(uname -m)-linux-gnu/libopenblas.so /opt/openblas-shim/lib/libopenblas.so
  ln -sf /usr/lib/$(uname -m)-linux-gnu/libopenblas.a /opt/openblas-shim/lib/libopenblas.a
  ln -sf /usr/include/$(uname -m)-linux-gnu/cblas.h /opt/openblas-shim/include/cblas.h
  ln -sf /usr/include/lapacke.h /opt/openblas-shim/include/lapacke.h
fi
make -j$jobs
cd ../src
if [[ `uname` == 'Darwin' ]] ; then
  ./configure --shared --use-cuda=no
  perl -i -pe"s/-O1/-O3 -DNDEBUG -mmacosx-version-min=$osx_version/g" kaldi.mk
elif [[ `uname -m` == 'x86_64' ]] ; then
  ./configure --shared --mathlib=MKL --mkl-root=/opt/intel/oneapi/mkl/latest --use-cuda=no
  perl -i -pe's/-O1/-O3 -DNDEBUG/g' kaldi.mk
else
  ./configure --shared --mathlib=OPENBLAS --openblas-root=/opt/openblas-shim --use-cuda=no
  perl -i -pe's/-O1/-O3 -DNDEBUG/g' kaldi.mk
fi
perl -i -pe's/-g //g' kaldi.mk
echo 'CXXFLAGS += -w' >> kaldi.mk
make -j clean depend
make -j$jobs
cd ../tools
./extras/install_phonetisaurus.sh
cd ../..
