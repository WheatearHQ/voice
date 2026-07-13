#!/bin/bash

set -e

HERE=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
. $HERE/paths.sh
cd $SERENADE_LIBRARY_ROOT

osx_version="11.0"

git clone --recursive -b v3.14.0 https://github.com/protocolbuffers/protobuf.git protobuf-src
mkdir -p protobuf
cd protobuf-src
./autogen.sh
./configure --prefix=$PWD/../protobuf --disable-shared --with-pic
if [[ `uname` == "Darwin" ]] ; then
  make CFLAGS="-mmacosx-version-min=$osx_version" CXXFLAGS="-g -std=c++11 -DNDEBUG -mmacosx-version-min=$osx_version" -j2
else
  make -j2
fi
make install
cd ..
rm -rf protobuf-src
