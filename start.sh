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


until nc -z ${MYSQL_HOST} ${MYSQL_PORT}; do
    echo "$(date) - waiting for mysql..."
    sleep 1
done

MYSQL_COMMAND="mysql -u ${MYSQL_USER} -p${MYSQL_PASSWORD} --host=${MYSQL_HOST} ${MYSQL_DB}"

if $MYSQL_COMMAND  >/dev/null 2>&1 </dev/null
then
	echo "Database ${MYSQL_DB} already exists"
else
	$MYSQL_COMMAND -e "CREATE DATABASE ${MYSQL_DB}"
	$MYSQL_COMMAND < /pdns.sql
	$MYSQL_COMMAND < /poweradmin.sql
	rm /pdns.sql /poweradmin.sql
fi


if [ "$PDNS_SLAVE"=="yes" ] ; then

#https://www.digitalocean.com/community/tutorials/how-to-configure-dns-replication-on-a-slave-powerdns-server-on-ubuntu-14-04

read -d '' SQL_CMD << EOF
insert into supermasters values ('${PDNS_MASTER_IP}', '${PDNS_SLAVE_FQDN}', 'admin')
EOF
echo "sql_cmd: $SQL_CMD"
$MYSQL_COMMAND -e "$SQL_CMD"  # insert into supermasters
fi

### PDNS
sed -i "s/{{MYSQL_HOST}}/${MYSQL_HOST}/" /etc/powerdns/pdns.d/pdns.local.gmysql.conf
sed -i "s/{{MYSQL_PORT}}/${MYSQL_PORT}/" /etc/powerdns/pdns.d/pdns.local.gmysql.conf
sed -i "s/{{MYSQL_USER}}/${MYSQL_USER}/" /etc/powerdns/pdns.d/pdns.local.gmysql.conf
sed -i "s/{{MYSQL_PASSWORD}}/${MYSQL_PASSWORD}/" /etc/powerdns/pdns.d/pdns.local.gmysql.conf
sed -i "s/{{MYSQL_DB}}/${MYSQL_DB}/" /etc/powerdns/pdns.d/pdns.local.gmysql.conf
sed -i "s/{{PDNS_ALLOW_AXFR_IPS}}/${PDNS_ALLOW_AXFR_IPS}/" /etc/powerdns/pdns.conf
sed -i "s/{{PDNS_MASTER}}/${PDNS_MASTER}/" /etc/powerdns/pdns.conf
sed -i "s/{{PDNS_SLAVE}}/${PDNS_SLAVE}/" /etc/powerdns/pdns.conf
sed -i "s/{{PDNS_CACHE_TTL}}/${PDNS_CACHE_TTL}/" /etc/powerdns/pdns.conf
sed -i "s/{{PDNS_DISTRIBUTOR_THREADS}}/${PDNS_DISTRIBUTOR_THREADS}/" /etc/powerdns/pdns.conf
sed -i "s/{{PDNS_RECURSIVE_CACHE_TTL}}/${PDNS_RECURSIVE_CACHE_TTL}/" /etc/powerdns/pdns.conf
sed -i "s/{{PDNS_ALLOW_RECURSION}}/${PDNS_ALLOW_RECURSION}/" /etc/powerdns/pdns.conf
sed -i "s/{{PDNS_RECURSOR}}/${PDNS_RECURSOR}/" /etc/powerdns/pdns.conf
sed -i "s/{{PDNS_WEBSERVER_PASSWORD}}/${PDNS_WEBSERVER_PASSWORD}/" /etc/powerdns/pdns.conf
sed -i "s/{{PDNS_API_KEY}}/${PDNS_API_KEY}/" /etc/powerdns/pdns.conf

### POWERADMIN
sed -i "s/{{MYSQL_HOST}}/${MYSQL_HOST}/" /var/www/html/inc/config.inc.php
sed -i "s/{{MYSQL_PORT}}/${MYSQL_PORT}/" /var/www/html/inc/config.inc.php
sed -i "s/{{MYSQL_USER}}/${MYSQL_USER}/" /var/www/html/inc/config.inc.php
sed -i "s/{{MYSQL_PASSWORD}}/${MYSQL_PASSWORD}/" /var/www/html/inc/config.inc.php
sed -i "s/{{MYSQL_DB}}/${MYSQL_DB}/" /var/www/html/inc/config.inc.php
sed -i "s/{{POWERADMIN_HOSTMASTER}}/${POWERADMIN_HOSTMASTER}/" /var/www/html/inc/config.inc.php
sed -i "s/{{POWERADMIN_NS1}}/${POWERADMIN_NS1}/" /var/www/html/inc/config.inc.php
sed -i "s/{{POWERADMIN_NS2}}/${POWERADMIN_NS2}/" /var/www/html/inc/config.inc.php

exec /usr/bin/supervisord

