#!/bin/bash

. common.sh

echo PDNS_NETWORK: $PDNS_NETWORK

docker network create \
  --driver overlay \
  --subnet 10.0.9.0/24 \
  $PDNS_NETWORK
