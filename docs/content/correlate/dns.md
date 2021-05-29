---
title: "Dns"
date: 2021-05-10T08:53:11-05:00
draft: true
---

When you're trying to turn internal IP addresses into hostnames you can use these tools to query a local DNS server. These will need to be run on their network. 

dig -x ipaddress 

Windows:
nslookup ipaddress 

Powershell script to do bulk lookups: 
https://gist.github.com/PrateekKumarSingh/586f2d3d43f7e8cb07ce  
https://geekeefy.wordpress.com/2015/10/24/powershell-resolve-dns-hostname-to-ip-and-reverse-using-a-single-function/ 

https://gist.github.com/ethack/8fe44b9ccc7790e47eb738e86047b95a  


## Cymru Whois

```bash
cat BadIP.txt                                                       
1.1.1.1 
8.8.8.8 
1.0.0.1 
208.67.222.222 
```

```
netcat whois.cymru.com 43 < BadIP.txt 
AS      | IP               | AS Name 
13335   | 1.1.1.1          | CLOUDFLARENET, US 
AS      | IP               | AS Name 
15169   | 8.8.8.8          | GOOGLE, US 
AS      | IP               | AS Name 
13335   | 1.0.0.1          | CLOUDFLARENET, US 
AS      | IP               | AS Name 
36692   | 208.67.222.222   | OPENDNS, US 
```

```
$ (echo asn,dst,org; (echo begin; echo noasnumber noheader; cat uncommon_dst.csv | grep -v dst | cut -d',' -f1; echo end) | netcat whois.cymru.com 43 | grep -v whois | sed -e 's/,//g' -e 's/\s*|\s*/,/g')
```

https://team-cymru.com/community-services/ip-asn-mapping/ 