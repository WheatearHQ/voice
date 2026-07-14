#!/bin/bash

set -e

HERE=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
. $HERE/paths.sh
cd $SERENADE_LIBRARY_ROOT

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

git clone --recursive --shallow-submodules --depth 1 --branch boost-1.78.0 https://github.com/boostorg/boost.git boost-src
cd boost-src
./bootstrap.sh --prefix=$PWD/../boost
./b2 install -j$jobs -d0
cd ..
rm -rf boost-src
