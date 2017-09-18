FROM stellar/base:latest

# NOTE:  This dockerfile is for the base quickstart image, of which two
# derivatives are created (the testnet and pubnet images).  Images built from
# this dockerfile aren't intended to be used directly.  See testnet/Dockerfile
# or pubnet/Dockerfile for details on how those images are built.

MAINTAINER Oleg Tokarev <otokarev@gmail.com>

ENV STELLAR_CORE_VERSION 0.6.3-391-708237b0

EXPOSE 5432
EXPOSE 8000
EXPOSE 11625
EXPOSE 11626

ADD dependencies /
RUN ["chmod", "+x", "dependencies"]
RUN /dependencies

ADD install /
RUN ["chmod", "+x", "install"]
RUN /install

RUN ["mkdir", "-p", "/opt/stellar"]

RUN [ "adduser", \
  "--disabled-password", \
  "--gecos", "\"\"", \
  "--uid", "10011001", \
  "stellar"]

RUN ["ln", "-s", "/opt/stellar", "/stellar"]
RUN ["ln", "-s", "/opt/stellar/core/etc/stellar-core.cfg", "/stellar-core.cfg"]
RUN ["ln", "-s", "/opt/stellar/core/buckets", "/buckets"]
ADD core /opt/stellar/core
ADD supervisor /opt/stellar/supervisor
RUN chown -R stellar:stellar /opt/stellar/core


ADD start /
RUN ["chmod", "+x", "start"]

ENV PROJECT=\
    NONEWDB=\
    NONEWHIST=\
    ARCHIVE_NAME=\
    GS_ACCESS_KEY_ID=\
    GS_SECRET_ACCESS_KEY=\
    STELLAR_CORE_CFG_URL=

ENTRYPOINT ["/init", "--", "/start" ]
