#!/bin/bash
MYSQL_HOST=${MYSQL_HOST:-db}
MYSQL_PORT=${MYSQL_PORT:-3306}
MYSQL_USER=${MYSQL_USER:-root}
MYSQL_PASSWORD=${MYSQL_ROOT_PASSWORD}
MYSQL_DB=${MYSQL_DB:-pdns}
PDNS_ALLOW_AXFR_IPS=${PDNS_ALLOW_AXFR_IPS:-127.0.0.1/32}
PDNS_MASTER=${PDNS_MASTER:-yes}
PDNS_SLAVE=${PDNS_SLAVE:-no}
PDNS_CACHE_TTL=${PDNS_CACHE_TTL:-20}
PDNS_DISTRIBUTOR_THREADS=${PDNS_DISTRIBUTOR_THREADS:-3}
PDNS_RECURSIVE_CACHE_TTL=${PDNS_RECURSIVE_CACHE_TTL:-10}
PDNS_ALLOW_RECURSION=${PDNS_ALLOW_RECURSION:-127.0.0.1/32}
PDNS_RECURSOR=${PDNS_RECURSOR:-no}
POWERADMIN_HOSTMASTER=${POWERADMIN_HOSTMASTER:-}
POWERADMIN_NS1=${POWERADMIN_NS1:-}
POWERADMIN_NS2=${POWERADMIN_NS2:-}
PDNS_WEBSERVER_PASSWORD=${PDNS_WEBSERVER_PASSWORD:-powerdns101}
PDNS_API_KEY=${PDNS_API_KEY:-apikey101}
PDNS_DOMAIN=${PDNS_DOMAIN:-example.org}
PDNS_RECURSOR_ALLOW=${PDNS_RECURSOR_ALLOW:-127.0.0.1,10.0.0.0\\/8,172.16.0.0\\/12,192.168.0.0\\/16} # https://doc.powerdns.com/md/recursor/settings/#allow-from

### PDNS-RECURSOR
sed -i "s/{{PDNS_WEBSERVER_PASSWORD}}/${PDNS_WEBSERVER_PASSWORD}/" /etc/powerdns/recursor.conf
sed -i "s/{{PDNS_API_KEY}}/${PDNS_API_KEY}/" /etc/powerdns/recursor.conf
sed -i "s/{{PDNS_RECURSOR_ALLOW}}/${PDNS_RECURSOR_ALLOW}/" /etc/powerdns/recursor.conf

exec /usr/bin/supervisord

