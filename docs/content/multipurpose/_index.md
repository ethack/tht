---
title: "Multipurpose"
date: 2021-05-29T11:07:40-05:00
weight: 60
chapter: true
draft: true
---


# Takeaways
- Use `ugrep` or `filter` if:
    - Your use case will work with regex.
    - You can filter out some data before passing it on to more expensive operations.
- Use Zq on Zeek files if:
    - Performance is not a concern.
- Use VAST if:
    - All you need is filtering. No math, aggregations, or pipelines (unless you're willing to use Python).
    - Space is not a concern.
    - You want to ingest and correlate multiple data sources: Zeek, Suricata, Sysmon
    - You need interopability with Arrow / Pandas.
- Use Zq with ZNG file format if:
    - You need to run lots of queries on the same Zeek data.
    - Space is a concern.
- Use Miller if:
    - You need are processing non-Zeek logs.
    - You need more flexibility than what Zq gives you.
- Use Python if:
    - Other options fall short.
    - You need a custom algorithm.
    - You want to use data science libraries.
    - You want to use Jupyter notebooks.
- Use R if:
    - You already know it?
    - ?
- Use Julia if:
    - More speed than Python?
    - ?



# Benchmarks
## Baseline

$ time zcat conn.00:00:00-01:00:00__pcl03seconion01__102321245.log.gz | zeek-cut id.orig_h | sort -V | uniq -c | sort -nr | head
zcat conn.00:00:00-01:00:00__pcl03seconion01__102321245.log.gz  10.60s user 0.43s system 43% cpu 25.424 total
zeek-cut id.orig_h  2.28s user 0.56s system 11% cpu 25.424 total
sort -V  15.81s user 0.43s system 53% cpu 30.511 total
uniq -c  0.67s user 0.02s system 2% cpu 30.510 total
sort -nr  0.07s user 0.00s system 0% cpu 30.533 total
head  0.00s user 0.00s system 0% cpu 30.532 total

So about 28-29 seconds.

Uncompressed Zeek log.

2.5G	conn.log
660M	conn.log.gz

That actually makes the results below even more impressive.

## VAST
version 2021.06.24-rc1-0-g034be0de9d

### Preprocessing
time zcat 2021-04-04/* | vast/bin/vast import zeek
VAST is using all cores. But I'm thinking I could improve by having zcat use all cores as well with xargs or parallel.
Import 30GB.
Ran out of space :(

time zcat sample/* | vast/bin/vast import zeek
[15:35:13.805] zeek-reader source produced 26525269 events at a rate of 304628 events/sec in 1.45m

real	1m27.956s
user	1m50.791s
sys	0m5.290s

Increase in 8.25x space
1.2G	sample
9.9G	vast.db

### Querying

I can't figure out the equivalent of `cut` for VAST. I'll have to do a search example instead.


## ZQ
version 0.29.0

### Preprocessing

#### ZNG
time find . -type f -name '*.gz' -exec bash -c 'zcat {} | zq -f zng -o {}.zng -' \;
find . -type f -name '*.gz' -exec bash -c 'zcat {} | zq -f zng -o {}.zng -' \  204.85s user 10.59s system 239% cpu 1:29.83 total

Zq was also multi-threaded. while processing logs.

Not a big increase in space.
1.2G	sample
1.8G	sample-zng

#### ZST

$ time find . -type f -name '*.gz' -exec bash -c 'zcat {} | zq -f zst -o {}.zst -' \;
find . -type f -name '*.gz' -exec bash -c 'zcat {} | zq -f zst -o {}.zst -' \  118.26s user 4.74s system 166% cpu 1:13.77 total

Took less time, but was a much bigger increase in storage. Falls squarely between VAST and Zq/zng, but while taking less time.
1.2G	sample
1.8G	sample-zng
4.1G	sample-zst

### Querying

#### ZNG

zq -i zng -f csv 'cut id.orig_h | sort | uniq -c | sort -r _uniq | head 10'   69.20s user 0.81s system 113% cpu 1:01.75 total

#### ZST
Interesting. You can't pipe a zst file into zq. And can't have colons in the name or you have to jump through hoops. Renamed files to conn.zst, etc.

This seems too long
zq -i zst -f csv 'cut id.orig_h | sort | uniq -c | sort -r _uniq | head 10'   92.68s user 1.19s system 132% cpu 1:11.06 total

Try benchmarks again later with uncompressed logs.

hyperfine -w 0 -r 2 \
-n ug 'ug "\tT\tF" sample/conn.log | wc -l' \
-n ug-gzip 'ug -z "\tT\tF" sample/conn.log.gz | wc -l' \
-n vast 'vast/bin/vast -e 172.17.0.1 export csv "net.src.ip in 10.0.0.0/8 && net.dst.ip !in 10.0.0.0/8" | wc -l' \
-n zq 'zq -i zeek -f csv "id.orig_h =~ 10.0.0.0/8 and not id.resp_h =~ 10.0.0.0/8" sample/conn.log | wc -l' \
-n zq-gzip 'zq -i zeek -f csv "id.orig_h =~ 10.0.0.0/8 and not id.resp_h =~ 10.0.0.0/8" sample/conn.log.gz | wc -l' \
-n zng 'zq -i zng -f csv "id.orig_h =~ 10.0.0.0/8 and not id.resp_h =~ 10.0.0.0/8" sample-zng/conn.zng | wc -l' \
-n zst 'zq -i zst -f csv "id.orig_h =~ 10.0.0.0/8 and not id.resp_h =~ 10.0.0.0/8" sample-zst/conn.zst | wc -l'
Benchmark #1: ug
  Time (mean ± σ):      2.244 s ±  0.007 s    [User: 2.010 s, System: 0.422 s]
  Range (min … max):    2.240 s …  2.249 s    2 runs
 
Benchmark #2: ug-gzip
  Time (mean ± σ):      9.173 s ±  0.072 s    [User: 9.826 s, System: 0.803 s]
  Range (min … max):    9.122 s …  9.224 s    2 runs
 
Benchmark #3: vast
  Time (mean ± σ):     21.148 s ±  0.002 s    [User: 16.652 s, System: 14.386 s]
  Range (min … max):   21.146 s … 21.149 s    2 runs
 
Benchmark #4: zq
  Time (mean ± σ):     45.765 s ±  0.067 s    [User: 63.689 s, System: 0.814 s]
  Range (min … max):   45.717 s … 45.812 s    2 runs
 
Benchmark #5: zq-gzip
  Time (mean ± σ):     60.147 s ±  0.140 s    [User: 78.250 s, System: 0.710 s]
  Range (min … max):   60.048 s … 60.246 s    2 runs
 
Benchmark #6: zng
  Time (mean ± σ):     20.665 s ±  0.056 s    [User: 23.885 s, System: 1.039 s]
  Range (min … max):   20.625 s … 20.704 s    2 runs
 
Benchmark #7: zst
  Time (mean ± σ):     29.604 s ±  0.007 s    [User: 39.547 s, System: 0.573 s]
  Range (min … max):   29.599 s … 29.609 s    2 runs
 
Summary
  'ug' ran
    4.09 ± 0.03 times faster than 'ug-gzip'
    9.21 ± 0.04 times faster than 'zng'
    9.42 ± 0.03 times faster than 'vast'
   13.19 ± 0.04 times faster than 'zst'
   20.39 ± 0.07 times faster than 'zq'
   26.80 ± 0.10 times faster than 'zq-gzip'

Here are the results to look for correctness. I'm pretty sure local orig and local resp were not set correctly. But holy crap, why are vast and zq different? Oh that's right. Vast has all logs in.

ug: 3223980
vast: 911115
zng: 539885
zst: 539885

$ bash -c 'vast/bin/vast -e 172.17.0.1 export csv "#type == \"zeek.conn\" && net.src.ip in 10.0.0.0/8 && net.dst.ip !in 10.0.0.0/8" | wc -l'
vast: 539885
That's more like it. Took less time too.
13.08s

So overall it seems that zng is the winner, though it's probably worth doing some more tests based on what's possible. Definitely use grep where possible.


hyperfine -w 0 -r 2 \
-n vast 'vast/bin/vast -e 172.17.0.1 export csv "zeek.conn.conn_state == \"SF\" && zeek.conn.orig_bytes > 10" | wc -l' \
-n zq 'zq -i zeek -f csv "conn_state=SF and orig_bytes > 10" sample/conn.log | wc -l' \
-n zq-gzip 'zq -i zeek -f csv "conn_state=SF and orig_bytes > 10" sample/conn.log.gz | wc -l' \
-n zng 'zq -i zng -f csv "conn_state=SF and orig_bytes > 10" sample-zng/conn.zng | wc -l' \
-n zst 'zq -i zst -f csv "conn_state=SF and orig_bytes > 10" sample-zst/conn.zst | wc -l'
Benchmark #1: vast
  Time (mean ± σ):     32.971 s ±  0.054 s    [User: 35.947 s, System: 25.157 s]
  Range (min … max):   32.933 s … 33.010 s    2 runs
 
Benchmark #2: zq
  Time (mean ± σ):     69.549 s ±  0.116 s    [User: 90.983 s, System: 2.049 s]
  Range (min … max):   69.467 s … 69.631 s    2 runs
 
Benchmark #3: zq-gzip
  Time (mean ± σ):     83.967 s ±  0.048 s    [User: 105.235 s, System: 2.059 s]
  Range (min … max):   83.933 s … 84.001 s    2 runs
 
Benchmark #4: zng
  Time (mean ± σ):     45.097 s ±  0.270 s    [User: 56.205 s, System: 2.039 s]
  Range (min … max):   44.906 s … 45.288 s    2 runs
 
Benchmark #5: zst
  Time (mean ± σ):     54.942 s ±  0.034 s    [User: 72.636 s, System: 1.799 s]
  Range (min … max):   54.918 s … 54.966 s    2 runs
 
Summary
  'vast' ran
    1.37 ± 0.01 times faster than 'zng'
    1.67 ± 0.00 times faster than 'zst'
    2.11 ± 0.00 times faster than 'zq'
    2.55 ± 0.00 times faster than 'zq-gzip'


vast: 4233955
zng: 4233955
