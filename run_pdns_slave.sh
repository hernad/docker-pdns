#!/bin/bash

. common.sh
echo ======= PDNS SLAVE ===========


docker service rm pdns_slave
docker service rm pdns_slave_db



#docker volume rm pdns_slave_mysql_data
#docker volume create --name pdns_slave_mysql_data

echo pdns_db
#https://docs.docker.com/swarm/scheduler/filter/

CONSTRAINT="--constraint node.labels.role==${LABEL_PDNS_SLAVE}"
CONSTRAINT+=" --constraint engine.labels.provider==digitalocean "


docker service create --name  pdns_slave_db \
    --replicas 1 \
    --mount type=volume,source=pdns_slave_mysql_data,destination=/var/lib/mysql \
    -e MYSQL_ROOT_PASSWORD=test01 \
    --network infra-back \
    $CONSTRAINTS \
    mysql


#-e PDNS_ALLOW_AXFR_IPS="${PDNS_MASTER_IP}\/32"  \

echo pdns
docker service create --name pdns_slave \
    --replicas 1 \
    -p 532:53/udp \
    -p 8082:80 \
    -p 8083:8081 \
    -e PDNS_ALLOW_RECURSION="0.0.0.0\/0" \
    -e PDNS_ALLOW_AXFR_IPS="${PDNS_MASTER_IP}"  \
    -e PDNS_MASTER=no \
    -e PDNS_SLAVE=yes \
    -e PDNS_WEBSERVER_PASSWORD=test01 \
    -e PDNS_API_KEY=secretkey01 \
    -e PDNS_DISTRIBUTOR_THREADS=3 \
    -e PDNS_CACHE_TTL=20 \
    -e PDNS_RECURSIVE_CACHE_TTL=10 \
    -e MYSQL_HOST=pdns_slave_db \
    -e MYSQL_PORT=3306 \
    -e MYSQL_USER=root \
    -e MYSQL_ROOT_PASSWORD=test01 \
    -e MYSQL_DB=pdns_slave \
    -e PDNS_MASTER_IP="${PDNS_MASTER_IP}" \
    -e PDNS_SLAVE_FQDN="${PDNS_SLAVE_FQDN}" \
    --network infra-back \
    $CONSTRAINTS \
    hernad/pdns
