# syntax=docker/dockerfile:experimental

#### stage transform files
FROM centos:7.9.2009 as files_passer

RUN echo "CACHEKEY=2022-01-12-01 -> just to force it rebuild" 

COPY files /files

#### stage transform packages
FROM centos:7.9.2009 as packages_passer

RUN echo "CACHEKEY=2022-01-12-01 -> just to force it rebuild" 

COPY packages /packages

#### python after compile
FROM registry.cn-shanghai.aliyuncs.com/dev-container/compile-python:master_latest as python_passer

#### zsh after compile
FROM registry.cn-shanghai.aliyuncs.com/dev-container/compile-zsh:master_latest as zsh_passer

#### stage main
FROM registry.cn-shanghai.aliyuncs.com/dev-container/base:master_latest

ENV \
    PROXY_IP=10.24.1.136 \
    PROXY_PORT=8888

ENV \
    https_proxy=http://${PROXY_IP}:${PROXY_PORT} \
    http_proxy=http://${PROXY_IP}:${PROXY_PORT} \
    all_proxy=socks5://${PROXY_IP}:${PROXY_PORT}

ENV \
    HTTPS_PROXY="${https_proxy}" \
    HTTP_PROXY="${http_proxy}" \
    ALL_PROXY="${all_proxy}"

