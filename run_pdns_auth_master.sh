#!/bin/bash

. common.sh

docker service rm pdns
docker service rm pdns_db

echo "=== MASTER PDNS ===="

#docker volume rm pdns_mysql_data
#docker volume create --name pdns_mysql_data

CONSTRAINTS="--constraint node.labels.role==${LABEL_PDNS_AUTH_MASTER}"
#CONSTRAINTS+=" --constraint engine.labels.provider==digitalocean "



echo "$CONSTRAINT"

CMD="docker service create --name  pdns_db"
CMD+=" --replicas 1"
CMD+=" $CONSTRAINTS"
CMD+=" --mount type=volume,source=pdns_mysql_data,destination=/var/lib/mysql"
CMD+=" -e MYSQL_ROOT_PASSWORD=test01"
CMD+=" --network $PDNS_NETWORK"
CMD+=" mysql"

echo $CMD
$CMD
echo ===================



echo pdns
docker service create --name pdns \
    --replicas 1 \
    -p 531:53/udp \
    -p 8082:80 \
    -p 8083:8081 \
    -e PDNS_ALLOW_AXFR_IPS="${PDNS_ALLOW_AXFR_IPS}"  \
    -e PDNS_DOMAIN="$PDNS_DOMAIN" \
    -e PDNS_ALLOW_RECURSION="0.0.0.0\/0" \
    -e PDNS_AUTH_MASTER_IP=${PDNS_AUTH_MASTER_IP} \
    -e PDNS_AUTH_SLAVE_IP=${PDNS_AUTH_SLAVE_IP} \
    -e PDNS_AUTH_MASTER=yes \
    -e PDNS_AUTH_SLAVE=no \
    -e PDNS_WEBSERVER_PASSWORD="$PDNS_WEBSERVER_PASSWORD" \
    -e PDNS_API_KEY=${PDNS_API_KEY}  \
    -e PDNS_DISTRIBUTOR_THREADS=3 \
    -e PDNS_CACHE_TTL=20 \
    -e PDNS_RECURSIVE_CACHE_TTL=10 \
    -e MYSQL_HOST=pdns_db \
    -e MYSQL_PORT=3306 \
    -e MYSQL_USER=root \
    -e MYSQL_ROOT_PASSWORD="$MYSQL_ROOT_PASSWORD" \
    -e MYSQL_DB=pdns \
    --network $PDNS_NETWORK \
    $CONSTRAINTS \
    hernad/pdns
