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

git clone https://github.com/marian-nmt/marian-dev marian
cd marian
git checkout 737f43014a939a3ded2806b00cbaa661fbcc5f49
git apply $SERENADE_SOURCE_ROOT/patches/marian/fix-warnings.patch
git apply $SERENADE_SOURCE_ROOT/patches/marian/max-history.patch
mkdir build
cd build
if [[ "$gpu" == "true" ]] ; then
  CC=/usr/bin/gcc-8 CXX=/usr/bin/g++-8 cmake .. \
    -DBUILD_ARCH=x86-64 \
    -DCMAKE_OSX_ARCHITECTURES=x86_64 \
    -DCOMPILE_CUDA=on \
    -DUSE_DOXYGEN=off
elif [[ `uname` == "Darwin" ]] ; then
  cmake .. \
    -DBUILD_ARCH=x86-64 \
    -DCMAKE_OSX_ARCHITECTURES=x86_64 \
    -DCOMPILE_CUDA=off \
    -DUSE_DOXYGEN=off \
    -DUSE_APPLE_ACCELERATE=on \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=$osx_version
else
  cmake .. \
    -DBUILD_ARCH=x86-64 \
    -DCMAKE_OSX_ARCHITECTURES=x86_64 \
    -DCOMPILE_CUDA=off \
    -DUSE_DOXYGEN=off
fi
rm -f ../src/3rd_party/sentencepiece/version
cmake --build . --config Release -j2
cd ../..
