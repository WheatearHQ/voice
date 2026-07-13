#!/bin/bash

set -e

HERE=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
. $HERE/paths.sh
cd $SERENADE_LIBRARY_ROOT

git clone --recursive https://github.com/boostorg/boost.git boost-src
cd boost-src
git checkout boost-1.78.0
./bootstrap.sh --prefix=$PWD/../boost
./b2 install
cd ..
rm -rf boost-src
