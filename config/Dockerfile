FROM ubuntu:20.04

ARG BUILD_TYPE
ARG DEVICE_TYPE
ARG BUILD_JOBS=2
WORKDIR /root/serenade

ENV DEBIAN_FRONTEND="noninteractive"
COPY scripts/setup/paths.sh scripts/setup/setup-ubuntu.sh scripts/setup/
RUN ./scripts/setup/setup-ubuntu.sh $([ "${DEVICE_TYPE}" = "gpu" ] && echo "--gpu") && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

COPY scripts/setup/build-tools.sh scripts/setup/
RUN ./scripts/setup/build-tools.sh $([ "${DEVICE_TYPE}" = "gpu" ] && echo "--gpu")

COPY scripts/setup/build-boost.sh scripts/setup/
RUN ./scripts/setup/build-boost.sh --jobs=${BUILD_JOBS}

COPY scripts/setup/build-protobuf.sh scripts/setup/
RUN ./scripts/setup/build-protobuf.sh --jobs=${BUILD_JOBS}

COPY scripts/setup/build-sentencepiece.sh scripts/setup/
RUN ./scripts/setup/build-sentencepiece.sh --jobs=${BUILD_JOBS}

COPY patches/marian patches/marian
COPY scripts/setup/build-marian.sh scripts/setup/
RUN ./scripts/setup/build-marian.sh --jobs=${BUILD_JOBS} $([ "${DEVICE_TYPE}" = "gpu" ] && echo "--gpu")

COPY patches/kaldi patches/kaldi
COPY scripts/setup/build-kaldi.sh scripts/setup/
RUN ./scripts/setup/build-kaldi.sh --jobs=${BUILD_JOBS} $([ "${DEVICE_TYPE}" = "gpu" ] && echo "--gpu")

COPY scripts/setup/build-cleanup.sh scripts/setup/
RUN ./scripts/setup/build-cleanup.sh $([ "${BUILD_TYPE}" = "minimal" ] && echo "--minimal")

ENV JAVA_HOME="/root/libserenade/jdk-17.0.19+10"
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV PATH="/root/libserenade/gradle-7.4.2/bin:/root/libserenade/jdk-17.0.19+10/bin:/root/serenade/scripts/serenade/bin:${PATH}"
ENV PYTHONPATH="/root/serenade/scripts"
ENV SERENADE_SOURCE_ROOT="/root/serenade"
ENV SERENADE_LIBRARY_ROOT="/root/libserenade"

COPY build.gradle settings.gradle ./
COPY buildSrc buildSrc
COPY bin bin
COPY config config
COPY scripts scripts
COPY toolbelt toolbelt
COPY grammarflattener grammarflattener

COPY corpusgen corpusgen
COPY offline offline
COPY replayer replayer
COPY core core
COPY code-engine code-engine
COPY speech-engine speech-engine

RUN gradle core:installDist code-engine:installDist speech-engine:installDist --console=plain
