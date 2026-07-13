#!/bin/bash

set -e

HERE=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
. $HERE/paths.sh
cd $SERENADE_LIBRARY_ROOT

minimal=false
while [[ $# -gt 0 ]]; do
  case $1 in
    --minimal)
      minimal=true
      ;;
    *)
      echo "Unknown argument: $1"
      exit 1
      ;;
  esac
  shift
done

if [[ "$minimal" == "true" ]] ; then
  rm -rf \
    marian/.git \
    marian/build/src \
    marian/build/marian \
    marian/build/marian-* \
    marian/build/spm_* \
    kaldi/.git \
    kaldi/tools/openfst-1.7.2/bin \
    kaldi/tools/openfst-1.7.2/lib/libfstscript.a \
    kaldi/tools/openfst-1.7.2/lib/libfstfarscript.a \
    kaldi/tools/openfst-1.7.2/lib/libfstlookahead.a \
    kaldi/tools/openfst-1.7.2/src/script/.libs \
    kaldi/tools/openfst-1.7.2/src/extensions/lookahead/.libs \
    kaldi/tools/openfst-1.7.2/src/extensions/far/.libs \
    kaldi/tools/openfst-1.7.2/src/extensions/ngram/.libs \
    kaldi/tools/phonetisaurus-g2p/phonetisaurus-*

  find kaldi/src -type f ! -name "*.*" -delete
  find kaldi -type f -name "*.so*" -delete
  find kaldi -type f -name "*.o" -delete
fi
