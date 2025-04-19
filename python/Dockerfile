ARG VERSION=1.2.0
FROM developmentseed/geolambda:${VERSION}

LABEL maintainer="Development Seed <info@developmentseed.org>"
LABEL authors="Matthew Hanson  <matt.a.hanson@gmail.com>"

ARG PYVERSION=3.7.4

# install Python
ENV \
    PYENV_ROOT=/root/.pyenv \
    PATH=/root/.pyenv/shims:/root/.pyenv/bin:$PATH

RUN yum update -y && \
    yum install -y \
      gcc make zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel \
      xz xz-devel libffi-devel wget curl \
      libxml2-devel libxmlsec1-devel ncurses-devel tk-devel && \
    yum clean all

RUN mkdir -p /usr/local/src && \
    cd /usr/local/src && \
    curl -L -O https://www.openssl.org/source/openssl-1.1.1w.tar.gz && \
    tar xzvf openssl-1.1.1w.tar.gz && \
    cd openssl-1.1.1w && \
    ./config --prefix=/usr/local/openssl --openssldir=/usr/local/openssl shared zlib && \
    make -j$(nproc) && \
    make install

RUN \
    curl https://pyenv.run | bash

COPY requirements*.txt ./
COPY bin/* /usr/local/bin/

RUN PATH="/usr/local/openssl/bin:$PATH" \
    LD_LIBRARY_PATH="/usr/local/openssl/lib" \
    CONFIGURE_OPTS="--with-openssl=/usr/local/openssl" \
    LD_RUN_PATH="/usr/local/openssl/lib" \
    PIP_NO_BUILD_ISOLATION=1 \
    run-pyenv.sh bash -c '\
    pyenv install '${PYVERSION}' && \
    pyenv global '${PYVERSION}' && \
    pyenv rehash && \
    pip install --no-build-isolation --upgrade pip && \
    pip install --no-build-isolation wheel && \
    pip install --no-build-isolation -r requirements-pre.txt && \
    pip install --no-build-isolation -r requirements.txt'
