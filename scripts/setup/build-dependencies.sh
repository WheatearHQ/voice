#!/bin/bash

set -e

HERE=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

gpu=false
minimal=false
while [[ $# -gt 0 ]]; do
  case $1 in
    --gpu)
      gpu=true
      ;;
    --cpu)
      gpu=false
      ;;
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

gpu_flag=()
[[ "$gpu" == "true" ]] && gpu_flag=(--gpu)
minimal_flag=()
[[ "$minimal" == "true" ]] && minimal_flag=(--minimal)

$HERE/build-tools.sh "${gpu_flag[@]}"
$HERE/build-boost.sh
$HERE/build-protobuf.sh
$HERE/build-sentencepiece.sh
$HERE/build-marian.sh "${gpu_flag[@]}"
$HERE/build-kaldi.sh "${gpu_flag[@]}"
$HERE/build-cleanup.sh "${minimal_flag[@]}"
