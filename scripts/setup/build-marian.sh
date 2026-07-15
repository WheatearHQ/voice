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

mkdir marian
cd marian
git init -q
git remote add origin https://github.com/marian-nmt/marian-dev
git fetch --depth 1 origin 737f43014a939a3ded2806b00cbaa661fbcc5f49
git checkout -q FETCH_HEAD
git apply $SERENADE_SOURCE_ROOT/patches/marian/fix-warnings.patch
git apply $SERENADE_SOURCE_ROOT/patches/marian/max-history.patch
if [[ `uname` != 'Darwin' && `uname -m` != 'x86_64' ]] ; then
  # -m64 is an x86-only flag; this Marian commit predates its own ARM support.
  perl -i -pe 's/-m64 //g' CMakeLists.txt
  git apply $SERENADE_SOURCE_ROOT/patches/marian/arm-faiss-vector-transform.patch
  git apply $SERENADE_SOURCE_ROOT/patches/marian/arm-sse-types.patch
  git apply $SERENADE_SOURCE_ROOT/patches/marian/arm-sse-operators.patch
  git apply $SERENADE_SOURCE_ROOT/patches/marian/arm-sse-tensor.patch
  git apply $SERENADE_SOURCE_ROOT/patches/marian/arm-sse-element.patch
  git apply $SERENADE_SOURCE_ROOT/patches/marian/arm-sse-tensor-operators.patch
  git apply $SERENADE_SOURCE_ROOT/patches/marian/arm-sse-int-gemm.patch
  git apply $SERENADE_SOURCE_ROOT/patches/marian/arm-exclude-x86-gemm.patch
fi
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
elif [[ `uname -m` == "x86_64" ]] ; then
  cmake .. \
    -DBUILD_ARCH=x86-64 \
    -DCMAKE_OSX_ARCHITECTURES=x86_64 \
    -DCOMPILE_CUDA=off \
    -DUSE_DOXYGEN=off
else
  cmake .. \
    -DCOMPILE_CUDA=off \
    -DUSE_DOXYGEN=off
fi
rm -f ../src/3rd_party/sentencepiece/version
cmake --build . --config Release -j$jobs
cd ../..
