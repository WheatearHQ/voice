#!/bin/bash

set -e

HERE=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
. $HERE/paths.sh
cd $SERENADE_LIBRARY_ROOT

export MAKEFLAGS=-s

osx_version="11.0"
jobs=2
while [[ $# -gt 0 ]]; do
  case $1 in
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

git clone --recursive --shallow-submodules --depth 1 -b v3.14.0 https://github.com/protocolbuffers/protobuf.git protobuf-src
mkdir -p protobuf
cd protobuf-src
./autogen.sh
./configure --prefix=$PWD/../protobuf --disable-shared --with-pic
if [[ `uname` == "Darwin" ]] ; then
  make CFLAGS="-mmacosx-version-min=$osx_version" CXXFLAGS="-g -std=c++11 -DNDEBUG -mmacosx-version-min=$osx_version" -j$jobs
else
  make -j$jobs
fi
make install
cd ..
rm -rf protobuf-src
