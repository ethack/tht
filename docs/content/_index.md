---
title: "Introduction"
date: 2021-05-27T08:00:00-05:00
draft: false
weight: 1
---

# Threat Hunting Toolkit

#### You have data. Now what?

Don't panic! You have many tools and methods at your disposal. This documentation will show how you can use and combine them to make your data more valuable.

- **Explore** 
    - The simplest thing you can do is explore your raw data. There may be too much at first to be meaningful, but viewing your data is necessary to determine how to transform and summarize it. In data science this is called _Exploratory Data Analysis_ (EDA).
        - Example: Using `cat` to view a log file or loading a CSV into a spreadsheet.
    - _Visualizing_ your data through graphs and charts is a useful way to discover patterns and trends, identify outliers, and view relationships.
- **Filter** 
    - Reducing the amount of data through _filtering_ is nearly always going to be your first step and often between other operations as well. 
    - Not only does this remove noise irrelevant to your question or goal, but it decreases the time it takes to process the remaining data.
    - How to: Countless tools accomplish this in different ways. Anything that uses regular expressions, search terms, or comparisions is a way of filtering data. Common Linux utils like `grep` and `awk`, THT's `filter`, your SIEM's search bar, or even a SQL `WHERE` clause are all ways to accomplish this.
- **Compute** 
    - This is when you use fields from your existing data and perform some operation to create or _derive_ a new field, sometimes referred to as a _computed field_. A simple example would be adding the bytes sent and received together to get the total bytes transferred. In data science this is known as _Feature Engineering_.
    - _Computing_ normally involves some custom programming, either in a formal language like Python, or in a domain specific language (DSL) in a tool like Miller.
- **Correlate** 
    - Closely related to pivoting, which is when you would manually use a piece of information to _pivot_ into a different dataset. This can also be thought of as a _join_.
    - You can _correlate_ your data with other data by _joining_ datasets together on common fields.
        - Example: Taking multiple log types that share a field (e.g. IP address) and joining them together to create a single entry containing data from both logs. 
    - You can also _enrich_ your data using data from other sources, such as an API or existing database. 
        - Examples: Name resolution or passive DNS, geographical info, WHOIS or ownership info, or even threat intelligence feeds.
- **Summarize** 
    - _Summarizing_, also known as _grouping_, _aggregating_, or _data stacking_, reduces your data by combining data through methods such as the average, sum, or count.

<!-- - Visualize - can be broken down into EDA, conceptualization - Learning about your dataset

- Search / Filter - Reducing your dataset (filter), also columns (chop)
- Compute / Transform - increases your data by adding new information
- Summarize / group / aggregate / stack - related but reduces number of rows

- Correlate / Join / Pivot - Bringing in other datasets

VE F T SGA CJP

filter chop agg

- **Clean** 
    - An overlooked, but crucial step is making sure your data is _cleaned_ so that other operations can be performed without error. This is an important part of data science.
- **Sort** 
    - _Sorting_ the data on different or even multiple fields is necessary for techniques like long tail analysis. It is also a vital first step done before any aggregation/grouping procedure.

Change Correlate to Pivot or integrate pivot somehow. 


Supplementary
- Clean / scrubbing
- Sort

Similar Models:

