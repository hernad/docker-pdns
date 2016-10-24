#!/bin/bash

. common.sh

docker service rm pdns
docker service rm pdns_db

echo "=== MASTER PDNS ===="

#docker volume rm pdns_mysql_data
#docker volume create --name pdns_mysql_data

CONSTRAINT="--constraint node.labels.role==${LABEL_PDNS_MASTER}"
CONSTRAINT+=" --constraint engine.labels.provider==digitalocean "



echo "$CONSTRAINT"

echo pdns_db


CMD="docker service create --name  pdns_db"
CMD+=" --replicas 1"
CMD+=" $CONSTRAINT"
CMD+=" --mount type=volume,source=pdns_mysql_data,destination=/var/lib/mysql"
CMD+=" -e MYSQL_ROOT_PASSWORD=test01"
CMD+=" --network infra-back"
CMD+=" mysql"

echo $CMD
$CMD
echo ===================


#-e PDNS_ALLOW_AXFR_IPS="${PDNS_SLAVE_IP}\/32"  \

echo pdns
docker service create --name pdns \
    --replicas 1 \
    -p 531:53/udp \
    -p 8080:80 \
    -p 8081:8081 \
    -e PDNS_ALLOW_AXFR_IPS="${PDNS_SLAVE_IP}"  \
    -e PDNS_ALLOW_RECURSION="0.0.0.0\/0" \
    -e PDNS_MASTER=yes \
    -e PDNS_SLAVE=no \
    -e PDNS_WEBSERVER_PASSWORD=test01 \
    -e PDNS_API_KEY=secretkey01 \
    -e PDNS_DISTRIBUTOR_THREADS=3 \
    -e PDNS_CACHE_TTL=20 \
    -e PDNS_RECURSIVE_CACHE_TTL=10 \
    -e MYSQL_HOST=pdns_db \
    -e MYSQL_PORT=3306 \
    -e MYSQL_USER=root \
    -e MYSQL_ROOT_PASSWORD=test01 \
    -e MYSQL_DB=pdns \
    --network infra-back \
    $CONSTRAINT \
    hernad/pdns
