FROM stellar/base:latest

# NOTE:  This dockerfile is for the base quickstart image, of which two
# derivatives are created (the testnet and pubnet images).  Images built from
# this dockerfile aren't intended to be used directly.  See testnet/Dockerfile
# or pubnet/Dockerfile for details on how those images are built.

MAINTAINER Oleg Tokarev <otokarev@gmail.com>

ENV STELLAR_CORE_VERSION 0.6.3-391-708237b0

EXPOSE 11625
EXPOSE 11626

RUN mkdir /data
VOLUME /data
RUN mkdir -p /secrets/gcloud/storage
VOLUME /secrets/gcloud/storage

ADD dependencies /
RUN sh /dependencies

ADD gsutil /gsutil

# Default config for testnet
ADD stellar-core.cfg /stellar-core.cfg

ADD install /
RUN sh /install

ADD start /

ENV PROJECT=\
    NONEWDB=\
    NONEWHIST=\
    ARCHIVE_NAME=\
    GS_ACCESS_KEY_ID=\
    GS_SECRET_ACCESS_KEY=\
    STELLAR_CORE_CFG_URL=

ENTRYPOINT ["/bin/bash", "/start"]
