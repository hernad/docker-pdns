#!/bin/bash

API_KEY=secretkey01
DOMAIN="test.pdns"
URL="http://127.0.0.1:8081/api/v1/servers/localhost/zones/${DOMAIN}."
#URL2="http://127.0.0.1:8081/api/v1/servers/localhost/zones"

curl -s -w "\n\n%{http_code}\n" -X PATCH --data '{"rrsets": [{
  "name": "api.test.pdns.",
  "type": "A",
  "ttl": 600,
  "changetype": "REPLACE",
  "records": [ {
    "name": "api.test.pdns.",
    "content": "10.10.10.12",
    "disabled": false
  }]
}]}' -H "X-API-Key: $API_KEY" $URL



curl -s -H "X-API-Key: $API_KEY" -X GET \
    $URL | jq .

