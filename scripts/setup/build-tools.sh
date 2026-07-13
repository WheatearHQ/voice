#!/bin/bash

set -e

HERE=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
. $HERE/paths.sh
cd $SERENADE_LIBRARY_ROOT

pip3 install --upgrade \
  awscli \
  black \
  certbot \
  certbot_dns_route53 \
  certifi \
  click \
  fabric \
  jsonlines \
  numpy \
  pip \
  psutil \
  psycopg2-binary \
  pybars3 \
  pyenchant \
  pyyaml \
  requests \
  sentencepiece==0.1.95

sudo-non-docker npm install -g \
  prettier \
  prettier-plugin-java

rm -rf \
  antlr \
  boost \
  boost-src \
  crow \
  gradle-* \
  kaldi \
  marian \
  sentencepiece \
  sentencepiece-src

curl https://services.gradle.org/distributions/gradle-7.4.2-bin.zip -Lso gradle.zip
unzip -qq gradle.zip
rm gradle.zip

mkdir antlr
curl https://www.antlr.org/download/antlr-4.7.2-complete.jar -Lso antlr/antlr-4.7.2-complete.jar

git clone https://github.com/CrowCpp/crow crow
cd crow
git checkout v1.0+1
cd ..
