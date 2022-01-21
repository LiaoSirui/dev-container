# syntax=docker/dockerfile:experimental

#### stage transform files
FROM centos:7.9.2009 as files_passer

RUN echo "CACHEKEY=2021022001 -> just to force it rebuild"

COPY files /files

#### stage transform packages
FROM centos:7.9.2009 as packages_passer

RUN echo "CACHEKEY=2021022001 -> just to force it rebuild"

COPY packages /packages


FROM centos:7.9.2009

ENV \
    PROXY_IP=10.24.8.2 \
    PROXY_PORT=7890

ENV \
    https_proxy=http://${PROXY_IP}:${PROXY_PORT} \
    http_proxy=http://${PROXY_IP}:${PROXY_PORT} \
    all_proxy=socks5://${PROXY_IP}:${PROXY_PORT}

ENV \
    HTTPS_PROXY="${https_proxy}" \
    HTTP_PROXY="${http_proxy}" \
    ALL_PROXY="${all_proxy}"

ENV TZ=Asia/Shanghai \
    SHELL=/bin/bash \
    \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    \
    CC=/opt/rh/devtoolset-7/root/usr/bin/gcc \
    CXX=/opt/rh/devtoolset-7/root/usr/bin/g++ \
    CPP=/opt/rh/devtoolset-7/root/usr/bin/cpp \
    \
    PATH=/opt/rh/rh-git218/root/usr/bin:${PATH} \
    LD_LIBRARY_PATH=/opt/rh/httpd24/root/usr/lib64:${LD_LIBRARY_PATH}

RUN --mount=type=cache,target=/var/cache/yum,id=centos-zero-20211120 \
    --mount=type=bind,from=files_passer,source=/files,target=/files,rw \
    --mount=type=bind,from=packages_passer,source=/packages,target=/packages,rw \
    \
    echo "CACHEKEY=2021022001 -> just to force it rebuild" \
    \
    # using set -x for debug, set -e to ensure that each command execution is successful
    && set -ex \
    \
    # update kernel-headers
    && rpm -Uvh /packages/kernel-ml-headers-4.19.12-1.el7.elrepo.x86_64.rpm \
    \
    # config repo
    && sed -e 's|^mirrorlist=|#mirrorlist=|g' \
    -e 's|^#baseurl=http://mirror.centos.org|baseurl=https://mirrors.tuna.tsinghua.edu.cn|g' \
    -i.bak \
    /etc/yum.repos.d/CentOS-*.repo \
    \
    # config yum
    && sed -i 's/keepcache=0/keepcache=1/g' /etc/yum.conf \
    # ADD zh_CN support
    && sed -i 's/override_install_langs=en_US.utf8/#override_install_langs=en_US.utf8/g' /etc/yum.conf \
    # disable fast mirror yum plugin
    && sed -i 's/enabled=1/enabled=0/g' /etc/yum/pluginconf.d/fastestmirror.conf \
    && yum clean metadata \
    && yum makecache \
    && yum update --exclude=centos-release* --skip-broken -y \
    \
    # install package for yum
    && yum install -y \
    yum-utils \
    wget \
    ca-certificates \
    redhat-lsb-core \
    # example: yum versionlock gcc-*
    yum-plugin-versionlock \
    # exmaple: yum install [包名] --downloadonly --downloaddir=[文件路径]
    yum-plugin-downloadonly \
    \
    # epel repo
    && yum install epel-release -y \
    && sed -e 's!^metalink=!#metalink=!g' \
    -e 's!^#baseurl=!baseurl=!g' \
    -e 's!//download\.fedoraproject\.org/pub!//mirrors.tuna.tsinghua.edu.cn!g' \
    -e 's!//download\.example/pub!//mirrors.tuna.tsinghua.edu.cn!g' \
    -e 's!http://mirrors!https://mirrors!g' \
    -i /etc/yum.repos.d/epel*.repo \
    \
    # ius repo
    && yum install -y https://mirrors.aliyun.com/ius/ius-release-el7.rpm \
    && sed -i "s|repo.ius.io|mirrors.tuna.tsinghua.edu.cn/ius|g" /etc/yum.repos.d/ius.repo \
    \
    && yum install -y centos-release-scl \
    \
    # docker-ce repo
    && wget -O /etc/yum.repos.d/docker-ce.repo https://download.docker.com/linux/centos/docker-ce.repo \
    && sed -i 's+download.docker.com+mirrors.tuna.tsinghua.edu.cn/docker-ce+' /etc/yum.repos.d/docker-ce.repo \
    \
    # vim repo
    && wget -O /etc/yum.repos.d/vim-latest.repo https://copr.fedorainfracloud.org/coprs/lantw44/vim-latest/repo/epel-7/lantw44-vim-latest-epel-7.repo \
    \
    # remi repo
    && yum install -y https://mirrors.aliyun.com/remi/enterprise/remi-release-7.rpm \
    && yum-config-manager --disable remi-php54 \
    && yum-config-manager --enable remi-php74 \
    \
    # cuda repo
    && wget -O /etc/yum.repos.d/cuda-rhel7.repo https://developer.download.nvidia.com/compute/cuda/repos/rhel7/x86_64/cuda-rhel7.repo \
    && yum-config-manager --disable cuda-rhel7-x86_64 \
    # navida-ml repo
    && yum install -y https://developer.download.nvidia.com/compute/machine-learning/repos/rhel7/x86_64/nvidia-machine-learning-repo-rhel7-1.0.0-1.x86_64.rpm \
    && yum-config-manager --disable nvidia-machine-learning \
    \
    # npm repo
    && curl -fsSL https://rpm.nodesource.com/setup_14.x | bash - \
    # yarn repo
    && wget -O /etc/yum.repos.d/yarn.repo https://dl.yarnpkg.com/rpm/yarn.repo \
    \
    && yum makecache fast \
    \
    # config fonts
    && yum groupinstall -y Fonts \
    && localedef -c -i en_US -f UTF-8 en_US.UTF-8 \
    \
    # config timezone
    && yum install -y tzdata \
    && rm -f /etc/localtime \
    && ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone \
    \
    && set +ex

