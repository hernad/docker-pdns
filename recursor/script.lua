-- Provide a function to translate the query type to to a cleartext string.
-- If the query type is unknown, its numeric value is returned as string.
-- The query types have been copy/pasted from pdns/qtype.hh with regex replacements
-- and sorting.

do 
   local qtt = {
      [1]     = "A",
      [38]    = "A6",
      [28]    = "AAAA",
      [65400] = "ADDR",
      [18]    = "AFSDB",
      [65401] = "ALIAS",
      [255]   = "ANY",
      [252]   = "AXFR",
      [257]   = "CAA",
      [60]    = "CDNSKEY",
      [59]    = "CDS",
      [37]    = "CERT",
      [5]     = "CNAME",
      [49]    = "DHCID",
      [32769] = "DLV",
      [39]    = "DNAME",
      [48]    = "DNSKEY",
      [43]    = "DS",
      [108]   = "EUI48",
      [109]   = "EUI64",
      [13]    = "HINFO",
      [45]    = "IPSECKEY",
      [251]   = "IXFR",
      [25]    = "KEY",
      [36]    = "KX",
      [29]    = "LOC",
      [254]   = "MAILA",
      [253]   = "MAILB",
      [14]    = "MINFO",
      [9]     = "MR",
      [15]    = "MX",
      [35]    = "NAPTR",
      [2]     = "NS",
      [47]    = "NSEC",
      [50]    = "NSEC3",
      [51]    = "NSEC3PARAM",
      [61]    = "OPENPGPKEY",
      [41]    = "OPT",
      [12]    = "PTR",
      [57]    = "RKEY",
      [17]    = "RP",
      [46]    = "RRSIG",
      [24]    = "SIG",
      [6]     = "SOA",
      [99]    = "SPF",
      [33]    = "SRV",
      [44]    = "SSHFP",
      [249]   = "TKEY",
      [52]    = "TLSA",
      [250]   = "TSIG",
      [16]    = "TXT",
      [256]   = "URI",
      [11]    = "WKS"  }

   function translateQtype ( qtype ) 
      local str = qtt[qtype]
      if str then
         return str
      else 
         return tostring(qtype)
      end
   end

   -- example: print ( translateQtype( 161 ) ) --> "161"
   --          print ( translateQtype( 249 ) ) --> "TKEY"

end

-- "preresolve" is called by pdns-resolver. 
-- The parameter list is the old style one (prior to version. 3.1.7)
-- for newer versions, use preresolve ( requestorip, acceptorip, domain, qtype )
-- Look in the system logfile for the logging text.

function preresolve ( requestorip, domain, qtype )

        pdnslog ("preresolve() called by " .. tostring(requestorip) .. " for domain=" .. tostring(domain) .. ", type=" .. translateQtype(qtype) )

        if domain == "mymachine.homelinux.org." and qtype == pdns.A
        then
            return 0,  { {qtype=pdns.A, content="192.168.0.10"} }
        else
            return -1, {}
        end
end
