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
    echo "CACHEKEY=2022-01-12-01 -> just to force it rebuild" \
    \
    # using set -x for debug, set -e to ensure that each command execution is successful
    && set -ex \
    \
    # update packages
    && yum clean metadata \
    && yum makecache \
    && yum update --exclude=centos-release* --skip-broken -y \
    \
    # check zsh source package
    && mkdir -p /opt/srliao/zsh \
    && tar -xJf /packages/zsh-5.8.tar.xz -C /opt/srliao/zsh \
    # fix gcc/g++ version
    && yum install -y \
        devtoolset-7-gcc \
        devtoolset-7-gcc-c++ \
        devtoolset-7-binutils \
    && ln -sf /opt/rh/devtoolset-7/root/usr/bin/gcc /usr/bin/gcc \
    && ln -sf /opt/rh/devtoolset-7/root/usr/bin/g++ /usr/bin/g++ \
    && ln -sf /opt/rh/devtoolset-7/root/usr/bin/cpp /usr/bin/cpp \
    \
    # compile zsh
    && cd /opt/srliao/zsh/zsh-5.8 \
    && yum-builddep -y zsh \
    # Installing:
    # autoconf                                          noarch             2.69-11.el7                                       base                701 k
    # libcap-devel                                      x86_64             2.22-11.el7                                       base                 26 k
    # ncurses-devel                                     x86_64             5.9-14.20130511.el7_4                             base                712 k
    # texi2html                                         noarch             1.82-10.el7                                       base                394 k
    # texinfo                                           x86_64             5.1-5.el7                                         base                961 k
    && ./configure --with-tcsetpgrp > /dev/null \
    && make -j > /dev/null \
    \
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

COPY --from=builder /opt/srliao/zsh /opt/srliao/zsh
