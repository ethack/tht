---
title: "Filter"
date: 2021-04-28T08:48:04-05:00
draft: true
---

The `filter` script is designed for searching Zeek logs for IP addresses and domains. However, it is flexible enough that it can be used for other purpsoses as well. 

`filter` has several special features. By default it will:
- Search in the current directory tree for any `conn.log` files, including compressed files and rotated logs.
- Search files in parallel using multiple cores.
- Use faster alternatives to `grep` like [ripgrep](https://github.com/BurntSushi/ripgrep) or [ugrep](https://github.com/Genivia/ugrep), when available.
- Keep Zeek TSV headers intact so that tools like `zeek-cut` can be used on the results.
- Require all search terms to be found in the same line.
- Escape periods in search terms to prevent `10.0.1.0` from matching `10.0.100` or `google.com` from matching `google1com.com`.
- Add boundaries around the search term to prevent `192.168.1` from matching `192.168.100.50` or `google.com` from matching `fakegoogle.com`.
- Just like traditional `grep` you can also pipe text to search in as input.

Usage: 

```txt
filter --help
Filters Zeek logs based on the search terms with output that can be piped to zeek-cut or other tools that can read Zeek logs.

filter [--<logtype>] [OPTIONS] [search_term] [search_term...]

    --<logtype>   is used to search logs of "logtype" (e.g. conn, dns, etc) in the current directory tree (default: conn)
    -r|--regex    signifies that [search_term(s)] should be treated as regexes
    -a|--and      all search terms are required to appear in a line (default)
    -o|--or       at least one search term is required to appera in a line

    Specify one or more [search_terms] to filter either STDIN or log files. Lines must match all search terms.

Examples:
    filter 10.0.0.1                            conn entries from the current directory tree that match the IP
    filter 10.0.0.1 1.1.1.1                    conn entries from the current directory tree that match the pair of IPs
    filter --or 8.8.8.8 1.1.1.1                conn entries from the current directory tree that match either of IPs
    cat conn.log | filter 10.0.0.1             conn entries from STDIN that match the IP
    filter --dns 'google.com'                  dns entries from the current directory tree that match the domain or any subdomains
    filter --dns --regex '\tgoogle\.com\t'     dns entries from the current directory tree that match the regex

```

The best way to understand the benefits is with examples.

`filter` is designed to be called as-is for the most common use cases. It would defeat the purpose if it always required extra options.

```bash
# find all conn log entries from the current directory tree containing 192.168.1.1
filter 192.168.1.1
# find all log entries from stdin containing 192.168.1.1
cat conn.log | filter 192.168.1.1
# find all conn log entries containing 192.168; note: this could also match 10.10.192.168
filter 192.168
# find all conn log entries containing both 192.168.1.1 and 8.8.8.8
filter 192.168.1.1 8.8.8.8
```

```bash
# use filter as a parallel grep replacement
filter --regex '"id.orig_h":"192.168.1.1"'
```

```bash
# find all http log entries containing 192.168.1.1
filter --http 192.168.1.50
# find all dns log entries containing both 192.168.1.1 and 8.8.8.8
filter --dns 192.168.1.1 8.8.8.8
```

```bash
# find all conn log entries containing 192.168.1.1
filter 192.168.1.1
# find all conn log entries containing both 192.168.1.1 and 8.8.8.8
filter --dns --or 8.8.8.8 8.8.4.4 1.1.1.1 1.0.0.1
```

TODO
Show examples of piping into zeek-cut, conn-summary (link to documentation), zq, or any other tool.

More Examples:

```bash
filter 1.1.1.1 192.168.1.2 | zeek-cut id.orig_h id.resp_h id.resp_p proto service
```

```bash
filter --dns 1.1.1.1 google.com | zeek-cut id.orig_h
```

It will look in the current directory tree for any files matching the type you pass in. However, you can also pipe in files to be more granular.

```
cat http.log | filter google.com | zeek-cut host uri
```

## Shortcomings
Or why you should use this to quickly reduce log volume before pairing with more specialized tools.

```bash
# This will also match 10.10.192.168 or 10.192.168.10, etc.
filter 192.168
# Workaround for TSV
filter --regex '\t192\.168\.'
# Workaround for JSON
filter --regex '"192\.168\.'
```

TODO: Can I fix these cases in the script?
filter --begins 192.168 == '(\t|")192\.168\b'
filter --ends 254 == '\b254(\t|")'

By design, `filter` will match the search string anywhere in the line. This means that if you want to search for an _origin_ of 192.168.1.1, the best method is to first use `filter` and then combine with another tool that can check a certain field such as `awk`, `jq`, `zq`, or even a combination of `zeek-cut` and more `filter`. 

For JSON logs you can do something like this:
```bash
# use filter as a parallel grep replacement
filter --regex '"id.orig_h":"192.168.1.1"'
```

## Alternatives
- `grepwide` from https://github.com/markjx/search2018

## FAQ

Why use `filter` over tools like `awk`, `grep`, `jq`, [`zq`](https://github.com/brimdata/zed/blob/main/cmd/zed/README.md#zq), etc.? `filter` complements or enhances many of these tools. 
- For instance, using a regex search tool is nearly always faster than using `awk`, `zq`, or `jq` to perform equality testing. 
- By assuming a specific use case (searching Zeek logs for things like IP addresses) `filter` can automate a bunch of boilerplate like escaping periods in regexes, passing through Zeek headers, and not printing the filenames.
- `grep` on it's own does not utilize paralell processing which means either replacing it with an alternative or combining it with something like `parallel` or `xargs` and remembering the correct syntax.