RUN --mount=type=cache,target=/var/cache/yum,id=centos-zero-20211120 \
    --mount=type=bind,from=files_passer,source=/files,target=/files,rw \
    --mount=type=bind,from=packages_passer,source=/packages,target=/packages,rw \
    \
    echo "CACHEKEY=2021022001 -> just to force it rebuild" \
    \
    # using set -x for debug, set -e to ensure that each command execution is successful
    && set -ex \
    \
    # install and config gcc/g++ 7
    && yum install -y \
    devtoolset-7-gcc \
    devtoolset-7-gcc-c++ \
    devtoolset-7-binutils \
    && ln -sf /opt/rh/devtoolset-7/root/usr/bin/gcc /usr/bin/gcc \
    && ln -sf /opt/rh/devtoolset-7/root/usr/bin/g++ /usr/bin/g++ \
    && ln -sf /opt/rh/devtoolset-7/root/usr/bin/cpp /usr/bin/cpp \
    \
    && set +ex

RUN --mount=type=cache,target=/var/cache/yum,id=centos-zero-20211120 \
    --mount=type=bind,from=files_passer,source=/files,target=/files,rw \
    --mount=type=bind,from=packages_passer,source=/packages,target=/packages,rw \
    \
    echo "CACHEKEY=2021022001 -> just to force it rebuild" \
    \
    # using set -x for debug, set -e to ensure that each command execution is successful
    && set -ex \
    \
    # for edit
    && yum install -y vim \
    # for download files
    && yum install -y wget curl axel \
    # network debug tools
    && yum install -y telnet nslookup traceroute nc bind-utils net-tools \
    # other tools
    && yum install -y rsync \
    bash-completion \
    screen \
    collectd \
    rh-git218-git-lfs \
    rh-git218 \
    tmux \
    \
    # as a denpence, it will be override by devtoolset-10-gcc and devtoolset-10-gcc-c++ 
    # can not remove it, it may be installed again by other dependencies
    gcc \
    gcc-c++ \
    cpp \
    \
    && wget https://silenceshell-1255345740.cos.ap-shanghai.myqcloud.com/topic/topic -O /usr/local/bin/topic \
    \
    # config git
    && git config --global user.name "srliao" \
    && git config --global user.email "cyril@liaosirui.com" \
    # git config
    # https://github.com/git-lfs/git-lfs/issues/3675
    && git config --global core.trustctime false \
    \
    # docker and k8s client
    && yum install -y docker-client kubernetes-client \
    && kubectl version --client \
    # && docker version \
    \
    # copy files
    && rsync -av /files/* / \
    \
    # clean all
    && yum clean all \
    && rm -rf /tmp/* \
    && rm -rf /files/* \
    && rm -rf /packages/* \
    \
    && set +ex
