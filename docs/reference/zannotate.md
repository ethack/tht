---
title: "Zannotate"
date: 2021-03-29T22:40:15-05:00
draft: true
---


Zannotate is a nifty command line tool that adds GeoIP or ASN info to IP addresses. Think what Logstash or AC-Hunter can do but on-demand, ad hoc, and from the command line.
You can install it (after having Go) with `go get github.com/zmap/zannotate/cmd/zannotate`
Then you feed it a list of IP addresses and it spits out a JSON file. Example of feeding responder IP addresses from Zeek log.

```bash
rg -zI -e '^#' -e '\tT\tF\t' /opt/zeek/logs/conn* | bro-cut id.resp_h | sort -V | uniq | ./zannotate --geoip2-database GeoLite2-Country_20201110/GeoLite2-Country.mmdb --geoip2 --geoip2-fields country > geo-2020-11-12.json
```

Then you have a JSON file you can process or query as you see fit. Example of pulling out all IP addresses from a given country.

```bash
cat geo-2020-11-12.json| jq -cr 'select(.geoip2.country.name == "Ukraine")' | jq -cr '.ip'
31.28.161.68
91.236.251.5
192.102.6.38
192.102.6.72
```