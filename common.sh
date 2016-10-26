
PDNS_DOMAIN="example.org"
PDNS_NETWORK="infra_net"

#PDNS_MASTER_IP="159.203.144.119"
#LABEL_PDNS_MASTER="out.ba.infra-1"


#PDNS_SLAVE_IP="37.139.4.121"
#LABEL_PDNS_SLAVE="out.ba.infra-2"
#PDNS_SLAVE_FQDN="ns2.cloud.out.ba"


PDNS_ALLOW_AXFR_IPS="10.0.2.0\/24"

PDNS_MASTER_IP="10.0.2.4"
LABEL_PDNS_MASTER="out.ba.infra-1"

PDNS_SLAVE_IP="10.0.2.8"
LABEL_PDNS_SLAVE="out.ba.infra-2"

PDNS_SLAVE_FQDN="ns2.$PDNS_DOMAIN"

PDNS_WEBSERVER_PASSWORD="test01"
MYSQL_ROOT_PASSWORD="test01"

PDNS_RECURSOR_ALLOW="10.0.0.0/8,172.16.0.0/12,192.168.0.0/16"
PDNS_RECURSOR_ALLOW+=",92.36.155.3" ## adsl.out.ba
