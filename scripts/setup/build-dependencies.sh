#!/bin/bash

set -e

HERE=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

gpu=false
minimal=false
jobs=2
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

gpu_flag=()
[[ "$gpu" == "true" ]] && gpu_flag=(--gpu)
minimal_flag=()
[[ "$minimal" == "true" ]] && minimal_flag=(--minimal)
jobs_flag=(--jobs=$jobs)

$HERE/build-tools.sh "${gpu_flag[@]}"
$HERE/build-boost.sh "${jobs_flag[@]}"
$HERE/build-protobuf.sh "${jobs_flag[@]}"
$HERE/build-sentencepiece.sh "${jobs_flag[@]}"
$HERE/build-marian.sh "${gpu_flag[@]}" "${jobs_flag[@]}"
$HERE/build-kaldi.sh "${gpu_flag[@]}" "${jobs_flag[@]}"
$HERE/build-cleanup.sh "${minimal_flag[@]}"
