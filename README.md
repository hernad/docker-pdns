PowerDNS Authoritative server and Poweradmin
===========
[![](https://badge.imagelayers.io/secns/pdns:latest.svg)](https://imagelayers.io/?images=secns/pdns:latest 'Get your own badge on imagelayers.io')

# Quickstart

```wget https://raw.githubusercontent.com/obi12341/docker-pdns/master/docker-compose.yml && docker-compose up -d```

# Running

Just use this command to start the container. PowerDNS will listen on port 53/tcp, 53/udp and 8080/tcp.

```docker run --name pdns-master --link mysql:db -d -p 53:53/udp -p 53:53 -p 8080:80 secns/pdns:4.0.3```

Login:
``` admin / admin ```

# Webserver REST

```curl -H 'X-API-Key: powerdns101' http://127.0.0.1:8081/api/v1/servers | jq .```


```docker-pdns $ curl --silent -H 'X-API-Key: secretkey01' http://127.0.0.1:8081/api/v1/servers/localhost/zones | jq .
[
  {
    "account": "",
    "dnssec": false,
    "id": "out.ba.",
    "kind": "Master",
    "last_check": 0,
    "masters": [],
    "name": "out.ba.",
    "notified_serial": 7200,
    "serial": 0,
    "url": "api/v1/servers/localhost/zones/out.ba."
  }
]```

# Configuration
These options can be set:

- **PDNS_ALLOW_AXFR_IPS**: restrict zonetransfers to originate from these IP addresses. Enter your slave IPs here. (Default: "127.0.0.1", Possible Values: "IPs comma seperated")
- **PDNS_MASTER**: act as master (Default: "yes", Possible Values: "yes, no")
- **PDNS_SLAVE**: act as slave (Default: "no", Possible Values: "yes, no")
- **PDNS_CACHE_TTL**: Seconds to store packets in the PacketCache (Default: "20", Possible Values: "<integer>")
- **PDNS_DISTRIBUTOR_THREADS**: Default number of Distributor (backend) threads to start (Default: "3", Possible Values: "<integer>")
- **PDNS_RECURSIVE_CACHE_TTL**: Seconds to store packets in the PacketCache (Default: "10", Possible Values: "<integer>")
- **PDNS_RECURSOR**: If recursion is desired, IP address of a recursing nameserver (Default: "no", Possible Values: "yes, no")
- **PDNS_ALLOW_RECURSION**: List of subnets that are allowed to recurse (Default: "127.0.0.1", Possible Values: "<ipaddr>")
- **POWERADMIN_HOSTMASTER**: default hostmaster (Default: "", Possible Values: "<email>")
- **POWERADMIN_NS1**: default Nameserver 1 (Default: "", Possible Values: "<domain>")
- **POWERADMIN_NS2**: default Nameserver 2 (Default: "", Possible Values: "<domain>")



# docker exec -ti dockerpdns_pdns_1 bash 

```
root@6688f910197e:/# pdnsutil create-zone test.pdns ns1.test.pdns    
Creating empty zone 'test.pdns.'
Also adding one NS record
root@6688f910197e:/# pdnsutil add-record test.pdns ns1 A 192.168.1.2  
New rrset:
ns1.test.pdns. IN A 3600 192.168.1.2
root@6688f910197e:/# pdnsutil list-zone test.pdns
ns1.test.pdns.	3600	IN	A	192.168.1.2
test.pdns.	3600	IN	NS	ns1.test.pdns.
test.pdns.	3600	IN	SOA	ns1.test.pdns podrska.bring.out.ba 1 10800 3600 604800 3600
root@6688f910197e:/# pdnsutil edit-zone test.pdns

; Warning - every name in this file is ABSOLUTE!
$ORIGIN .
ns1.test.pdns.  3600    IN      A       192.168.1.2
test.pdns.      3600    IN      NS      ns1.test.pdns
test.pdns.      3600    IN      SOA     ns1.test.pdns podrska.bring.out.ba 1 10800 3600 604800 3600
```

# REST


```
docker-pdns $ curl --silent -H 'X-API-Key: secretkey01' http://localhost:8081/api/v1/servers/localhost/zones/test.pdns. | jq .
{
  "account": "",
  "dnssec": false,
  "id": "test.pdns.",
  "kind": "Native",
  "last_check": 0,
  "masters": [],
  "name": "test.pdns.",
  "notified_serial": 0,
  "rrsets": [
    {
      "comments": [],
      "name": "ns1.test.pdns.",
      "records": [
        {
          "content": "192.168.1.2",
          "disabled": false
        }
      ],
      "ttl": 3600,
      "type": "A"
    },
    {
      "comments": [],
      "name": "test.pdns.",
      "records": [
        {
          "content": "ns1.test.pdns. podrska.bring.out.ba. 1 10800 3600 604800 3600",
          "disabled": false
        }
      ],
      "ttl": 3600,
      "type": "SOA"
    },
    {
      "comments": [],
      "name": "test.pdns.",
      "records": [
        {
          "content": "ns1.test.pdns.",
          "disabled": false
        }
      ],
      "ttl": 3600,
      "type": "NS"
    }
  ],
  "serial": 1,
  "soa_edit": "",
  "soa_edit_api": "",
  "url": "api/v1/servers/localhost/zones/test.pdns."
}
```
