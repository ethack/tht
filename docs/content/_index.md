---
title: "Introduction"
date: 2021-05-27T08:00:00-05:00
draft: false
weight: 1
---

# Threat Hunting Toolkit

#### You have data. Now what?

Don't panic! You have many tools and methods at your disposal. This documentation will show how you can use and combine them to make your data more valuable.

- **Visualize** 
    - The simplest thing you can do is look at your raw data. There may be too much at first to be meaningful, but viewing your data is necessary to determine how to transform and summarize it.
        - Example: Using `cat` to view a log file or loading a CSV into a spreadsheet.
    - Creating _graphs_ and _charts_ is a useful way to discover patterns and trends, identify outliers, and view relationships.
- **Clean** 
    - An overlooked, but crucial step is making sure your data is _cleaned_ or _normalized_ so that other operations can be performed without error. This is an important part of data science.
- **Filter** 
    - Reducing the amount of data through _filtering_ is nearly always going to be your first step and often between other operations as well. Not only does this remove noise irrelevant to the question or goal you have, but it reduces the amount of time it takes to get to that goal.
- **Sort** 
    - _Sorting_ the data on different or even multiple fields is necessary for techniques like long tail analysis. It is also a vital first step done before any aggregation/grouping procedure.
- **Compute** 
    - This is when you use fields from your existing data and perform some operation to create or _derive_ a new field, sometimes referred to as a _computed field_. A simple example would be adding the bytes sent and received together to get the total bytes transferred.
- **Correlate** 
    - You can _correlate_ your data with other data by _joining_ datasets together on common fields.
        - Example: Taking multiple log types that share a field (e.g. IP address) and joining them together to create a single entry containing data from both logs. 
    - You can also _enrich_ your data using data from other sources, such as an API or existing database. 
        - Examples: Name resolution or passive DNS, geographical info, WHOIS or ownership info, or even threat intelligence feeds.
- **Summarize** 
    - _Summarizing_, also known as _grouping_, _aggregating_, or _stacking_, reduces your data by combining data through methods such as the average, sum, or count.

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

This will give you a `zsh` shell inside a new THT container. All the tools and examples from this documentation can now be used.

### Advanced Usage

With `tht` you can also run one-off commands or even give it scripts to execute within the context of the container. This is useful if you want to automate or schedule certain tasks from the host system.

The basic usage is `tht run <command>`.

```bash
tht run "echo hello world"
```
**Result:**

    hello world

This will run existing script.

```bash
cat my_script.sh | tht run
```

You can also specify multiple commands or an entire script like this.

```bash
tht run <<\SCRIPT
message=GREAT!
echo -n "Running multiple commands "
echo -n "without escaping feels $message "
echo {1..3}
SCRIPT
```
**Result:**

    Running multiple commands without escaping feels GREAT! 1 2 3

```bash
tht run <<\SCRIPT
#!/usr/bin/env python3

print('Here is an example python program')

SCRIPT
```
**Result:**

    Here is an example python program

For instance, you might want to put a script like this in your host's cron scheduler `/etc/cron.hourly/pdns`.

```bash
#!/bin/bash

tht run <<\SCRIPT
cd /host/opt/zeek/logs/

nice flock -n "/host/tmp/pdns.lock" \
fd 'dns.*.log' | sort | xargs -n 24 bro-pdns index
SCRIPT
```


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
