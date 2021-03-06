#!/bin/bash

. common.sh
echo ======= PDNS SLAVE ===========


docker service rm pdns_slave
docker service rm pdns_slave_db



#docker volume rm pdns_slave_mysql_data
#docker volume create --name pdns_slave_mysql_data

#https://docs.docker.com/swarm/scheduler/filter/

CONSTRAINTS="--constraint node.labels.role==${LABEL_PDNS_AUTH_SLAVE}"
#CONSTRAINTS+=" --constraint engine.labels.provider==digitalocean "


docker service create --name  pdns_slave_db \
    --replicas 1 \
    --mount type=volume,source=pdns_slave_mysql_data,destination=/var/lib/mysql \
    -e MYSQL_ROOT_PASSWORD="$MYSQL_ROOT_PASSWORD" \
    $CONSTRAINTS \
    --network $PDNS_NETWORK \
    mysql


echo pdns
docker service create --name pdns_slave \
    --replicas 1 \
    -p 532:53/udp \
    -p 8084:80 \
    -p 8085:8081 \
    -e PDNS_ALLOW_RECURSION="0.0.0.0\/0" \
    -e PDNS_ALLOW_AXFR_IPS="${PDNS_ALLOW_AXFR_IPS}"  \
    -e PDNS_DOMAIN="$PDNS_DOMAIN" \
    -e PDNS_AUTH_MASTER_IP=${PDNS_AUTH_MASTER_IP} \
    -e PDNS_AUTH_SLAVE_IP=${PDNS_AUTH_SLAVE_IP} \
    -e PDNS_AUTH_MASTER=no \
    -e PDNS_AUTH_SLAVE=yes \
    -e PDNS_WEBSERVER_PASSWORD="$PDNS_WEBSERVER_PASSWORD" \
    -e PDNS_API_KEY=${PDNS_API_KEY} \
    -e PDNS_DISTRIBUTOR_THREADS=3 \
    -e PDNS_CACHE_TTL=20 \
    -e PDNS_RECURSIVE_CACHE_TTL=10 \
    -e MYSQL_HOST=pdns_slave_db \
    -e MYSQL_PORT=3306 \
    -e MYSQL_USER=root \
    -e MYSQL_ROOT_PASSWORD="$MYSQL_ROOT_PASSWORD" \
    -e MYSQL_DB=pdns_slave \
    -e PDNS_AUTH_MASTER_IP="${PDNS_AUTH_MASTER_IP}" \
    -e PDNS_AUTH_SLAVE_FQDN="${PDNS_AUTH_SLAVE_FQDN}" \
    --network $PDNS_NETWORK \
    $CONSTRAINTS \
    hernad/pdns
