FROM python:3.11

ARG QUAST_VERSION=5.2.0
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
  bash ca-certificates \
  gzip unzip \
  coreutils \
  zlib1g-dev \
  && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir "quast==${QUAST_VERSION}"

ENTRYPOINT ["bash"]