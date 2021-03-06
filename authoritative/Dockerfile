FROM ubuntu:xenial
MAINTAINER Ernad Husremovic <hernad@bring.out.ba>   # based on Patrick Oberdorf <patrick@oberdorf.net>

#ARG pgp_key=CBC8B383
#ARG pdns_branch=master
ARG pgp_key=FD380FBB
ARG pdns_branch=40

COPY assets/apt/preferences.d/pdns /etc/apt/preferences.d/pdns
RUN apt-get update && apt-get install -y curl \
	&& curl https://repo.powerdns.com/${pgp_key}-pub.asc | apt-key add - \
	&& echo "deb [arch=amd64] http://repo.powerdns.com/ubuntu xenial-auth-${pdns_branch} main" > /etc/apt/sources.list.d/pdns.list \
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
	php-fpm \
	php-mcrypt \
	php-mysqlnd \
	pdns-server \
	pdns-backend-mysql \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY assets/pdns/pdns.conf /etc/powerdns/pdns.conf
COPY assets/pdns/pdns.d/ /etc/powerdns/pdns.d/
COPY assets/mysql/pdns.sql /pdns.sql

### PHP/Nginx ###
#RUN rm /etc/nginx/sites-enabled/default
RUN phpenmod mcrypt
RUN mkdir -p /var/www/html/ \
	&& cd /var/www/html ; rm -rf * \
	&& git clone https://github.com/wociscz/poweradmin.git . \
        && rm -rf /var/www/html/install
        # /var/www/html/index.php 
	#&& git checkout 98ecbb5692d4f9bc42110ec478be63eb5651c6de \

COPY assets/poweradmin/config.inc.php /var/www/html/inc/config.inc.php
COPY assets/mysql/poweradmin.sql /poweradmin.sql
RUN chown -R www-data:www-data /var/www/html/ \
	&& chmod 644 /etc/powerdns/pdns.d/pdns.*

### SUPERVISOR ###
COPY assets/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY start.sh /start.sh

COPY assets/nginx/default /etc/nginx/sites-enabled/default
EXPOSE 53 80 8081
EXPOSE 53/udp

CMD ["/bin/bash", "/start.sh"]
