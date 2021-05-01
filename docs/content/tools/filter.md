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

`filter` is designed to be called as-is for the most common use cases. It would defeat its purpose if it required extra options every time.

```bash
# find all conn log entries from the current directory tree containing 192.168.1.1
filter 192.168.1.1
```

Let's look at what it would take to do this without using `filter`. A first attempt is straightforward:

```bash
cat conn.*log | fgrep 192.168.1.1
# or
zcat conn.*log.gz | fgrep 192.168.1.1
```

However, this has multiple issues:
- It is tricky to search both plaintext and gzip logs at once.
- Zeek TSV headers are stripped which means no piping to zeek-cut.
- Grep doesn't make use of multiple cores, severely increasing the search time.
- Logs in subdirectories are not searched.
- Search will match `192.168.1.10`, `192.168.1.19`, `192.168.1.100`, etc.

There are ways around each of these issues, but they add extra complexity to the command and more typing. You'd ultimately end up with something like this:

```bash
find . -regextype egrep -iregex '.*/conn\b.*\.log(.gz)?$' | xargs -n 1 -P 12 zgrep -e '^#' -e '\b192\.168\.1\.1\b'
```

Which is roughly equivalent to the much shorter `filter 192.168.1.1`.

Let's take a look at more examples.

```bash
# log entries from stdin containing 192.168.1.1
cat conn.log | filter 192.168.1.1

# conn log entries containing 192.168; note: this could also match 10.10.192.168
filter 192.168

# conn log entries containing both 192.168.1.1 and 8.8.8.8
filter 192.168.1.1 8.8.8.8

# dns log entries containing 8.8.8.8
filter --dns 8.8.8.8

# conn log entries containing both 192.168.1.1 and 8.8.8.8
filter --dns --or 8.8.8.8 8.8.4.4 1.1.1.1 1.0.0.1

# http log entries containing google.com; note: this will also match google.com.fake.com
filter --http google.com

# conn JSON entries where the origin host is 192.168.1.1
filter --regex '"id.orig_h":"192.168.1.1"'
```

Where `filter` really shines is when you combine it with other tools that can parse Zeek logs, such as `zeek-cut`, `conn-summary`, and `zq`.


```bash
# find all sources who queried evil.com
filter --dns evil.com | zeek-cut id.orig_h | sort -V | uniq

# show a summary of traffic involving a specific IP address
filter 1.2.3.4 | conn-summary
```

## Shortcomings

> Or... reasons to use `filter` to quickly reduce log volume before pairing with more specialized tools.

```bash
# This will also match 10.10.192.168 or 10.192.168.10, etc.
filter 192.168
# Workaround for TSV
filter --regex '\t192\.168\.'
# Workaround for JSON
filter --regex '"192\.168\.'
```

By design, `filter` will match the search string anywhere in the line. This means that if you want to search for an _origin_ of 192.168.1.1, the best method is to first use `filter` and then combine with another tool that can check a certain field such as `awk`, `jq`, `zq`, or even a combination of `zeek-cut` and more `filter`. 

```bash
# for JSON logs you can do something like this
filter --regex '"id.orig_h":"192.168.1.1"'
# or this
filter 192.168.1.1 | jq ""

# or you can use zq for either type of Zeek log
filter 192.168.1.1 | zq -f zeek "id.orig_h = 192.168.1.1" -
```

Now you might be wondering in that last example why you would even need to use filter at all. And you'd certainly get the same results by using the `zq` command on the unfiltered logs. It comes down to performance. String searching tools like `grep` are going to be much faster than something that parses and interprets a log file like `zq`. The benchmark below shows that it is quite a bit faster to first use `filter` to reduce log volume before doing more expensive matching, than it is to feed all the logs directly into `zq` for exact matching first. This also has the benefit 

```bash
$ hyperfine -w 1 'filter 10.55.182.100 | zq -f zeek "id.orig_h = 10.55.182.100" -' 'zcat conn.* | zq -f zeek "id.orig_h = 10.55.182.100" -'
Benchmark #1: filter 10.55.182.100 | zq -f zeek "id.orig_h = 10.55.182.100" -
  Time (mean ± σ):     768.8 ms ±  31.5 ms    [User: 3.399 s, System: 0.262 s]
  Range (min … max):   714.9 ms … 822.9 ms    10 runs
 
Benchmark #2: zcat conn.* | zq -f zeek "id.orig_h = 10.55.182.100" -
  Time (mean ± σ):      6.256 s ±  0.392 s    [User: 11.595 s, System: 0.466 s]
  Range (min … max):    5.807 s …  7.240 s    10 runs
 
Summary
  'filter 10.55.182.100 | zq -f zeek "id.orig_h = 10.55.182.100" -' ran
    8.14 ± 0.61 times faster than 'zcat conn.* | zq -f zeek "id.orig_h = 10.55.182.100" -'
```

$ cat conn.* | jq 'select(."id.orig_h"=="10.55.182.100")'
filter 10.55.182.100 | jq 'select(."id.orig_h"=="10.55.182.100")'

## Alternatives
- `grepwide` from https://github.com/markjx/search2018

## FAQ

Why use `filter` over tools like `awk`, `grep`, `jq`, [`zq`](https://github.com/brimdata/zed/blob/main/cmd/zed/README.md#zq), etc.? `filter` complements or enhances many of these tools. 
- For instance, using a regex search tool is nearly always faster than using `awk`, `zq`, or `jq` to perform equality testing. 
- By assuming a specific use case (searching Zeek logs for things like IP addresses) `filter` can automate a bunch of boilerplate like escaping periods in regexes, passing through Zeek headers, and not printing the filenames.
- `grep` on it's own does not utilize paralell processing which means either replacing it with an alternative or combining it with something like `parallel` or `xargs` and remembering the correct syntax.
