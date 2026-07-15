#!/bin/bash

set -e

HERE=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
. $HERE/paths.sh
cd $SERENADE_LIBRARY_ROOT

gpu=false
while [[ $# -gt 0 ]]; do
  case $1 in
    --gpu)
      gpu=true
      ;;
    --cpu)
      gpu=false
      ;;
    *)
      echo "Unknown argument: $1"
      exit 1
      ;;
  esac
  shift
done

sudo-non-docker apt-get update
sudo-non-docker apt-get install --upgrade -y \
  apt-transport-https \
  curl \
  gnupg2 \
  wget

if [[ "$gpu" == "true" ]] ; then
  sudo-non-docker apt-get install --upgrade -y ubuntu-drivers-common
  sudo-non-docker ubuntu-drivers autoinstall
fi

mathlib_package="libopenblas-dev liblapacke-dev"
if [[ `uname -m` == "x86_64" ]] ; then
  mathlib_package="intel-oneapi-mkl-devel"
  curl -sL https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB | sudo-non-docker apt-key add -
  echo "deb https://apt.repos.intel.com/oneapi all main" | sudo-non-docker tee /etc/apt/sources.list.d/oneapi.list
fi
sudo-non-docker apt-get update
sudo-non-docker apt-get install --upgrade -y \
  autoconf \
  automake \
  build-essential \
  ca-certificates \
  clang-format-9 \
  cmake \
  ffmpeg \
  fonts-liberation \
  gawk \
  gconf-service \
  gdb \
  gfortran \
  git \
  groff \
  $mathlib_package \
  libasound2 \
  libc++-dev \
  libssl-dev \
  libpq-dev \
  libtool \
  logrotate \
  lsb-release \
  nodejs \
  npm \
  $([[ "$gpu" == "true" ]] && echo "nvidia-cuda-toolkit")  \
  postgresql-client \
  psmisc \
  python2-minimal \
  python3 \
  python3-dev \
  python3-pip \
  python-is-python3 \
  redis-tools \
  rsync \
  sox \
  subversion \
  swig \
  unzip \
  vim \
  xdg-utils \
  yarn \
  zlib1g-dev

jdk_arch=$([[ `uname -m` == "x86_64" ]] && echo "x64" || echo "aarch64")
curl -L "https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.19%2B10/OpenJDK17U-jdk_${jdk_arch}_linux_hotspot_17.0.19_10.tar.gz" -so jdk.tar.gz
tar xf jdk.tar.gz
rm jdk.tar.gz

echo ""
echo "Install complete!"
echo "Now, run build-dependencies.sh and add the following to your ~/.zshrc or ~/.bashrc:"
echo "export PATH=\"$SERENADE_LIBRARY_ROOT/jdk-17.0.19+10/bin:$SERENADE_LIBRARY_ROOT/gradle-7.4.2/bin:\$PATH\""
echo "export JAVA_HOME=\"$SERENADE_LIBRARY_ROOT/jdk-17.0.19+10\""

# If we're not installing on docker, we need to restart.
if [[ "$gpu" == "true" && "$EUID" != 0 ]] ; then
  echo ""
  echo "Restart your system to complete setup."
fi
