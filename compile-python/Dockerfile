# syntax=docker/dockerfile:experimental

#### stage transform packages
FROM centos:7.9.2009 as packages_passer

RUN echo "CACHEKEY=2022-01-12-01 -> just to force it rebuild" 

COPY packages /packages

#### stage build
FROM registry.cn-shanghai.aliyuncs.com/dev-container/base:master_latest as builder

RUN echo "CACHEKEY=2022-01-12-01 -> just to force it rebuild" 

ENV \
    CC=/opt/rh/devtoolset-7/root/usr/bin/gcc \
    CXX=/opt/rh/devtoolset-7/root/usr/bin/g++ \
    CPP=/opt/rh/devtoolset-7/root/usr/bin/cpp

RUN --mount=type=cache,target=/var/cache/yum,id=centos-compiler-20211120 \
    --mount=type=bind,from=packages_passer,source=/packages,target=/packages,rw \
    \
    echo "CACHEKEY=2021022001 -> just to force it rebuild" \
    \
    # using set -x for debug, set -e to ensure that each command execution is successful
    && set -ex \
    \
    # update packages
    && yum clean metadata \
    && yum makecache \
    && yum update --exclude=centos-release* --skip-broken -y \
    \
    # check python source package
    && mkdir -p /opt/srliao/python/ \
    && tar zxf /packages/Python-3.8.12.tgz -C /opt/srliao/python/ \
    # prepare for compile python3
    && yum-builddep -y python3 \
    # fix gcc/g++ version
    && yum install -y \
        devtoolset-7-gcc \
        devtoolset-7-gcc-c++ \
        devtoolset-7-binutils \
    && ln -sf /opt/rh/devtoolset-7/root/usr/bin/gcc /usr/bin/gcc \
    && ln -sf /opt/rh/devtoolset-7/root/usr/bin/g++ /usr/bin/g++ \
    && ln -sf /opt/rh/devtoolset-7/root/usr/bin/cpp /usr/bin/cpp \
    \
    # compile python
    && cd /opt/srliao/python/Python-3.8.12 \
    && ./configure --prefix=/usr/local/python3 --enable-optimizations --enable-shared \
    && make -j > /dev/null \
    && gcc --version \
    && g++ --version \
    \
    # clean all
    && yum clean all \
    && rm -rf /tmp/* \
    && rm -rf /packages/* \
    \
    && set +ex

#### stage main
FROM scratch

COPY --from=builder /opt/srliao/python /opt/srliao/python
