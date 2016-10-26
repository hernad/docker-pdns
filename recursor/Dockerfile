FROM ubuntu:xenial
MAINTAINER Ernad Husremovic <hernad@bring.out.ba>   # based on Patrick Oberdorf <patrick@oberdorf.net>

ARG pgp_key=FD380FBB
ARG pdns_branch=40

COPY assets/apt/preferences.d/pdns /etc/apt/preferences.d/pdns
RUN apt-get update && apt-get install -y curl \
	&& curl https://repo.powerdns.com/${pgp_key}-pub.asc | apt-key add - \
	&& echo "deb [arch=amd64] http://repo.powerdns.com/ubuntu xenial-rec-${pdns_branch} main" > /etc/apt/sources.list.d/pdns.list \
        && apt-get update

RUN export DEBIAN_FRONTEND=noninteractive \
   && apt-get install -y \
	wget \
        netcat \
        dnsutils iputils-ping net-tools \
        vim \
	git \
	supervisor \
	mysql-client \
	nginx \
	pdns-recursor \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN  mv /etc/powerdns/recursor.conf /etc/powerdns/recursor-orig.conf
COPY pdns-recursor.conf /etc/powerdns/recursor.conf
COPY script.lua /etc/powerdns/script.lua

### SUPERVISOR ###
COPY supervisord-recursor.conf /etc/supervisor/conf.d/supervisord.conf
COPY start.sh /start.sh

EXPOSE 53 8081
EXPOSE 53/udp

CMD ["/bin/bash", "/start.sh"]
