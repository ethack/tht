---
title: "Chop"
date: 2021-07-23T16:06:13-05:00
draft: true
---

## Overview

One of the most common ways to transform data is to select certain columns to keep, while discarding the rest. This is exactly what `chop` does. You can accomplish the same thing with `awk`, `cut`, `zeek-cut`, `jq`, etc. but without changing your tool or syntax when your log format changes. 

Here's a comparison between the different tools and log types they support.

| Command    | Zeek TSV | JSON | CSV  | TSV  | Whitespace | Custom |
| ---------- | -------- | ---- | ---- | ---- | ---------- | ------ |
| `chop`     | ✔️        | ✔️    | ✔️    | ✔️    | ✔️          | ††††   |
| `awk`      | ✔️ †      |      | ✔️ †† | ✔️ †† | ✔️          | ✔️      |
| `cut`      | ✔️ †      |      | ✔️ †† | ✔️ †† | ✔️  †††     | ✔️      |
| `zeek-cut` | ✔️        |      |      |      |            |        |
| `jq`       |          | ✔️    |      |      |            |        |
| `json-cut` |          | ✔️    |      |      |            |        |
| `zq`       | ✔️        | ✔️    |      |      |            |        |
| `mlr`      |          | ✔️    | ✔️    | ✔️    | ✔️          |        |
| `xsv`      |          |      | ✔️    | ✔️    |            |        |

- † returns junk from metadata
- †† will not handle quoted values containing delimeter
- ††† can pick space or tab but not both
- †††† not yet

Can you pre-process and post-process data and make most of these tools work? Sure. But why not let `chop` do it for you instead? And automatically using the fastest tool for the job is a nice bonus.

The best way to illustrate this is with examples.

Let's say you want to pull out the destination IPs and ports from a Zeek TSV file. Here are some traditional ways you might do this.

```bash
zeek-cut id.resp_h id.resp_p
awk '{print $6,$7}'
cut -d$'\t' -f6,7
zq -f text 'cut id.resp_h,id.resp_p'
sed -e '0,/^#fields\t/s///' | grep -v '^#' | xsv select -d '\t' id.resp_h,id.resp_p
mlr --prepipe "sed '0,/^#fields\t/s///'" --tsv --skip-comments cut -f id.resp_h,id.resp_p
```

`chop` borrows its simplicity from `zeek-cut` to accomplish the same task.

```bash
chop id.resp_h id.resp_p
chop id.resp_h,id.resp_p
```
<!-- 
These don't yet work with Zeek TSV
chop 6,7
chop 6 7
chop 6-7
-->


{{% notice tip %}}
`chop` lets you keep using the syntax you are comfortable with. Separate your fields with spaces, commas, or both!
{{% /notice %}}

Now let's say you want to do the same thing (pull out the destination IPs and ports) but this time from a Zeek JSON file.

```bash
json-cut id.resp_h id.resp_p
zq -f text 'cut id.orig_h,id.resp_h,id.resp_p'
jq -c '{"id.resp_h", "id.resp_p"}'
mlr --json cut -f id.resp_h,id.resp_p
```

{{% notice note %}}
Since JSON objects are sparse and un-ordered it doesn't make sense to specify a field by its index.
{{% /notice %}}

Unless you're using `zq` you've already had to dust off a new tool and learn/remember its syntax. `chop` lets you use the same simple syntax you've already learned.

```bash
chop id.resp_h id.resp_p
```

Next, let's say you want the `src` (1st column) and `dst` (3rd column) fields from a firewall log CSV file.

```bash
awk -F, '{print $1,$3}'
cut -d, -f1,3
xsv select src,dst
xsv select 1,3
mlr --csv cut -f src,dst
```

That's not *too* bad. But you still have unnecessary command switches and boilerplate.

```bash
chop src dst
chop 1,3
```

And what if those `src` and `dst` columns were whitespace separated?

```bash
awk '{print $1,$3}'
cut -d' ' -f1,3    # only works if spaces used
cut -d$'\t' -f1,3  # only works if tabs used
mlr --pprint cut -f src,dst
```

By now you've guessed it. `chop` remains the same. Not only can you keep the same syntax between file formats, but you don't have to even think about what separators are used.

```bash
chop src dst
chop 1,3
```

Before `chop`, each scenario would require you to reach for a different tool and then figure out the syntax or transformations to get it working. In the end, you'll have a command that's cumbersome to type and likely cannot be used as-is for another log format.

{{% notice info %}}
`chop` does not yet support specifying a custom delimeter. So if your data is `|`-separated, for example, you'll have to reach for `cut -d'|'` for now.
{{% /notice %}}