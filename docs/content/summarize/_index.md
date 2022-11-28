---
title: "Summarize"
date: 2021-05-29T11:07:50-05:00
weight: 30
chapter: true
---

Here is an overview of the pages in this category:

{{% children description="true" %}}

- `distinct` - Outputs unique lines.
- `count` - Counts number of lines.
- `card` - Counts unique lines, printing the _cardinality_ of the data.
- `freq` - Displays the number of occurrences, or _frequency_, of each unique line.
- `mfo` - Most Frequent Occurrence. Like `freq` but sorted by most commonly occurring unique line. Optionally pass a number to truncate results.
- `lfo` - Least Frequent Occurrence. Like `freq` but sorted by least commonly occurring unique line. Optionally pass a number to truncate results.


What is the difference between `freq`, `mfo`, and `lfo`?

- `freq` is equivalent to `sort | uniq -c`. It will order and count your data but leave it in the original order. This is especially useful for working with dates and creating charts.
- `mfo` is equivalent to `sort | uniq -c | sort -nr` with an optional `head -n`. It's very similar to `freq` except it sorts the final result by the most frequent (highest count). This is useful when you want the most common values at the top.
- `lfo` is equivalent to `sort | uniq -c | sort -n` with an optional `head -n`. It's nearly identical to `mfo` but just sorts the opposite direction so that the least frequent (lowest count) are at the top.