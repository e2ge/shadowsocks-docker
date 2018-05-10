FROM centos:latest 

MAINTAINER Rex1901 <me@e2ge.com> 

#shadowsocks-libev

ARG VERSION=3.1.3
ARG SS_URL=https://github.com/shadowsocks/shadowsocks-libev/releases/download/v$VERSION/shadowsocks-libev-$VERSION.tar.gz
ARG BASEDIR=/tmp/ss

ENV PACKAGES1 gcc make libev-devel libsodium-devel mbedtls-devel pcre-devel c-ares-devel

RUN rpm -ivh http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \
	&& yum install -y $PACKAGES1 \
	&& mkdir $BASEDIR && cd $BASEDIR \
	&& curl -sSL $SS_URL | tar xz --strip 1 \
	&& ./configure --disable-documentation \
	&& make && make install \
	&& yum history list $PACKAGES1 | grep install | awk {'print $1'} | xargs yum history undo -y \
	&& yum install -y libev libsodium mbedtls pcre c-ares \
	&& yum clean all \
	&& rm -fr $BASEDIR

#GoQuiet

ENV PACKAGES2 go git gcc make

RUN yum install -y $PACKAGES2 \
	&& cd ~ && git clone https://github.com/cbeuw/GoQuiet \
	&& go get -d -v github.com/cbeuw/GoQuiet/gqserver \
	&& cd GoQuiet && make server \
	&& cp build/gq-server /usr/local/bin \
	&& yum history list $PACKAGES2 | grep install | awk {'print $1'} | xargs yum history undo -y \
	&& yum clean all \
	&& rm -fr ~/go && rm -fr ~/GoQuiet



