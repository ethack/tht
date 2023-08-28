# Challenge 1

Extract source IP addresses from SSL and HTTP logs. These are IP addresses making HTTP and SSL/TLS requests web servers.

Answer the following questions:
- How many IPs made both types of connections?
- How many IPs made only SSL connections but no HTTP connections?
- How many IPs made only HTTP connections but no SSL connections?

<!-- tabs:start -->

### **⚠️ Spoilers**

You can view _hints_ :question: and the **final solution** :exclamation: by selecting a tab.

#### **:question: Suggested tools **

- `[[filter]]`
- `[[chop]]`
- `ipintersect` / `ipdiff` / `zet`

#### **:question: Log fields to consider**

Most Zeek logs contain an [`id` struct](https://docs.zeek.org/en/master/scripts/base/init-bare.zeek.html#type-conn_id) which has the source (`id.orig_h`) and destination (`id.resp_h`) IP addresses along with the source (`id.orig_p`) and destination (`id.resp_p`) ports.

The Zeek [`conn`](https://docs.zeek.org/en/master/logs/conn.html) log will show all connections observed. SSL servers typically use TCP port 443 and HTTP servers typically use TCP port 80. The `conn` log contains a `service` field that indicates if Zeek detected a certain protocol for that connection. When certain protocols are detected, Zeek will also generate one (or more) entries in a log specific for that protocol. For example, [`http`](https://docs.zeek.org/en/master/logs/http.html) or [`ssl`](https://docs.zeek.org/en/master/logs/ssl.html).

> [!TIP]
> When a single connection generates multiple log events, possibly spanning multiple files, Zeek uses the same value for the `uid` field to indicate the events are all related to the same connection. You can use this file to pivot between logs.

Log file field refences:
- https://docs.zeek.org/en/master/scripts/base/protocols/conn/main.zeek.html#type-Conn::Info
- https://docs.zeek.org/en/master/scripts/base/protocols/http/main.zeek.html#type-HTTP::Info
- https://docs.zeek.org/en/master/scripts/base/protocols/ssl/main.zeek.html#type-SSL::Info
- https://docs.zeek.org/en/master/scripting/basics.html#writing-scripts-connection-record

#### **:question: Extracting IPs**

```bash
filter --http | chop id.orig_h | distinct >http-ips.txt
filter --ssl | chop id.orig_h | distinct >ssl-ips.txt
```

> [!TIP]
> The `distinct` in the above commands is optional but will remove duplicates from your lists.

#### **:question: Finding items in common**

When dealing with IP addresses in particular, the `ipcount`, `ipdiff`, `ipdiffs`, `ipintersect`, and `ipunion` tools can be used. These work with both IP ranges and individual addesses. You may also find them to be faster for very large lists.

```bash
ipintersect http-ips.txt ssl-ips.txt
```

> [!TIP]
> When you have long lists of IP addresses, the `ip2cidr` script can condense the output by combining runs of consecutive IP addresses into IP address range CIDR notation.

You can also use `zet` for lists of IP addresses, as well as for generic lists of things (e.g. domains, hashes, user-agents, names, fruits, etc.)

```bash
zet intersect http-ips.txt ssl-ips.txt
```
#### **:question: Finding differences**

This is called the _set difference_ or the _complement_ in [[Set Theory]]. Look at the following tools:
- `ipdiff`
- `zet diff`
</details>

#### **:exclamation: Solution**

Read through the hints to understand the solution.

```bash
# Extract source IPs from HTTP log
filter --http | chop id.orig_h | distinct >http-ips.txt
# Extract source IPs from SSL log
filter --ssl | chop id.orig_h | distinct >ssl-ips.txt

# Find IPs from both logs
ipintersect http-ips.txt ssl-ips.txt | count

# Find IPs only in the HTTP log
ipdiff http-ips.txt ssl-ips.txt | count

# Find IPs only in the SSL log
ipdiff ssl-ips.txt http-ips.txt | count
```

> [!ATTENTION]
> For an advanced challenge, use `zq` to convert the logs to JSON and use `duckdb` to solve the challenge using SQL.

<!-- tabs:end -->

# Challenge 2

Find _internal_ ([RFC 1918](https://datatracker.ietf.org/doc/html/rfc1918#section-3)) web servers.

Answer the following questions:

- Which servers are listening on both ports 443 and 80?
- Which servers are listening on only port 80?
- Which servers are listening on only port 443?
- Which servers are listening on only a port other than 80 or 443?

# Challenge 3

Now do the same for _external_ web servers.
