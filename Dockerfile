FROM centos:latest 

MAINTAINER e2ge <me@e2ge.com> 


RUN rpm -ivh http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \
	&& yum install -y gcc make libsodium-devel libsodium

#shadowsocks-libev

ARG SS_LIBEV_VERSION=3.1.3
ARG SS_LIBEV_URL=https://github.com/shadowsocks/shadowsocks-libev/releases/download/v$SS_LIBEV_VERSION/shadowsocks-libev-$SS_LIBEV_VERSION.tar.gz
ARG SS_LIBEV_BASEDIR=/tmp/sslibev

ENV SS_LIBEV_PACKAGES libev-devel mbedtls-devel pcre-devel c-ares-devel

RUN yum install -y $SS_LIBEV_PACKAGES \
	&& mkdir $SS_LIBEV_BASEDIR && cd $SS_LIBEV_BASEDIR \
	&& curl -sSL $SS_LIBEV_URL | tar xz --strip 1 \
	&& ./configure --disable-documentation --prefix=/usr/local/sslibev \
	&& make && make install \
	&& yum history list $SS_LIBEV_PACKAGES | grep install | awk {'print $1'} | xargs yum history undo -y \
	&& yum install -y libev mbedtls pcre c-ares \
	&& rm -fr $SS_LIBEV_BASEDIR

#GoQuiet

ARG GQ_VERSION=1.1.2
ARG GQ_URL=https://github.com/cbeuw/GoQuiet.git
ARG GQ_BASEDIR=/tmp/gq

ENV GQ_PACKAGES go git

RUN yum install -y $GQ_PACKAGES \
	&& mkdir $GQ_BASEDIR && cd $GQ_BASEDIR \
	&& git clone $GQ_URL . \
	&& go get -d -v github.com/cbeuw/GoQuiet/gqserver \
	&& make server \
	&& cp build/gq-server /usr/local/bin \
	&& yum history list $GQ_PACKAGES | grep install | awk {'print $1'} | xargs yum history undo -y \
	&& rm -fr ~/go && rm -fr $GQ_BASEDIR

#shadowsocks-rust

ARG SS_RUST_VER=1.6.12
ARG SS_RUST_URL=https://github.com/shadowsocks/shadowsocks-rust/archive/v$SS_RUST_VER.tar.gz
ARG SS_RUST_BASEDIR=/tmp/ssrust

ENV SS_RUST_PACKAGES openssl-devel

RUN curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain nightly -y \
	&& source ~/.profile \
	&& yum install -y $SS_RUST_PACKAGES \
	&& mkdir $SS_RUST_BASEDIR && cd $SS_RUST_BASEDIR \
	&& curl -sSL $SS_RUST_URL | tar xz --strip 1 \
	&& cargo install --path . --root /usr/local/ssrust --all-features \
	&& yum history list $SS_RUST_PACKAGES | grep install | awk {'print $1'} | xargs yum history undo -y \
	&& yum install -y openssl \
	&& rustup self uninstall -y \
	&& rm -rf $SS_RUST_BASEDIR

RUN yum clean all && rm -rf /var/cache/yum
