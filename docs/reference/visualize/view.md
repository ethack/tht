---
title: "Viewers"
description: |
  THT includes several ways of viewing data.
date: 2021-06-11T18:44:06-05:00
draft: true
---


- pxl
- pv
- plot-bar
- zv, cv, tv
- zvt, cvt, tvt


# Pipeviewer

Progress bar

Example:

```
# from
fd ... | xargs zcat | grep ... > out.txt
# to (I think. Check my previous notes.)
fd ... | xargs pv | zcat | grep ... > out.txt
```

# Zeek viewer

`zv` script for Zeek logs, both TSV or JSON

# CSV Viewer

`cv` alias for CSV files

# TSV Viewer

`tv` alias for TSV files