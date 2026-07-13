#!/bin/bash

set -e

HERE=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
. $HERE/paths.sh
cd $SERENADE_LIBRARY_ROOT

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

git clone --depth 1 --branch v0.1.96 https://github.com/google/sentencepiece.git sentencepiece-src
cd sentencepiece-src
mkdir build
cd build
cmake .. \
  -DCMAKE_OSX_ARCHITECTURES=x86_64 \
  -DCMAKE_INSTALL_PREFIX=$PWD/../../sentencepiece \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=$osx_version
cmake --build . --config Release -j$jobs
cmake --install .
cd ../..
rm -rf sentencepiece-src
