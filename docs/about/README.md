## About

The Threat Hunting Toolkit (<span title="aka Think Happy Thoughts  (⌒‿⌒)">THT</span>) is a Swiss Army knife for threat hunting, log processing, and security-focused data science. You can think THT as a curated environment that you can bring with you anywhere, much like a craftsman's toolkit would be. While THT is designed with processing Zeek network logs in mind (both TSV and JSON), we've also used it successfully with other delimited logs such as comma or whitespace separated.

- Incorporates many CLI tools into one place for ease of deployment.
- Removes boilerplate and awkward syntax from common workflows.
- Use the same tools and syntax on many types of logs: Zeek TSV, NDJSON, CSV, TSV, Whitespace, etc.

## Why THT

THT aims to make complex command line kung fu simple and fast. It also makes it possible to do things you wouldn't normally accomplish in the command line. The example below shows using THT to create a bar chart.

Let's say your goal is to find a trend or anomaly in traffic to _cloudfront.net_.

The following command searches Zeek `ssl.log` files (compressed or not) for all events going to _cloudfront.net_. It then pulls out the timestamp, converts it to a date, and counts the frequency of events per day. Finally, it displays a bar graph of the result.

```bash
filter --ssl cloudfront.net | chop ts | ts2 date | freq | plot-bar 
```
          ┌────────────────────────────────────────────────────────────────────────────────────────────┐
    475620┤                                                               █████████████▌               │
          │                                                               █████████████▌               │
          │                                                               █████████████▌               │
          │                                                               █████████████▌               │
    396350┤                                                               █████████████▌               │
          │                                                               █████████████▌               │
          │                                                               █████████████▌               │
          │                                                               █████████████▌               │
    317080┤                                                               █████████████▌               │
          │                                                               █████████████▌               │
          │                                                               █████████████▌               │
          │                                                               █████████████▌               │
    237810┤                                                               █████████████▌               │
          │                                                               █████████████▌  ▄▄▄▄▄▄▄▄▄▄▄▄▄│
          │                                                               █████████████▌  █████████████│
          │                                                               █████████████▌  █████████████│
          │                                                               █████████████▌  █████████████│
    158540┤                                                               █████████████▌  █████████████│
          │                                                               █████████████▌  █████████████│
          │                                               ▐████████████▌  █████████████▌  █████████████│
          │                                               ▐████████████▌  █████████████▌  █████████████│
     79270┤                                               ▐████████████▌  █████████████▌  █████████████│
          │                                               ▐████████████▌  █████████████▌  █████████████│
          │                                               ▐████████████▌  █████████████▌  █████████████│
          │                               ▗▄▄▄▄▄▄▄▄▄▄▄▄▖  ▐████████████▌  █████████████▌  █████████████│
         0┤▄▄▄▄▄▄▄▄▄▄▄▄▄  ▗▄▄▄▄▄▄▄▄▄▄▄▄▄  ▐████████████▌  ▐████████████▌  █████████████▌  █████████████│
          └──────┬───────────────┬───────────────┬──────────────┬───────────────┬───────────────┬──────┘
             2021-06-21      2021-06-22      2021-06-23     2021-06-24      2021-06-25      2021-06-26  
    [y] Count                                           [x]                                             

Compare this to a (rougly) equivalent command without THT. It's doable, but you have to be fluent in quite a few builtin Linux tools, as well as their various flags, and how to escape special characters. After all that you get the same information, but you have to compare relative size of numbers in the text output rather than looking at a graph.

```bash
zgrep -hF cloudfront.net */ssl* | cut -d$'\t' -f1 | sed 's/^/@/' | date -Idate -f - | sort -nr | uniq -c
```

       2910 2021-06-21
       3326 2021-06-22
      19308 2021-06-23
     126939 2021-06-24
     475620 2021-06-25
     226890 2021-06-26

Not only do the tools included in THT remove much of the arcane syntax and boilerplate associated with log parsing, but they are also generally faster. 

In the above example, the THT version took **10.8 seconds**.

    filter --ssl cloudfront.net  64.85s user 5.54s system 670% cpu 10.491 total
    chop ts  2.56s user 2.10s system 44% cpu 10.492 total
    ts2 date  4.54s user 0.11s system 44% cpu 10.496 total
    sort --version-sort --buffer-size=2G  1.26s user 0.11s system 12% cpu 10.809 total
    uniq -c  0.05s user 0.01s system 0% cpu 10.808 total
    plot-bar  0.07s user 0.02s system 0% cpu 10.871 total

And the non-THT version took nearly **3x longer** at **31.3 seconds**.

    zgrep -hF cloudfront.net */ssl*  33.00s user 3.68s system 117% cpu 31.188 total
    cut -d$'\t' -f1  1.41s user 0.48s system 6% cpu 31.187 total
    sed 's/^/@/'  0.32s user 0.04s system 1% cpu 31.187 total
    date -Idate -f -  1.23s user 0.04s system 4% cpu 31.186 total
    sort -n  0.56s user 0.05s system 1% cpu 31.306 total
    uniq -c  0.06s user 0.00s system 0% cpu 31.305 total                                  