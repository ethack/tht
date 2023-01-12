---
title: "Zq"
date: 2021-03-29T22:39:59-05:00
draft: true
---


zq looks to have parallelization. 
    -P read two or more files into parallel-input zql query (default "false")
    This is only for join and requires some fenagling.
    https://github.com/brimdata/zed/issues/1616
    https://github.com/brimdata/zed/issues/1629

Performance shows its significantly slower than using zeek-cut or jq when working with their respective formats and simple tasks.

zq supports compressed Zeek files
Supports Parquet files. Also custom ZST columnar storage.
https://github.com/brimdata/zq/issues/703
https://github.com/brimdata/zq/issues/796
Next version will support parquet writing as well.
https://github.com/brimdata/zed/issues/2167

rg -zI -e '169\.254\.' -e '^#' -g 'conn.*.log.gz' | zq -f zeek 'id.resp_h =~ 169.254.0.0/16' -

rg -zI -e '169\.254\.' -e '^#' -g 'conn.*.log.gz' | awk '{ if($5~/^169.254./) print $0 }'

ls conn.*.log.gz | parallel "zcat {}" | awk '{ if($5~/^169.254./) print $0 }'
ls conn.*.log.gz | parallel "zcat {}" | zq -f zeek 'id.resp_h =~ 169.254.0.0/16' -

```
root@2020-206H /host/opt/bro/remotelogs/COMBINED__0000/2021-04-13 
$ hyperfine -i -w 1 "fd -ag 'conn.00*.log.gz' | sed 's_^_file://_' | xargs zq -f zeek 'id.resp_h =~ 169.254.0.0/16'" "rg -zI -e '169\.254\.' -e '^#' -g 'conn.00*.log.gz' | zq -f zeek 'id.resp_h =~ 169.254.0.0/16' -" "rg -zI -e '169\.254\.' -e '^#' -g 'conn.00*.log.gz' | awk '{ if(\$5~/^169.254./) print \$0 }'"
Benchmark #1: fd -ag 'conn.00*.log.gz' | sed 's_^_file://_' | xargs zq -f zeek 'id.resp_h =~ 169.254.0.0/16'
  Time (mean ± σ):     23.303 s ±  0.265 s    [User: 34.853 s, System: 2.214 s]
  Range (min … max):   22.996 s … 23.850 s    10 runs
 
  Warning: Ignoring non-zero exit code.
 
Benchmark #2: rg -zI -e '169\.254\.' -e '^#' -g 'conn.00*.log.gz' | zq -f zeek 'id.resp_h =~ 169.254.0.0/16' -
  Time (mean ± σ):      8.589 s ±  0.197 s    [User: 25.622 s, System: 2.798 s]
  Range (min … max):    8.267 s …  8.824 s    10 runs
 
Benchmark #3: rg -zI -e '169\.254\.' -e '^#' -g 'conn.00*.log.gz' | awk '{ if($5~/^169.254./) print $0 }'
  Time (mean ± σ):      8.584 s ±  0.194 s    [User: 25.493 s, System: 2.806 s]
  Range (min … max):    8.313 s …  8.991 s    10 runs
 
Summary
  'rg -zI -e '169\.254\.' -e '^#' -g 'conn.00*.log.gz' | awk '{ if($5~/^169.254./) print $0 }'' ran
    1.00 ± 0.03 times faster than 'rg -zI -e '169\.254\.' -e '^#' -g 'conn.00*.log.gz' | zq -f zeek 'id.resp_h =~ 169.254.0.0/16' -'
    2.71 ± 0.07 times faster than 'fd -ag 'conn.00*.log.gz' | sed 's_^_file://_' | xargs zq -f zeek 'id.resp_h =~ 169.254.0.0/16''
```

Though it's promising that zq piped in was just as fast as awk and didn't error.

```
$ hyperfine -i -w 1 -n zq "rg -zI -e '169\.254\.' -e '^#' -g 'conn.0*.log.gz' | zq -f zeek 'id.resp_h =~ 169.254.0.0/16' -" -n awk "rg -zI -e '169\.254\.' -e '^#' -g 'conn.0*.log.gz' | awk '{ if(\$5~/^169.254./) print \$0 }'"
Benchmark #1: zq
  Time (mean ± σ):     44.971 s ±  1.311 s    [User: 237.228 s, System: 28.524 s]
  Range (min … max):   43.263 s … 47.028 s    10 runs
 
Benchmark #2: awk
  Time (mean ± σ):     43.985 s ±  0.816 s    [User: 237.987 s, System: 26.656 s]
  Range (min … max):   42.623 s … 45.064 s    10 runs
 
Summary
  'awk' ran
    1.02 ± 0.04 times faster than 'zq'
```

DON'T FORGET TO SPECIFY - FOR STDIN IF PIPING INTO ZQ!!!


cat filter.test | zq -f zeek 'id.orig_h = 165.227.88.15' - | head


CIDR testing

id.resp_h =~ 169.254.0.0/16
id.resp_h in 169.254.0.0/16

How to query for an empty field. (This includes if the field is - for unset.)
$ filter 172.28.4.22 SF | zq -f zeek 'service = "" | head' -  
I think this also works for service = null


PCR calculation in zq
$ cat conn.log | zq -f table 'sum_orig=sum(orig_bytes:int64),sum_resp=sum(resp_bytes:int64) by src=id.orig_h,dst=id.resp_h,port=id.resp_p | put pcr=(sum_orig-sum_resp)/(sum_orig+sum_resp+0.001)' -
