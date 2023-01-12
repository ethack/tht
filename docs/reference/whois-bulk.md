
`whois-bulk` uses [Team Cymru's service](https://team-cymru.com/community-services/ip-asn-mapping/).

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
$ cat ips.txt| whois-bulk | tvt
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
