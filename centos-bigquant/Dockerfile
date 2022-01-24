# syntax=docker/dockerfile:experimental

#### stage copy ta-lib after compile
FROM dockerhub.bigquant.ai:5000/dockerstacks/centos-compile-talib:master_latest as ta_lib_passer

#### stage poetry pip install
FROM dockerhub.bigquant.ai:5000/dockerstacks/centos-runtime:master_latest as bigquant_runtime

FROM registry.cn-shanghai.aliyuncs.com/dev-container/runtime:master_latest

ENV \
    # hack for poetry install 
    CURL_CA_BUNDLE=""

SHELL [ "/bin/sh", "-c" ]

RUN --mount=type=cache,target=/var/cache/yum,id=runtime-yum-20211120 \
    --mount=type=cache,target=/var/cache/pip3,id=runtime-pip3-20211120 \
    --mount=type=cache,target=/var/cache/poetry,id=runtime-poetry-20211120 \
    --mount=type=bind,from=ta_lib_passer,source=/opt/bigquant/talib/ta-lib,target=/opt/bigquant/talib/ta-lib,rw \
    --mount=type=bind,from=bigquant_runtime,source=/var/app/enabled,target=/opt/var/app/enabled,rw \
    \
    echo "CACHEKEY=2022-01-12-01 -> just to force it rebuild"  \
    \
    # using set -x for debug, set -e to ensure that each command execution is successful
    && set -ex \
    \
    # update packages
    && yum clean metadata \
    && yum makecache \
    && yum update --exclude=centos-release* --skip-broken -y \
    \
    # intall ta-lib
    && cd /opt/bigquant/talib/ta-lib \
    && ./configure --prefix=/usr > /dev/null \
    && make > /dev/null \
    && make install >/dev/null \
    && ldconfig \
    && pip3 install TA-Lib==0.4.21 \
    \
    && cd /opt/var/app/enabled \
    && poetry config virtualenvs.create false \
    && poetry env use system \
    && poetry install \
    \
    && set +ex
