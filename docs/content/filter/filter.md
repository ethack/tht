---
title: "Filter"
date: 2021-04-28T08:48:04-05:00
draft: false
---

## Overview

The `filter` script is tailored for searching IP addresses and domains in Zeek logs. However, it is flexible enough that it can be used for other purpsoses as well. 

`filter` has several special features. By default, it:
- Searches in the current directory tree for any `conn.log` files, including compressed files and rotated logs.
- Searches files in parallel using multiple cores.
- Uses faster alternatives to `grep` like [ripgrep](https://github.com/BurntSushi/ripgrep) or [ugrep](https://github.com/Genivia/ugrep), when available.
- Keeps Zeek TSV headers intact so that tools like `zeek-cut` can be used on the results.
- Requires all search terms to be found in the same line to cut down on piping to repeated searches.
- Escapes periods in search terms to prevent `10.0.1.0` from matching `10.0.100` or `google.com` from matching `google1com.com`.
- Adds boundaries around the search term to prevent `192.168.1` from matching `192.168.100.50` or `google.com` from matching `fakegoogle.com`.

## Usage

```txt
filter [--<logtype>] [OPTIONS] [search_term] [search_term...] [-- [OPTIONS]]

    --<logtype>         is used to search logs of "logtype" (e.g. conn, dns, etc) in the current directory tree (default: conn)
    -d|--dir <dirglob>  will search logs in <dirglob> instead of current directory

    Specify one or more [search_terms] to filter either STDIN or log files. If you don't specify any search terms, all lines will be printed.
    
    Lines must match all search terms by default.
    -o|--or       at least one search term is required to appear in a line (as opposed to all terms matching)

    Search terms will match on word boundaries by default.
    -s|--starts-with   anchor search term to beginning of field (e.g. 192.168)
    -e|--ends-with     anchor search term to end of field (e.g. google.com)
    -r|--regex         signifies that [search_term(s)] should be treated as regexes
    -v|--invert-match  will invert the matching
    -n|--dry-run       print out the final search command rather than execute it

    You can specify search terms in other ways as well.
    -f|--file <patternfile.txt>   file containing newline separated search terms
    -p|--preset <preset>          use a common preset regex with current options being:
                rfc1918           matches private IPv4 addresses defined in RFC1918
                ipv4              matches any IPv4 address

    filter will pick the best search tool for the situation. Use the following options to force a specific tool.
    --rg          force use of ripgrep
    --ug          force use of ugrep
    --zgrep       force use of zgrep
    --cat         force use of cat (useful for testing)
    --grepcidr    force use of grepcidr

    Any arguments given after -- will be passed to the underlying search command.
```

## Comparison with Grep

The best way to understand the benefits is with an example. `filter` is designed to be called as-is for the most common use cases. It would defeat its purpose if it required extra options every time.

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
- It is cumbersome to search both plaintext and gzip logs at once.
- Zeek TSV headers are stripped which means no piping to `zeek-cut`.
- `grep` doesn't make use of multiple cores, increasing the search time.
- Logs in subdirectories are not searched.
- Search will match `192.168.1.10`, `192.168.1.19`, `192.168.1.100`, etc.

There are ways around each of these issues, but they add extra complexity to the command and more typing. You'd ultimately end up with something like this:

```bash
find . -regextype egrep -iregex '.*/conn\b.*\.log(.gz)?$' | xargs -n 1 -P $(nproc) zgrep -e '^#' -e '\b192\.168\.1\.1\b'
```

Which is roughly equivalent to the much shorter `filter 192.168.1.1`.

## Examples

Let's take a look at more examples.

{{% notice tip %}}
Just like traditional `grep` you can also pipe text to search as input.
{{% /notice %}} 

```bash
# log entries from stdin containing 192.168.1.1
cat conn.log | filter 192.168.1.1

# conn log entries containing 192.168; note: this could also match 10.10.192.168
filter 192.168

# conn log entries containing both 192.168.1.1 and 8.8.8.8
filter 192.168.1.1 8.8.8.8

# dns log entries containing 8.8.8.8
filter --dns 8.8.8.8

# dns log entries to Google or Cloudflare's DNS servers
filter --dns --or 8.8.8.8 8.8.4.4 1.1.1.1 1.0.0.1

# http log entries containing google.com; note: this will also match google.com.fake.com
filter --http google.com

# conn JSON entries where the origin host is 192.168.1.1
filter -r '"id.orig_h":"192.168.1.1"'
```

Where `filter` really shines is when you combine it with other tools that can parse Zeek logs, such as `zeek-cut`, `conn-summary`, and `zq`.


```bash
# find all source IPs that queried evil.com
filter --dns evil.com | zeek-cut id.orig_h | sort -V | uniq

# find all IPs there were resolved by evil.com queries
filter --dns evil.com | zeek-cut answers | filter -p ipv4 -- -o | sort -V | uniq

# show a summary of traffic involving a specific IP address
filter 1.2.3.4 | conn-summary

# TODO zq example with a grouping
```

You can also specify search terms inside a file. These search terms are given the same escaping treatment as if they were specified on the commandline.

```bash
filter --or -f patterns.txt
```

If you'd like to restrict the search directory to something more than the current directory tree you can.

```bash
filter -d 2021-06-29 1.1.1.1
# globbing and bash brace expansion work as well (note: you'll need quotes around the argument)
filter -d '2021-06-*' 1.1.1.1
filter -d '2021-06-{01..15}' 1.1.1.1
```

## Performance

{{% notice tip %}}
Use `filter` to quickly reduce log volume before piping to more specialized tools.
{{% /notice %}} 

By design, `filter` will match the search string anywhere in the line. This means that if you want to search for an _origin_ of 192.168.1.1, the best method is to first use `filter` and then another tool that can check a certain field such as `awk`, `jq`, `zq`.

```bash
# TODO awk example

# for JSON logs you can do something like this
filter --regex '"id.orig_h":"192.168.1.1"'
# or this
filter 192.168.1.1 | jq 'select(."id.orig_h"=="192.168.1.1")'

# or you can use zq for either type of Zeek log
filter 192.168.1.1 | zq -f zeek "id.orig_h = 192.168.1.1" -
```

You might be wondering in that last example why you would even need to use filter at all. You'd certainly get the same results by using the `zq` command on the unfiltered logs. 

It comes down to performance. String searching tools like `grep` are going to be much faster than something like `zq` or `jq` that parses and interprets the field values in a log file. The benchmarks below show that it is quite a bit faster to first use `filter` to reduce log volume before doing more expensive matching, than it is to feed all the logs directly into `zq` or `jq` for field matching first. 

{{% notice note %}}
Since `filter` uses multiple CPU cores, this also has the benefit of parallelizing the pipeline stage when the log volume is at its peak.
{{% /notice %}}

```bash
$ hyperfine -w 1 \
  -n filter-then-select 'filter 10.55.182.100 | zq -f zeek "id.orig_h = 10.55.182.100" -' \
  -n cat-then-select 'zcat conn.* | zq -f zeek "id.orig_h = 10.55.182.100" -'

Benchmark #1: filter-then-select
  Time (mean ± σ):     768.8 ms ±  31.5 ms    [User: 3.399 s, System: 0.262 s]
  Range (min … max):   714.9 ms … 822.9 ms    10 runs
 
Benchmark #2: cat-then-select
  Time (mean ± σ):      6.256 s ±  0.392 s    [User: 11.595 s, System: 0.466 s]
  Range (min … max):    5.807 s …  7.240 s    10 runs
 
Summary
  'filter-then-select' ran
    8.14 ± 0.61 times faster than 'cat-then-select'
```

```bash
$ hyperfine -w 1 \
  -n cat-then-select 'cat conn.* | jq "select(.\"id.orig_h\"==\"10.55.182.100\")"' \
  -n filter-then-select 'filter 10.55.182.100 | jq "select(.\"id.orig_h\"==\"10.55.182.100\")"'

Benchmark #1: cat-then-select
  Time (mean ± σ):     22.428 s ±  2.036 s    [User: 22.185 s, System: 2.264 s]
  Range (min … max):   18.629 s … 24.577 s    10 runs
 
Benchmark #2: filter-then-select
  Time (mean ± σ):      1.285 s ±  0.101 s    [User: 2.455 s, System: 0.172 s]
  Range (min … max):    1.096 s …  1.386 s    10 runs
 
Summary
  'filter-then-select' ran
   17.45 ± 2.09 times faster than 'cat-then-select'
```

## Gotchas

```bash
# this will also match 10.10.192.168 or 10.192.168.10, etc.
filter 192.168
# do this instead
filter --starts-with 192.168
```

```bash
# this will also match google.com.fake.com
filter --http google.com
# do this instead
filter --http --ends-with google.com
```

## Alternatives

- [grepwide](https://github.com/markjx/search2018)
- [ripgrep](https://github.com/BurntSushi/ripgrep)
- [ugrep](https://github.com/Genivia/ugrep)
- [grepcidr](https://github.com/jrlevine/grepcidr3)

## FAQ

Q: Why use `filter` over tools like `awk`, `grep`, `jq`, [`zq`](https://github.com/brimdata/zed/blob/main/cmd/zed/README.md#zq), etc.? 

A: `filter` complements or enhances many of these tools. 
- For instance, using a regex search tool is nearly always faster than using `awk`, `zq`, or `jq` to perform equality testing. 
- By assuming a specific use case (searching Zeek logs for things like IP addresses) `filter` can automate a bunch of boilerplate like escaping periods in regexes, passing through Zeek headers, and recursively searching compressed files of one log type.
- `grep` on its own does not utilize parallel processing. This means either replacing it with an alternative or remembering the correct syntax to combine it with something like `parallel` or `xargs`.