- Split, Apply, Combine - [Pandas `groupby` function](https://pandas.pydata.org/docs/user_guide/groupby.html)
- Extract, Transform, Load (ETL) - Data Science discipline
- Graph, Aggregate, Pivot, Statistics, Search (GAPPS) - [Chris Sanders' Practical Threat Hunting course](https://chrissanders.org/training/threat-hunting-training/) -->

<!-- Not sure if this belongs in the list or not.
- Machine learning - This is often has a loose definition, but under the hood any machine learning going to be doing several of these methods, especially _deriving_ and _correlating_ your data.

TODO: See if the definition is better in a nested list. Would make each method stand out more. Put an example of each in a nested list.
TODO: Combine view/visualize

Batch processing
Streaming -->

## Installing THT

The Threat Hunting Toolkit (THT) is the name of the project, a docker image, as well as a wrapper script for launching. While you can use the docker image manually, the recommended way is through the wrapper script.

This will install the `tht` script in `/usr/local/bin/tht`.

```bash
sudo curl -o /usr/local/bin/tht https://raw.githubusercontent.com/ethack/tht/main/tht && sudo chmod +x /usr/local/bin/tht
```

## Running THT

This is the simplest way to launch THT.

```bash
tht
```

This will give you a shell inside a new THT container. All the tools and examples from this documentation can now be used. 

{{% notice tip %}}
Your host's filesystem is accessible from `/host`.
{{% /notice %}}

### Advanced Usage

With `tht` you can also execute scripts from your host that run within the context of a THT container. The usage is much like you would with a shell such as `bash` or `zsh`. This is useful if you want to automate or schedule certain tasks from the host system.

This will run an existing script.

```bash
tht my_script.sh
```

You can also specify multiple commands or an entire script by piping on stdin, like this:

```bash
tht <<\SCRIPT
message=GREAT!
echo -n "Running multiple commands "
echo -n "without escaping feels $message "
echo {1..3}
SCRIPT
```
**Result:**

    Running multiple commands without escaping feels GREAT! 1 2 3

```bash
tht <<\SCRIPT
#!/usr/bin/env python3

print('Here is an example python program')

SCRIPT
```
**Result:**

    Here is an example python program

You can also use `tht` in a shell script's hash-bang where you would normally have your shell executable.

For instance, you might want to put a script like this in your host's cron scheduler `/etc/cron.hourly/pdns`.

```bash
#!/usr/local/bin/tht

cd /host/opt/zeek/logs/

nice flock -n "/host/tmp/pdns.lock" \
fd 'dns.*log' | sort | xargs -n 24 bro-pdns index
```

See the [cron/](https://github.com/ethack/tht/tree/main/cron) directory in the code repo for more examples of cron scripts.

{{% notice tip %}}
You can use `tht` as a shell executable in [Ansible's `shell` module](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/shell_module.html). E.g. 
```yaml
- name: Count the number of HTTP server errors to POST requests
  ansible.builtin.shell: |
    echo -n "Number of HTTP server errors to POSTs: "
    filter --http POST 500 | count
  args:
    executable: /usr/local/bin/tht
    chdir: "/opt/zeek/logs"
```
{{% /notice %}}

## Updating THT

This will pull the latest image as well as latest `tht` script.

```bash
tht update
```
**Result:**

    Downloading latest THT image...
    Using default tag: latest
    latest: Pulling from ethack/tht
    Digest: sha256:ef98d36e379fb0f2d9537c39b9e53fcb8f349e2cbde9d9d37eb15d4299e0ac41
    Status: Image is up to date for ethack/tht:latest
    docker.io/ethack/tht:latest
    Self-updating THT script...

# Advantages

## Simplicity

Here is an example of the power of THT. Let's say your goal is to find a trend or anomaly in traffic to _cloudfront.net_.

The following command searches Zeek `ssl.log` files (compressed or not) for all events going to _cloudfront.net_. It then pulls out the timestamp, converts it to a date, and counts the frequency of events per day. Finally, it displays a bar graph of the result.

```bash
filter --ssl cloudfront.net | chop ts | ts2 date | freq | plot-bar 
```

**Result:**

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

<!-- TODO prevent line wrapping on smaller width screens. The above block should purely scroll instead. -->

Compare this to a (rougly) equivalent command without THT. It's doable, but you have to be fluent in quite a few builtin Linux tools, as well as their various flags, and how to escape special characters. After all that you get the same information, but you have to compare relative size of numbers in the text output rather than looking at a graph.

```bash
zgrep -hF cloudfront.net */ssl* | cut -d$'\t' -f1 | sed 's/^/@/' | date -Idate -f - | sort -nr | uniq -c
```

**Result:**

       2910 2021-06-21
       3326 2021-06-22
      19308 2021-06-23
     126939 2021-06-24
     475620 2021-06-25
     226890 2021-06-26

## Speed

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

# Complementary Projects

These are all projects that work well together with THT.

- [Elastic](https://www.elastic.co/elasticsearch/) / [Kibana](https://www.elastic.co/kibana/)
- [Metabase](https://github.com/metabase/metabase)
- [ml-workspace](https://github.com/ml-tooling/ml-workspace)
- [Data Science at the Command Line](https://www.datascienceatthecommandline.com/)

## Further Resources

- https://github.com/dbohdan/structured-text-tools