# update packages
RUN --mount=type=cache,target=/var/cache/yum,id=runtime-yum-20211120 \
    --mount=type=bind,from=files_passer,source=/files,target=/files,rw \
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
    # copy files
    && rsync -av /files/* / \
    \
    && set +ex 

ENV \
    PATH=/opt/rh/rh-postgresql13/root/usr/bin:/usr/local/python3/bin:$PATH \
    LD_LIBRARY_PATH=/opt/rh/rh-postgresql13/root/usr/lib64:${LD_LIBRARY_PATH} \
    \
    APP_ENABLED=/var/app/enabled \
    \
    POETRY_CACHE_DIR=/var/cache/poetry

# install python3
RUN --mount=type=cache,target=/var/cache/yum,id=runtime-yum-20211120 \
    --mount=type=cache,target=/var/cache/pip3,id=runtime-pip3-20211120 \
    --mount=type=cache,target=/var/cache/poetry,id=runtime-poetry-20211120 \
    --mount=type=bind,from=packages_passer,source=/packages,target=/packages,rw \
    --mount=type=bind,from=python_passer,source=/opt/srliao/python,target=/opt/srliao/python,rw \
    \
    echo "CACHEKEY=2022-01-12-01 -> just to force it rebuild"  \
    \
    # using set -x for debug, set -e to ensure that each command execution is successful
    && set -ex \
    \
    # install these package for python runtime
    && yum install -y \
    zlib-devel \
    bzip2 \
    bzip2-devel \
    openssl \
    openssl-devel \
    ncurses \
    ncurses-devel \
    sqlite-devel \
    readline-devel \
    tk-devel \
    libffi-devel \
    expat-devel \
    gdbm-devel \
    xz-devel \
    db4-devel \
    libpcap-devel \
    python-devel \
    libtirpc \
    && cd /opt/srliao/python/Python-3.8.12 \
    && make install > /dev/null \
    && ln -sf /usr/local/python3/bin/python3 /usr/bin/python3 \
    && ln -sf /usr/local/python3/bin/pip3 /usr/bin/pip3 \
    && echo "/usr/local/python3/lib" > /etc/ld.so.conf.d/python3.conf \
    && ldconfig \
    \
    # config python path for bigquant app
    && mkdir -p ${APP_ENABLED} \
    && ln -sf `python3 -c "import sys; print([p for p in sys.path if 'site-packages' in p][0])"`/srliao.pth /var/app/srliao.pth \
    && echo ${APP_ENABLED} > /var/app/srliao.pth \
    \
    # update pip
    && pip3 install -U \
    pip \
    setuptools \
    wheel \
    && pip3 --version \
    \
    # install base package for dev
    && yum install -y \
    # version is fixed in /etc/yum.repos.d/CentOS7-bigquant.repo, mirror from mysql57
    mysql-community-devel \
    rh-postgresql13-postgresql-devel \
    # to install pg_isready, as a database livenessprobe in the service container
    rh-postgresql13-postgresql-syspaths \
    libmemcached-devel \
    \
    # install poetry
    && pip3 install poetry \
    && poetry completions bash > /etc/bash_completion.d/poetry.bash-completion \
    && poetry config virtualenvs.create false \
    && poetry config repositories.aliyun http://mirrors.aliyun.com/pypi/simple/ \
    && poetry config cache-dir /var/cache/poetry \
    \
    # install nuitka
    && pip3 install Nuitka \
    \
    # install for fastapi
    && pip3 install \
    "uvicorn[standard]" \
    "uvicorn[uvloop]" \
    gunicorn \
    \
    # install dev utils 
    && pip3 install \
    pgcli \
    iredis \
    mycli \
    httpie \
    \
    && set +ex

ENV \
    PATH=/usr/local/go/bin:$PATH \
    GOROOT=/usr/local/go

# install go
RUN --mount=type=cache,target=/var/cache/yum,id=runtime-yum-20211120 \
    --mount=type=bind,from=packages_passer,source=/packages,target=/packages,rw \
    \
    echo "CACHEKEY=2022-01-12-01 -> just to force it rebuild" \
    \
    # using set -x for debug, set -e to ensure that each command execution is successful
    && set -ex \
    \
    && tar zxf /packages/go1.17.6.linux-amd64.tar.gz -C /usr/local \
    && go env -w GOPROXY=https://goproxy.cn,direct \
    && go version \
    \
    && set +ex

# intall npm and yarn
RUN --mount=type=cache,target=/var/cache/yum,id=runtime-yum-20211120 \
    --mount=type=cache,target=/var/cache/npm,id=runtime-npm-20211120 \
    --mount=type=cache,target=/var/cache/yarn,id=runtime-yarn-20211120 \
    \
    echo "CACHEKEY=2022-01-12-01 -> just to force it rebuild" \
    \
    # using set -x for debug, set -e to ensure that each command execution is successful
    && set -ex \
    \
    && yum makecache \
    # install nodejs
    && yum install -y nodejs yarn \
    \
    && npm config set strict-ssl false \
    && npm config set registry https://repos.bigquant.ai:443/artifactory/api/npm/remote.npm.npmjs \
    && npm config set sass_binary_site https://repos.bigquant.ai:443/artifactory/remote.npm.node-saas \
    && npm config set phantomjs_cdnurl https://repos.bigquant.ai:443/artifactory/remote.npm.phantomjs \
    && npm config set electron_mirror https://repos.bigquant.ai:443/artifactory/remote.npm.electron \
    && npm config set sqlite3_binary_host_mirror https://repos.bigquant.ai:443/artifactory/remote.npm.sqlite3 \
    && npm config set profiler_binary_host_mirror https://repos.bigquant.ai:443/artifactory/remote.npm.node-inspector \
    && npm config set chromedriver_cdnurl https://repos.bigquant.ai:443/artifactory/remote.npm.chromedriver \
    && npm install -g configurable-http-proxy grunt-cli \
    && npm config set cache /var/cache/npm \
    \
    && yarn config set strict-ssl false \
    && yarn config set registry https://repos.bigquant.ai:443/artifactory/api/npm/remote.npm.npmjs \
    && yarn config set sass_binary_site https://repos.bigquant.ai:443/artifactory/remote.npm.node-saas \
    && yarn config set phantomjs_cdnurl https://repos.bigquant.ai:443/artifactory/remote.npm.phantomjs \
    && yarn config set electron_mirror https://repos.bigquant.ai:443/artifactory/remote.npm.electron \
    && yarn config set sqlite3_binary_host_mirror https://repos.bigquant.ai:443/artifactory/remote.npm.sqlite3 \
    && yarn config set profiler_binary_host_mirror https://repos.bigquant.ai:443/artifactory/remote.npm.node-inspector \
    && yarn config set chromedriver_cdnurl https://repos.bigquant.ai:443/artifactory/remote.npm.chromedriver \
    && yarn config set cache /var/cache/yarn \
    \
    && npm install -g \
    html-minifier \
    lerna \
    myth6 \
    terser \
    uglify-js \
    uglifycss \
    webpack \
    teadocs \
    \
    && set +ex

# intall rust
ENV \
    PATH=/root/.cargo/bin:$PATH

RUN --mount=type=cache,target=/var/cache/yum,id=runtime-yum-20211120 \
    \
    echo "CACHEKEY=2022-01-12-01 -> just to force it rebuild" \
    \
    # using set -x for debug, set -e to ensure that each command execution is successful
    && set -ex \
    \
    && curl -fsSL https://sh.rustup.rs | sh -s -- -y \
    && rustup update \
    && rustup component add rls rust-src rust-analysis \
    && rustc --version \
    \
    && set +ex

# install zsh
RUN --mount=type=cache,target=/var/cache/yum,id=runtime-yum-20211120 \
    --mount=type=bind,from=zsh_passer,source=/opt/srliao/zsh,target=/opt/srliao/zsh,rw \
    \
    echo "CACHEKEY=2022-01-12-01 -> just to force it rebuild" \
    \
    # using set -x for debug, set -e to ensure that each command execution is successful
    && set -ex \
    \
    # install zsh 
    && cd /opt/srliao/zsh/zsh-5.8 \
    && make install > /dev/null \
    && zsh --version  \
    \
    && echo "/usr/local/bin/zsh" >> /etc/shells \
    && chsh -s /usr/local/bin/zsh root \
    \
    # install zimfw
    && wget -nv -O - https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh \
    && echo "zmodule ohmyzsh/ohmyzsh -f 'plugins/git' -s 'plugins/git/git.plugin.zsh' -f 'plugins/wd' -s 'plugins/wd/wd.plugin.zsh' -f 'plugins/pip' -s 'plugins/pip/pip.plugin.zsh' -f 'plugins/command-not-found' -s 'plugins/command-not-found/command-not-found.plugin.zsh' -f 'plugins/git-lfs' -s 'plugins/git-lfs/git-lfs.plugin.zsh' -f 'plugins/common-aliases' -s 'plugins/common-aliases/common-aliases.plugin.zsh' -f 'plugins/z' -s 'plugins/z/z.plugin.zsh'" >> ~/.zimrc \
    && echo "zmodule romkatv/powerlevel10k" >> ~/.zimrc \
    \
    && set +ex


ENV \
    SHELL=/usr/local/bin/zsh

CMD [ "zsh" ]

SHELL [ "/usr/local/bin/zsh" , "-c" ]

RUN --mount=type=cache,target=/var/cache/yum,id=runtime-yum-20211120 \
    \
    echo "CACHEKEY=2022-01-12-01 -> just to force it rebuild" \
    \
    # using set -x for debug, set -e to ensure that each command execution is successful
    && set -ex \
    \
    && git config --global merge.defaultToUpstream true \
    \
    && echo '# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.' >> ~/.zshrc \
    && echo '[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh' >> ~/.zshrc \
    \
    && source ~/.zshrc > /dev/null 2>&1 \
    && zimfw install \
    && zimfw update \
    \
    && echo 'source <(kubectl completion zsh)'  >> ~/.zshrc \
    && echo 'complete -F __start_kubectl k' >> ~/.zshrc \
    && echo 'alias k=kubectl' >>~/.zshrc \
    && echo 'autoload -Uz compinit'  >>~/.zshrc \
    && echo 'compinit'  >>~/.zshrc \
    \
    # custom zshrc
    && echo 'source ~/.zshrc-custom' >> ~/.zshrc \
    \
    && set +ex
