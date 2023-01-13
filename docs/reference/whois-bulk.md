
`whois-bulk` uses [Team Cymru's service](https://www.team-cymru.com/ip-asn-mapping).

> [!WARNING]
> IPs that are seen abusing the whois server with large numbers of individual queries [...] will be null routed.

This tool and service should be fine to use for ad hoc manual queries. But if you attempt any form of automation, be sure to reference the link above to learn about acceptable use and the preferred DNS method for automation.

## Example

```bash
cat ips.txt                                                       
8.8.8.8
8.8.4.4
1.1.1.1
1.0.0.1
208.67.222.222
208.67.220.220
```

```
$ cat ips.txt | whois-bulk | tvt
+-------+----------------+------------------+
|  asn  |       ip       |       org        |
+-------+----------------+------------------+
| 15169 | 8.8.8.8        | GOOGLE US        |
| 15169 | 8.8.4.4        | GOOGLE US        |
| 13335 | 1.1.1.1        | CLOUDFLARENET US |
| 13335 | 1.0.0.1        | CLOUDFLARENET US |
| 36692 | 208.67.222.222 | OPENDNS US       |
| 36692 | 208.67.220.220 | OPENDNS US       |
+-------+----------------+------------------+
```
