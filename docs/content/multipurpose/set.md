---
title: "Set Operations"
description: |
  Set theory comes in useful in surprising places (union, intersection, difference, etc).
date: 2021-09-24T18:01:49-05:00
draft: true
---

# Tools

There are several tools available for performing set operations on files containing arbitrary data.

- `setdiff` - difference
- `setintersect` - intersection
- `setunion` - union

{{% notice note %}}
Symmetric difference is currently not implemented.
{{% /notice %}}

## IP Addresses

Additionally, there are tools that are specific for IP addresses. The difference with these is that they are aware of CIDR notation (e.g. 192.168.0.0/16) and treat address ranges as sets as well.

- `ipdiff` - difference
- `ipdiffs` - symmetric difference
- `ipintersect` - intersection
- `ipunion` - union

<!-- You can find more about these IP address tools [here](filter/ip/). -->

There are also several utility scripts for working with IP address ranges.

- `cidr2ip` - converts CIDR ranges to individual IP addresses
- `ip2cidr` - converts a set of IP addresses to the minimal list of CIDR ranges that represent the same IPs
- `ipcount` - counts the number of IP total addresses listed (including those in ranges)

# Set Theory

Diagrams do a fantastic job illustrating these concepts if you need an introduction or refresher.

## Union

> The set of elements that appear in either set. [More info](https://en.wikipedia.org/wiki/Union_(set_theory))

![union venn diagram](https://upload.wikimedia.org/wikipedia/commons/thumb/3/30/Venn0111.svg/300px-Venn0111.svg.png)

## Intersection

> The set of elements that appear in both sets. [More info](https://en.wikipedia.org/wiki/Intersection_(set_theory))

![intersection venn diagram](https://upload.wikimedia.org/wikipedia/commons/thumb/9/99/Venn0001.svg/330px-Venn0001.svg.png)

## Difference

> The set of elements in the second set but not in the first set. [More info](https://en.wikipedia.org/wiki/Complement_(set_theory)#Relative_complement)

![relative complement venn diagram](https://upload.wikimedia.org/wikipedia/commons/thumb/5/5a/Venn0010.svg/375px-Venn0010.svg.png)

{{% notice note %}}
Also known as the _relative complement_ or just _complement_.
{{% /notice %}}

## Symmetric Difference

> The set of elements which are in either of the sets, but not in their intersection. [More info](https://en.wikipedia.org/wiki/Symmetric_difference)

![symmetric difference venn diagram](https://upload.wikimedia.org/wikipedia/commons/thumb/4/46/Venn0110.svg/330px-Venn0110.svg.png)

{{% notice note %}}
Also known as the _disjunctive union_.
{{% /notice %}}