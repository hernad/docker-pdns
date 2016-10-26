#!/bin/bash

MYSQL_HOST=${MYSQL_HOST:-db}
MYSQL_PORT=${MYSQL_PORT:-3306}
MYSQL_USER=${MYSQL_USER:-root}
MYSQL_PASSWORD=${MYSQL_ROOT_PASSWORD}
MYSQL_DB=${MYSQL_DB:-pdns}
PDNS_ALLOW_AXFR_IPS=${PDNS_ALLOW_AXFR_IPS:-127.0.0.1/32}
PDNS_AUTH_MASTER=${PDNS_AUTH_MASTER:-yes}
PDNS_AUTH_SLAVE=${PDNS_AUTH_SLAVE:-no}
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

until nc -z ${MYSQL_HOST} ${MYSQL_PORT}; do
    echo "$(date) - waiting for mysql..."
    sleep 1
done


MYSQL_COMMAND="mysql -u ${MYSQL_USER} -p${MYSQL_PASSWORD} --host=${MYSQL_HOST}"



if $MYSQL_COMMAND $MYSQL_DB  >/dev/null 2>&1 </dev/null
then
        echo "Database ${MYSQL_DB} already exists"
else
        $MYSQL_COMMAND -e "CREATE DATABASE ${MYSQL_DB}"
        $MYSQL_COMMAND ${MYSQL_DB}  < /pdns.sql
        $MYSQL_COMMAND ${MYSQL_DB} < /poweradmin.sql
        #rm /pdns.sql /poweradmin.sql
fi

### PDNS
sed -i "s/{{MYSQL_HOST}}/${MYSQL_HOST}/" /etc/powerdns/pdns.d/pdns.local.gmysql.conf
sed -i "s/{{MYSQL_PORT}}/${MYSQL_PORT}/" /etc/powerdns/pdns.d/pdns.local.gmysql.conf
sed -i "s/{{MYSQL_USER}}/${MYSQL_USER}/" /etc/powerdns/pdns.d/pdns.local.gmysql.conf
sed -i "s/{{MYSQL_PASSWORD}}/${MYSQL_PASSWORD}/" /etc/powerdns/pdns.d/pdns.local.gmysql.conf
sed -i "s/{{MYSQL_DB}}/${MYSQL_DB}/" /etc/powerdns/pdns.d/pdns.local.gmysql.conf
sed -i "s/{{PDNS_ALLOW_AXFR_IPS}}/${PDNS_ALLOW_AXFR_IPS}/" /etc/powerdns/pdns.conf
sed -i "s/{{PDNS_AUTH_MASTER}}/${PDNS_AUTH_MASTER}/" /etc/powerdns/pdns.conf
sed -i "s/{{PDNS_AUTH_SLAVE}}/${PDNS_AUTH_SLAVE}/" /etc/powerdns/pdns.conf
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


if [ "$PDNS_AUTH_SLAVE" == "yes" ] ; then

#https://www.digitalocean.com/community/tutorials/how-to-configure-dns-replication-on-a-slave-powerdns-server-on-ubuntu-14-04
read -d '' SQL_CMD << EOF
insert into supermasters values ('${PDNS_AUTH_MASTER_IP}', '${PDNS_AUTH_SLAVE_FQDN}', 'admin')
EOF
echo "sql_cmd: $SQL_CMD"
$MYSQL_COMMAND ${MYSQL_DB} -e "$SQL_CMD"  # insert into supermasters

else

# master
/usr/bin/pdnsutil create-zone $PDNS_DOMAIN ns1.$PDNS_DOMAIN
/usr/bin/pdnsutil add-record $PDNS_DOMAIN @ NS ns2.$PDNS_DOMAIN 
/usr/bin/pdnsutil add-record $PDNS_DOMAIN ns1 A $PDNS_AUTH_MASTER_IP
/usr/bin/pdnsutil add-record $PDNS_DOMAIN ns2 A $PDNS_AUTH_SLAVE_IP
/usr/bin/pdnsutil add-record $PDNS_DOMAIN prvi A 1.1.1.1
/usr/bin/pdnsutil list-zone $PDNS_DOMAIN
/usr/bin/pdnsutil set-kind $PDNS_DOMAIN master

#read -d '' SQL_CMD << EOF
#INSERT INTO domains (name, type) VALUES ('$PDNS_DOMAIN', 'MASTER');
#INSERT INTO records (domain_id, name, content, type, ttl, prio) VALUES (1, '$', 'ns1.$PDNS_DOMAIN hostmaster.$PDNS_DOMAIN 1', 'SOA', 86400, NULL);
#INSERT INTO records (domain_id, name, content, type, ttl, prio) VALUES (1, '$PDNS_DOMAIN', 'ns1.$PDNS_DOMAIN', 'NS', 86400, NULL);
#INSERT INTO records (domain_id, name, content, type, ttl, prio) VALUES (1, '$PDNS_DOMAIN', 'ns2.$PDNS_DOMAIN', 'NS', 86400, NULL);
#INSERT INTO records (domain_id, name, content, type, ttl, prio) VALUES (1, 'ns1.$PDNS_DOMAIN', '10.0.0.1', 'A', 86400, NULL);
#INSERT INTO records (domain_id, name, content, type, ttl, prio) VALUES (1, 'ns2.$PDNS_DOMAIN', '10.0.0.2', 'A', 86400, NULL);
#EOF
#$MYSQL_COMMAND ${MYSQL_DB} -e "$SQL_CMD"  # insert example.org sample records

fi

exec /usr/bin/supervisord
