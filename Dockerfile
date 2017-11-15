FROM phusion/baseimage:latest as builder

ENV  STELLAR_CORE_VERSION=0.6.4-442-be645dff

RUN apt update \
    && apt-get install -y curl \
    && export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)" \
    && echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
    && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

RUN apt update \
    && apt-get install -y libpq-dev libsqlite3-dev google-cloud-sdk \
    && curl -s -o stellar-core.deb https://s3.amazonaws.com/stellar.org/releases/stellar-core/stellar-core-${STELLAR_CORE_VERSION}_amd64.deb \
    && apt-get install -y ./stellar-core.deb \
    && apt-get clean \
    && rm -rf stellar-core.deb /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 11625
EXPOSE 11626

RUN mkdir /data
VOLUME /data
RUN mkdir -p /secrets/gcloud/storage
VOLUME /secrets/gcloud/storage

ADD gsutil /gsutil

ADD configs /configs
VOLUME /configs

ADD start /

ENV NONEWDB=\
    NONEWHIST=\
    ARCHIVE_NAME=\
    STELLAR_CORE_CFG_URL=

ENTRYPOINT ["/bin/bash", "/start"]
