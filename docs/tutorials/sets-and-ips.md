
# IP Addresses and Set Logic

Use [Zeek](https://zeek.org/) logs to solve these challenges.

## Challenge 1

Extract source IP addresses from SSL and HTTP. These are IP addresses making HTTP and SSL/TLS requests to web servers.

Answer the following questions:
- How many IPs made both types of connections?
- How many IPs made only HTTP connections but no SSL connections?
- How many IPs made only SSL connections but no HTTP connections?

<!-- tabs:start -->

### **:warning: No spoilers**

You can view _hints_ :question: with relevant background and direction and **solutions** :exclamation: where a command is given by selecting a tab.

#### **:question: _Suggested tools_**

- [`filter`](reference/filter)
- [`chop`](reference/chop)
- `ipintersect` / `ipdiff` / `zet`

#### **:question: _Log fields to consider_**

Most Zeek logs contain an [`id` struct](https://docs.zeek.org/en/master/scripts/base/init-bare.zeek.html#type-conn_id) which has the source (`id.orig_h`) and destination (`id.resp_h`) IP addresses along with the source (`id.orig_p`) and destination (`id.resp_p`) ports.

> [!NOTE]
> `orig` refers to the _originator_ and `resp` refers to the _responder_. `_h` is the first letter in _host_ and `_p` is first letter in _port_. I.e. `id.orig_h` is the originating host, or source IP address of the connection.

The Zeek [`conn`](https://docs.zeek.org/en/master/logs/conn.html) log will show all connections observed. SSL servers typically use TCP port 443 and HTTP servers typically use TCP port 80. The `conn` log contains a `service` field that indicates if Zeek detected a certain protocol for that connection. When certain protocols are detected, Zeek will also generate one (or more) entries in a log specific for that protocol. For example, [`http`](https://docs.zeek.org/en/master/logs/http.html) or [`ssl`](https://docs.zeek.org/en/master/logs/ssl.html).

> [!TIP]
> When a single connection generates multiple log events, possibly spanning multiple files, Zeek uses the same value for the `uid` field to indicate the events are all related to the same connection. You can use this file to pivot between logs.

Log file field refences:
- https://docs.zeek.org/en/master/scripts/base/protocols/conn/main.zeek.html#type-Conn::Info
- https://docs.zeek.org/en/master/scripts/base/protocols/http/main.zeek.html#type-HTTP::Info
- https://docs.zeek.org/en/master/scripts/base/protocols/ssl/main.zeek.html#type-SSL::Info
- https://docs.zeek.org/en/master/scripting/basics.html#writing-scripts-connection-record

#### **:exclamation: __Extracting IPs__**

```bash
filter --http | chop id.orig_h | distinct >http-ips.txt
filter --ssl | chop id.orig_h | distinct >ssl-ips.txt
```

> [!TIP]
> The `distinct` in the above commands is optional but will remove duplicates from your lists.

#### **:exclamation: __Find items in common__**

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

#### **:question: _Find differences_**

This is called the _set difference_ or the _complement_ in [[Set Theory]]. Look at the following tools:
- `ipdiff`
- `zet diff`

#### **:exclamation: __Final Solution__**

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

<!-- tabs:end -->

## Challenge 2

Find web servers hosted on _internal_ ([RFC 1918](https://datatracker.ietf.org/doc/html/rfc1918#section-3)) IP addresses.

Answer the following questions:

- Which servers are listening on both ports 443 and 80?
- Which servers are listening on only port 80?
- Which servers are listening on only port 443?
- Which servers are listening on only a port other than 80 or 443?

<!-- tabs:start -->

### **:warning: No spoilers**

You can view _hints_ :question: with relevant background and direction and **solutions** :exclamation: where a command is given by selecting a tab.

#### **:question: _Suggested tools_**

- [`filter`](reference/filter)
- [`zq`](https://zed.brimdata.io/docs/next)
- [`chop`](reference/chop)
- `ipintersect` / `ipdiff` / `zet`

#### **:question: _Log fields to consider_**

See Challenge 1 hint. Pay attention to the `id.resp_p` field in the `ssl` and `http` logs.

The `conn` log has `local_orig` and `local_resp` fields which can tell you if the originator and responder were local IP addresses or not. 

> [!NOTE] 
> The defintion of Zeek local vs RFC 1918 internal is [nuanced](https://docs.zeek.org/en/master/quickstart.html#local-site-customization). For our purposes we'll consider the `local_orig` and `local_resp` fields indicate RFC 1918 IP addresses since this is the default configuration for most Zeek installs.

The `conn` log has a `service` field which tells if a particular service was detected for that connection. Use values of `http` and `ssl` to identify web servers.

> [!NOTE]
> The `ssl` service can mean any SSL/TLS wrapped protocol, not just an HTTP web server. For our purposes, looking for `ssl` is good enough.

The `conn` log has `local_orig` and `local_resp` fields which can tell you if the originator and responder were local IP addresses or not. The defintion of local vs internal is [nuanced](https://docs.zeek.org/en/master/quickstart.html#local-site-customization) but for our purposes (and the default settings) we'll consider the `local_orig` and `local_resp` fields to be indicators of RFC 1918 IP addresses.

> [!ATTENTION]
> This challenge, in particular, has multiple ways to solve it. Zeek's `conn` and `http`/`ssl` logs each have the information needed. Think about what fields might make it easier or harder to solve and fields that might be useful for further analysis later on.

#### **:exclamation: __Finding internal IPs__**

We can use `filter` and `chop`. The `-p` flag in `filter` has a regex preset for RFC 1918 addresses. Keep in mind that `filter` searches an entire line. So in order to be sure that the server is the internal IP address we'll have to first remote the source address. In these commands we are also keeping the server port and hostname from the `ssl` and `http` logs.

```bash
# Find internal SSL servers
filter --ssl | chop id.resp_h id.resp_p server_name | filter -p rfc1918 | distinct >internal-ssl-servers.tsv

# Find internal HTTP servers
filter --http | chop id.resp_h id.resp_p host | filter -p rfc1918 | distinct >internal-http-servers.tsv
```

We can use a similar technique to pul the information from the `conn` logs. However, the web server's hostname will not be available.

```bash
# Find internal SSL servers from the conn log
filter --conn ssl | chop id.resp_h id.resp_p | filter -p rfc1918 | distinct

# Find internal HTTP servers from the conn log
filter --conn http | chop id.resp_h id.resp_p | filter -p rfc1918 | distinct
```

Another solution involves using `zq`, which can natively understand both Zeek's TSV and JSON formats. In this example, we can keep the entire log line.

```bash
zq -f zeek 'local_resp == true and service in ["http", "ssl"]' conn.*.log* >conn-internal-web-servers.log
```

> [!NOTE]
> If you don't get expected results using `zq`, try this form. This has to do with the way `zq` applies datatypes to Zeek fields and can differ between TSV and JSON logs. Applying this [shaper](https://github.com/brimdata/zed/blob/main/docs/integrations/zeek/shaping-zeek-ndjson.md) file helps normalize the differences.
> `zq -f zeek -I /root/.config/zq/shaper.zed '| local_resp == true and service in ["http", "ssl"]' conn.*.log* >conn-internal-web-servers.log`

#### **:question: _Find items in common_**

See Challenge 1 hint. Keep in mind that in order to use the set tools, you'll need lists of bare IPs with no other information on the line.

#### **:exclamation: __Final Solution__**

```bash
# Find internal HTTP servers on port 80
filter --http 80 | chop id.resp_h id.resp_p | filter -p rfc1918 80 | chop 1 | distinct >internal-http-80-servers.txt

# Find internal SSL servers on port 443
filter --ssl 443 | chop id.resp_h id.resp_p | filter -p rfc1918 443 | chop 1 | distinct >internal-ssl-443-servers.txt

# Find servers listening on both both ports 80 and 443
zet intersect internal-http-80-servers.txt internal-ssl-443-servers.txt

# Find servers listening only on port 80
zet diff internal-http-80-servers.txt internal-ssl-443-servers.txt

# Find servers listening only on port 443
zet diff internal-ssl-443-servers.txt internal-http-80-servers.txt
```

This solution doesn't give us the hostnames for the servers. Think about how you might have done it differently to include hostnames as well.

```bash
# Find internal HTTP and SSL servers
zq -f text 'local_resp == true and service in ["http", "ssl"] and id.resp_p != 80 and id.resp_p != 443 | cut id.resp_h | sort | uniq' conn.*.log* >internal-web-servers-nonstandard-port.txt

# Find servers listening only on a port other than 80 or 443
zet diff internal-web-servers-nonstandard-port.txt internal-http-80-servers.txt internal-ssl-443-servers.txt
```

> [!TIP] 
> If you don't get any results and aren't sure if it's because there are not or if your commands are working, try inverting your condition (e.g. instead of `not in` use `in` or instead of `>` use `<=`) or removing the condition altogether. If you get results then, chances are your commands are working and you just have no results to show.

<!-- tabs:end -->

## Challenge 3

Repeat Challenge 2 for _external_ web servers. 

Chances are good that a C2 server is not listening on _both_ 80 and 443 (though it could happen). Chances are also good that a C2 server may be using SSL over a nonstandard port. 

<!-- tabs:start -->

### **:warning: No spoilers**

You can view _hints_ :question: with relevant background and direction and **solutions** :exclamation: where a command is given by selecting a tab.

#### **:question: _Suggested tools_**

- [`filter`](reference/filter)
- [`zq`](https://zed.brimdata.io/docs/next)
- [`chop`](reference/chop)
- `ipintersect` / `ipdiff` / `zet`

#### **:question: _Finding external IPs_**

If using `filter` consider the `-v` (`--invert-match`) flag combined with the `-p rfc1918` preset.

If using `zq` try the condition `local_resp == false`.

#### **:exclamation: __Final Solution__**

```bash
# Find external HTTP servers on port 80
filter --http 80 | chop id.resp_h id.resp_p | filter -v -p rfc1918 80 | chop 1 | distinct >external-http-80-servers.txt

# Find external SSL servers on port 443
filter --ssl 443 | chop id.resp_h id.resp_p | filter -v -p rfc1918 443 | chop 1 | distinct >external-ssl-443-servers.txt

# Find servers listening on both both ports 80 and 443
zet intersect external-http-80-servers.txt external-ssl-443-servers.txt

# Find servers listening only on port 80
zet diff external-http-80-servers.txt external-ssl-443-servers.txt

# Find servers listening only on port 443
zet diff external-ssl-443-servers.txt external-http-80-servers.txt
```

```bash
# Find external HTTP and SSL servers
zq -f text 'local_resp == false and service in ["http", "ssl"] and id.resp_p != 80 and id.resp_p != 443 | cut id.resp_h | sort | uniq' conn.*.log* >external-web-servers-nonstandard-port.txt

# Find servers listening only on a port other than 80 or 443
zet diff external-web-servers-nonstandard-port.txt external-http-80-servers.txt external-ssl-443-servers.txt
```

<!-- tabs:end -->

## Challenge 4

> [!ATTENTION]
> For an **advanced challenge**, use `zq` to convert the logs to JSON or Parquet and use `duckdb` to solve the challenges above using SQL.

<!-- tabs:start -->

### **:warning: No spoilers**

You can view _hints_ :question: with relevant background and direction and **solutions** :exclamation: where a command is given by selecting a tab.

#### **:question: _Suggested tools_**

- [`zq`](https://zed.brimdata.io/docs/next)
- [`duckdb`](https://duckdb.org/docs/archive/0.8.1/sql/introduction)

#### **:exclamation: __Converting Zeek logs__**

Set `_path` to the log type (in this case `conn`) to ensure the `shaper.zed` file works correctly. Use `zq -f` to specify the output file format. This may take a long time depending on the size of your data.

> [!TIP]
> `pv` is optional but is nice to have a status bar when a long data processing command is running.

```bash
# Combine all conn logs and convert to Parquet
zq "put _path:='conn'" conn.*.log* | pv | zq -I /root/.config/zq/shaper.zed -f parquet -o conn.parquet -
```

> [!NOTE]
> Compare the size of the resulting parquet file with the size of the original Zeek logs. The parquet file is uncompressed but can be very efficient in its binary storage format. Parquet does support compression as well to further reduce the file size.

#### **:exclamation: __Final Solution__**

Start `duckdb` without arguments.

```bash
duckdb
```

Note that we apply the same structure in the SQL solutions. See if you can pick out the pieces from earlier solutions.
1. Building temporary result sets for both HTTP and SSL clients.
2. Performing set operations on the datasets to get the result we want.

<!-- tabs:start -->

##### **Solution 1**

How many IPs made both types (SSL and HTTP) of connections?

```sql
WITH 
    http_clients AS (
        SELECT id.orig_h AS orig_h
        FROM read_parquet('conn.parquet')
        WHERE service = 'http'
    ), 
    ssl_clients AS (
        SELECT id.orig_h AS orig_h
        FROM read_parquet('conn.parquet')
        WHERE service = 'ssl'
    )
SELECT count(orig_h)
FROM (
    SELECT orig_h FROM http_clients
    INTERSECT 
    SELECT orig_h FROM ssl_clients
);
```

How many IPs made only HTTP connections but no SSL connections?

```sql
WITH 
    http_clients AS (
        SELECT id.orig_h AS orig_h
        FROM read_parquet('conn.parquet')
        WHERE service = 'http'
    ), 
    ssl_clients AS (
        SELECT id.orig_h AS orig_h
        FROM read_parquet('conn.parquet')
        WHERE service = 'ssl'
    )
SELECT count(orig_h)
FROM (
    SELECT orig_h FROM http_clients
    EXCEPT
    SELECT orig_h FROM ssl_clients
);
```

How many IPs made only SSL connections but no HTTP connections?

```sql
WITH 
    http_clients AS (
        SELECT id.orig_h AS orig_h
        FROM read_parquet('conn.parquet')
        WHERE service = 'http'
    ), 
    ssl_clients AS (
        SELECT id.orig_h AS orig_h
        FROM read_parquet('conn.parquet')
        WHERE service = 'ssl'
    )
SELECT count(orig_h)
FROM (
    SELECT orig_h FROM ssl_clients
    EXCEPT
    SELECT orig_h FROM http_clients
);
```

##### **Solution 2**

Which servers are listening on both ports 443 and 80?

```sql
WITH 
    http_servers AS (
        SELECT id.resp_h AS resp_h
        FROM read_parquet('conn.parquet')
        WHERE 
            local_resp 
            AND id.resp_p = 80
            AND service = 'http'
    ), 
    ssl_servers AS (
        SELECT id.resp_h AS resp_h
        FROM read_parquet('conn.parquet')
        WHERE 
            local_resp 
            AND id.resp_p = 443
            AND service = 'ssl'
    )
SELECT resp_h FROM http_servers
INTERSECT 
SELECT resp_h FROM ssl_servers;
```

Which servers are listening on only port 80?

```sql
WITH 
    http_servers AS (
        SELECT id.resp_h AS resp_h
        FROM read_parquet('conn.parquet')
        WHERE 
            local_resp 
            AND id.resp_p = 80
            AND service = 'http'
    ), 
    ssl_servers AS (
        SELECT id.resp_h AS resp_h
        FROM read_parquet('conn.parquet')
        WHERE 
            local_resp 
            AND id.resp_p = 443
            AND service = 'ssl'
    )
SELECT resp_h FROM http_servers
EXCEPT 
SELECT resp_h FROM ssl_servers;
```

Which servers are listening on only port 443?

```sql
WITH 
    http_servers AS (
        SELECT id.resp_h AS resp_h
        FROM read_parquet('conn.parquet')
        WHERE 
            local_resp 
            AND id.resp_p = 80
            AND service = 'http'
    ), 
    ssl_servers AS (
        SELECT id.resp_h AS resp_h
        FROM read_parquet('conn.parquet')
        WHERE 
            local_resp 
            AND id.resp_p = 443
            AND service = 'ssl'
    )
SELECT resp_h FROM ssl_servers
EXCEPT 
SELECT resp_h FROM http_servers;
```

Which servers are listening on only a port other than 80 or 443?

```sql
WITH 
    http_servers AS (
        SELECT id.resp_h AS resp_h
        FROM read_parquet('conn.parquet')
        WHERE 
            local_resp 
            AND id.resp_p = 80
            AND service = 'http'
    ), 
    ssl_servers AS (
        SELECT id.resp_h AS resp_h
        FROM read_parquet('conn.parquet')
        WHERE 
            local_resp 
            AND id.resp_p = 443
            AND service = 'ssl'
    ),
    nonstandard_servers AS (
        SELECT id.resp_h AS resp_h
        FROM read_parquet('conn.parquet')
        WHERE
            local_resp
            AND service IN ('http', 'ssl')
            AND id.resp_p NOT IN (80, 443)
    )
SELECT resp_h FROM nonstandard_servers
EXCEPT
SELECT resp_h FROM http_servers
EXCEPT
SELECT resp_h FROM ssl_servers;
```

> [!TIP] 
> Bonus: This is the same analysis done in a way to include the server port. If you get a different number of results from the previous query, it's because some IP addresses are listening on multiple ports.
> 
> ```sql
> WITH 
>     http_servers AS (
>         SELECT id.resp_h AS resp_h
>         FROM read_parquet('conn.parquet')
>         WHERE 
>             local_resp 
>             AND id.resp_p = 80
>             AND service = 'http'
>     ), 
>     ssl_servers AS (
>         SELECT id.resp_h AS resp_h
>         FROM read_parquet('conn.parquet')
>         WHERE 
>             local_resp 
>             AND id.resp_p = 443
>             AND service = 'ssl'
>     ),
>     nonstandard_servers AS (
>         SELECT 
>             id.resp_h AS resp_h,
>             id.resp_p AS resp_p
>         FROM read_parquet('conn.parquet')
>         WHERE
>             local_resp
>             AND service IN ('http', 'ssl')
>             AND id.resp_p NOT IN (80, 443)
>     )
> SELECT DISTINCT resp_h, resp_p
> FROM nonstandard_servers
> WHERE
>     resp_h NOT IN (SELECT resp_h FROM http_servers)
>     AND resp_h NOT IN (SELECT resp_h FROM ssl_servers);
> ```

##### **Solution 3**

This is the same as Solution 2 but with every `local_resp` turned into `NOT local_resp`.

Which servers are listening on both ports 443 and 80?

```sql
WITH 
    http_servers AS (
        SELECT id.resp_h AS resp_h
        FROM read_parquet('conn.parquet')
        WHERE 
            NOT local_resp 
            AND id.resp_p = 80
            AND service = 'http'
    ), 
    ssl_servers AS (
        SELECT id.resp_h AS resp_h
        FROM read_parquet('conn.parquet')
        WHERE 
            NOT local_resp 
            AND id.resp_p = 443
            AND service = 'ssl'
    )
SELECT resp_h FROM http_servers
INTERSECT 
SELECT resp_h FROM ssl_servers;
```

Which servers are listening on only port 80?

```sql
WITH 
    http_servers AS (
        SELECT id.resp_h AS resp_h
        FROM read_parquet('conn.parquet')
        WHERE 
            NOT local_resp 
            AND id.resp_p = 80
            AND service = 'http'
    ), 
    ssl_servers AS (
        SELECT id.resp_h AS resp_h
        FROM read_parquet('conn.parquet')
        WHERE 
            NOT local_resp 
            AND id.resp_p = 443
            AND service = 'ssl'
    )
SELECT resp_h FROM http_servers
EXCEPT 
SELECT resp_h FROM ssl_servers;
```

Which servers are listening on only port 443?

```sql
WITH 
    http_servers AS (
        SELECT id.resp_h AS resp_h
        FROM read_parquet('conn.parquet')
        WHERE 
            NOT local_resp 
            AND id.resp_p = 80
            AND service = 'http'
    ), 
    ssl_servers AS (
        SELECT id.resp_h AS resp_h
        FROM read_parquet('conn.parquet')
        WHERE 
            NOT local_resp 
            AND id.resp_p = 443
            AND service = 'ssl'
    )
SELECT resp_h FROM ssl_servers
EXCEPT 
SELECT resp_h FROM http_servers;
```

Which servers are listening on only a port other than 80 or 443?

```sql
WITH 
    http_servers AS (
        SELECT id.resp_h AS resp_h
        FROM read_parquet('conn.parquet')
        WHERE 
            NOT local_resp 
            AND id.resp_p = 80
            AND service = 'http'
    ), 
    ssl_servers AS (
        SELECT id.resp_h AS resp_h
        FROM read_parquet('conn.parquet')
        WHERE 
            NOT local_resp 
            AND id.resp_p = 443
            AND service = 'ssl'
    ),
    nonstandard_servers AS (
        SELECT id.resp_h AS resp_h
        FROM read_parquet('conn.parquet')
        WHERE
            NOT local_resp
            AND service IN ('http', 'ssl')
            AND id.resp_p NOT IN (80, 443)
    )
SELECT resp_h FROM nonstandard_servers
EXCEPT
SELECT resp_h FROM http_servers
EXCEPT
SELECT resp_h FROM ssl_servers;
```

> [!TIP] 
> Bonus: This is the same analysis done in a way to include the server port. If you get a different number of results from the previous query, it's because some IP addresses are listening on multiple ports.
> 
> ```sql
> WITH 
>     http_servers AS (
>         SELECT id.resp_h AS resp_h
>         FROM read_parquet('conn.parquet')
>         WHERE 
>             NOT local_resp 
>             AND id.resp_p = 80
>             AND service = 'http'
>     ), 
>     ssl_servers AS (
>         SELECT id.resp_h AS resp_h
>         FROM read_parquet('conn.parquet')
>         WHERE 
>             NOT local_resp 
>             AND id.resp_p = 443
>             AND service = 'ssl'
>     ),
>     nonstandard_servers AS (
>         SELECT 
>             id.resp_h AS resp_h,
>             id.resp_p AS resp_p
>         FROM read_parquet('conn.parquet')
>         WHERE
>             NOT local_resp
>             AND service IN ('http', 'ssl')
>             AND id.resp_p NOT IN (80, 443)
>     )
> SELECT DISTINCT resp_h, resp_p
> FROM nonstandard_servers
> WHERE
>     resp_h NOT IN (SELECT resp_h FROM http_servers)
>     AND resp_h NOT IN (SELECT resp_h FROM ssl_servers);
> ```

<!-- tabs:end -->

Type `.quit` to exit `duckdb` when finished.

<!-- tabs:end -->