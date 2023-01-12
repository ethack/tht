## Overview

One of the most common ways to transform data is to select certain columns to keep, while discarding the rest. This is exactly what `chop` does. It's like `cut` but with column names and CSV/TSV/JSON/Zeek support. 

## Examples

Let's say you want to pull out the destination IPs and ports from a Zeek TSV file. 


<details>
<summary>Here are some traditional ways you might do this.</summary>

```bash
zeek-cut id.resp_h id.resp_p
awk '{print $6,$7}'
cut -d$'\t' -f6,7
zq -f text 'cut id.resp_h,id.resp_p'
sed -e '0,/^#fields\t/s///' | grep -v '^#' | xsv select -d '\t' id.resp_h,id.resp_p
mlr --prepipe "sed '0,/^#fields\t/s///'" --tsv --skip-comments cut -f id.resp_h,id.resp_p
```

</details>


`chop` borrows its simplicity from `zeek-cut` to accomplish the task.

```bash
chop id.resp_h id.resp_p
chop id.resp_h,id.resp_p
```

If your logs don't have headers (or you just prefer not to use them) you can specify field indexes instead.

```bash
chop 6,7
chop 6 7
# a range will also work
chop 6-7
```

> [!TIP]
> `chop` lets you specify fields with spaces, commas, or mix-and-match!

Now let's say you want to do the same thing (pull out the destination IPs and ports) but this time from a Zeek JSON file.

> [!NOTE]
> Since JSON objects are sparse and un-ordered it doesn't make sense to specify a field by its numerical index.

<details>
<summary>Traditional methods are more verbose.</summary>

```bash
json-cut id.resp_h id.resp_p
zq -f text 'cut id.orig_h,id.resp_h,id.resp_p'
jq -c '{"id.resp_h", "id.resp_p"}'
mlr --json cut -f id.resp_h,id.resp_p
```

</details>

`chop` lets you use the same simple syntax you've already learned rather than forcing you to a different tool with its own syntax.

```bash
chop id.resp_h id.resp_p
```

Next, let's say you want the `src` (1st column) and `dst` (3rd column) fields from a firewall log CSV file. 

<details>
<summary>The traditional methods aren't <strong>too</strong> bad.</summary>

```bash
awk -F, '{print $1,$3}'
cut -d, -f1,3
xsv select src,dst
xsv select 1,3
mlr --csv cut -f src,dst
```

</details>

But they still have unnecessary command switches and boilerplate compared to `chop`.

```bash
chop src dst
chop 1,3
```

And what if those `src` and `dst` columns were whitespace separated?

<details>
<summary>Traditional methods force you to change flags.</summary>

```bash
awk '{print $1,$3}'
cut -d' ' -f1,3    # only if space separated, not both
cut -d$'\t' -f1,3  # only if tab separated, not both
mlr --pprint cut -f src,dst
```

</details>

By now, you've guessed it. `chop`'s syntax remains the same. Not only can you keep the same syntax between file formats, but you don't have to think about which separators are used.

```bash
chop src dst
chop 1,3
```

Before `chop`, each scenario would require you to reach for a different tool and then figure out the syntax or transformations to get it working with your data. In the end, you'd have a command that's cumbersome to type and unlikely to be used as-is for another log format.

> [!TIP]
> Just like with other tools, you can specify a custom single character as a delimeter with `chop`. E.g. `chop -d'|'` or `chop -d':'`.

## Comparison to Other Tools

You can accomplish the same thing with `awk`, `cut`, `zeek-cut`, `jq`, etc. but without changing your tool or syntax when your log format changes. 

Here's a comparison between the different tools and log types they support.

| Command      | Zeek TSV | JSON | CSV  | TSV  | Whitespace | Custom |
| ------------ | -------- | ---- | ---- | ---- | ---------- | ------ |
| `chop`       | ✔️        | ✔️    | ✔️    | ✔️    | ✔️          | ✔️      |
| `awk`        | ✔️ †      |      | ✔️ †† | ✔️ †† | ✔️          | ✔️      |
| `cut`        | ✔️ †      |      | ✔️ †† | ✔️ †† | ✔️  †††     | ✔️      |
| `zeek-cut`   | ✔️        |      |      |      |            |        |
| `jq`         |          | ✔️    |      |      |            |        |
| `json-cut`   |          | ✔️    |      |      |            |        |
| `zq 'cut'`   | ✔️        | ✔️    |      |      |            |        |
| `mlr cut`    |          | ✔️    | ✔️    | ✔️    | ✔️          |        |
| `xsv select` |          |      | ✔️    | ✔️    |            | ✔️      |
| `tsv-select` | ✔️ †      |      | ✔️    | ✔️    |            | ✔️      |

- † returns junk from metadata
- †† will not handle quoted values containing delimeter
- ††† can pick space or tab but not both

Can you pre-process and post-process data and make most of these tools work? Sure. But why not let `chop` do it for you instead?
