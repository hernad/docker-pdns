#!/bin/bash

API_KEY=key01
URL="http://127.0.0.1:8081/api/v1/servers/localhost/zones/out.ba."
URL2="http://127.0.0.1:8081/api/v1/servers/localhost/zones"

curl -s -w "\n\n%{http_code}\n" -X PATCH --data '{"rrsets": [{
  "name": "api.out.ba.",
  "type": "A",
  "ttl": 600,
  "changetype": "REPLACE",
  "records": [ {
    "name": "api.out.ba.",
    "content": "10.10.10.12",
    "disabled": false
  }]
}]}' -H "X-API-Key: $API_KEY" $URL



curl -s -H "X-API-Key: $API_KEY" -X GET \
    $URL2 | jq .

