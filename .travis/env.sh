#!/usr/bin/env bash

APP_VARIANT=${TRAVIS_TAG#*-} && [[ ${APP_VARIANT} = ${TRAVIS_TAG} ]] && APP_VARIANT="";
APP_VERSION=${TRAVIS_TAG%-${APP_VARIANT}};
APP_VERSION=${APP_VERSION} && [[ $APP_VERSION =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]] || APP_VERSION=""
[ -z "$APP_VERSION" ] && APP_VARIANT="" || true
APP_DOCKERFILE=Dockerfile && [[ -n $APP_VARIANT ]] && APP_DOCKERFILE="Dockerfile.${APP_VARIANT}" || true
