---
title: "Miller"
date: 2021-03-29T22:39:53-05:00
draft: true
---

> Miller is like awk, sed, cut, join, and sort for name-indexed data such as CSV, TSV, and tabular JSON. You get to work with your data using named fields, without needing to count positional column indices.

Miller is a data processing pipeline written in C. You can use it to supplement or replace traditional Unix tools, as well as use it's builtin domain specific language (DSL) to replace scripting engines like `awk`, `python`, `ruby`, `perl`, etc. As the above quote states, you can use column headers in CSV files or field names in JSON (much like `jq`) to reference values instead of having to count and use indexes. This makes scripts more robust as re-ordering or missing data can be handled automatically. 

The [features](https://miller.readthedocs.io/en/latest/features.html) page has great use cases that are worth reading through.

Miller's documentation is quite good. It's [10 minute intro](https://miller.readthedocs.io/en/latest/10min.html) is useful to get a feel for using Miller and the [examples](https://miller.readthedocs.io/en/latest/quick-examples.html) are a great reference for common tasks.

Another use case of Miller is to convert files between [formats that Miller supports](https://miller.readthedocs.io/en/latest/file-formats.html). Here are a few data types that Miller can process.

- CSV (comma separated values)
- TSV (tab separated values)
- JSON
- Pretty print (tab separated tables with aligned columns)

When using Miller you must tell it what the input file format is as well as what output type you would like. There are several ways to specify these.

To keep the output format the same as the input format you use the named flag (e.g. `mlr --json`). To specify different input and output formats you use multiple flags and prepend with `i` for input and `o` for output (e.g. `mlr --ijson --ocsv`).  Since having different input and output formats is common, Miller also has "keystroke-save" options in the format of "input abbreviation 2 output abbreviation". For example, `--j2c` is the same as `--ijson --ocsv` and `--j2t` is the same a `--ijson --otsv`.

While Miller doesn't provide builtin support for compressed files it does have a `--prepipe` flag which lets you preprocess files with an external program before they are passed to Miller's pipeline. Since `zcat` is a common task Miller has a shortcut `--prepipe-zcat` which is equivalent to `--prepipe 'zcat -cf'`.

One thing I am not sure of is if Miller does multi-processing or multi-threading.

# Zeek Log Examples

One use case for Miller is to help us process Zeek logs.

With JSON formatted Zeek logs the process is straight-forward.

```bash
mlr --json 
```
# Zeek TSV

```bash
mlr --prepipe "sed '0,/^#fields\t/s///'" --itsv --skip-comments
```

```
mlr --prepipe "sed '0,/^#fields\t/s///'"  --t2p --skip-comments head conn-10x-*.log.gz
```

Other options:
`tail -n +7 | sed -e '0,/^#fields\t/s///' | grep -v '^#'`
`zq -f csv`

Ideas:
alias
.mlrrc (prepipe is invalid here though)


## Producer-Consumer Ratio

```
      ( SrcApplicationBytes - DstApplicationBytes ) 
PCR = --------------------------------------------- 
      ( SrcApplicationBytes + DstApplicationBytes ) 
```




# Other


Quote
Source / Features
Description

Homepage (Link in the first instance of its name?)
GitHub
Installation

Help invocation

