#!/bin/bash

. common.sh

docker service rm pdns-recursor

echo "=== MASTER PDNS ===="

#docker volume rm pdns_mysql_data
#docker volume create --name pdns_mysql_data

echo "$CONSTRAINT"

echo pdns
docker service create --name pdns-recursor \
    --replicas 2 \
    -p 53:53/udp \
    -p 8080:80 \
    -p 8081:8081 \
    -e PDNS_DOMAIN="$PDNS_DOMAIN" \
    -e PDNS_WEBSERVER_PASSWORD="$PDNS_WEBSERVER_PASSWORD" \
    -e PDNS_API_KEY=secretkey01 \
    -e PDNS_RECURSOR_ALLOW=${PDNS_RECURSOR_ALLOW} \
    --network $PDNS_NETWORK \
    $CONSTRAINT \
    hernad/pdns-recursor
