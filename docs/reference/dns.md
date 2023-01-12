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


