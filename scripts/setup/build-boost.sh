#!/bin/bash

set -e

HERE=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
. $HERE/paths.sh
cd $SERENADE_LIBRARY_ROOT

git clone --recursive --shallow-submodules --depth 1 --branch boost-1.78.0 https://github.com/boostorg/boost.git boost-src
cd boost-src
./bootstrap.sh --prefix=$PWD/../boost
./b2 install
cd ..
rm -rf boost-src
