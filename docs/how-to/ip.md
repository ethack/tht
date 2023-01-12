---
title: "Working with IP Addresses"
date: 2021-03-29T22:41:20-05:00
draft: true
---

Tools
- ipset
- grepcidr
- ipcalc
- cidr2regex (python script or perl script)
  - https://github.com/dameyerdave/cidr2regex
  - https://github.com/bAndie91/cidr2regex

TODO performance comparison of grepcidr to ipset with Microsoft IP space

- Include files with IP address ranges defined in different RFCs (e.g. RFC1918, IPv6, link-local, carrier-nat, etc)

Wrapper script that takes these IP address files and does things. Like auto-converts IPSets.

# `grepcidr`

ips1.txt
ips2.txt
ips3.txt

grepcidr ips1.txt ips2.txt - intersection of ips1.txt and ips2.txt
grepcidr ips1.txt ips2.txt ips3.txt - intersection of ips1.txt and (union of ips2.txt and ips3.txt)?
grepcidr -v ips1.txt ips2.txt - difference of ips2.txt and ips1.txt
grepcidr ips1.txt ips2.txt ips3.txt - difference of (union of ips2.txt and ips3.txt) and ips1.txt?

Grepcidr doesn't work the other way :( Meaning you can't have ranges in the search text.

```
$ cat whitelist.json | jq | grep 104.42.0.0      
    "name": "Public: 104.42.0.0/16",
$ cat whitelist.json | jq | grepcidr 104.42.43.44
$ cat whitelist.json | jq | grepcidr 104.42.0.0  
    "name": "Public: 104.42.0.0/16",
```

grepcidr -v has interesting behavior. It seems that it will exclude lines if they don't have any IPs at all.

```
$ cat test.txt
#comment
1.1.1.1
2.2.2.2
$ grepcidr 1.1.1.1 test.txt
1.1.1.1
$ grepcidr -v 1.1.1.1 test.txt
2.2.2.2

```

Use cases:
I have Zeek logs.
I want to exclude all logs that originate from outside the customer network. The customer has both RFC1918 and public routable IPs.
Grepcidr should work.

I have a list of external IPs that I'm interested in investigating.
I want to exclude all customer public routable IPs.
Grepcidr should work.

I have a list of external IPs that I'm interested in investigating.
I want to segregate this list based on other lists I have that contain Microsoft IP ranges, Cloudflare, Google, Amazon, and other major CDN or cloud provider.
SiLK IPSet should work.

# IPSet

TODO print help text on no arguments or with --help

```
ipcount
ipcidr
ipintersect
ipunion
ipdiff
ipdiffs
```

```
$ rwsetmember --help
rwsetmember [SWITCHES] WILDCARD_IP INPUT_SET [INPUT_SET...]
	Determine existence of IP address(es) in one or more IPset files.
	By default, print names of INPUT_SETs that contain WILDCARD_IP.
```
