---
title: "Grep"
date: 2021-03-29T22:40:34-05:00
draft: true
---

WARNING: empty lines in pattern files matches everything!
- grep
- ripgrep

It does not apply to:
- ugrep
- grepcidr

wtf, this should be something that you're told when you're given your first computer. here's the mouse, keyboard, and screen. you can click and type to do things. and grep will turn into cat if you have an empty line in your patternfile


ripgrep doesn't read zip files from stdin. e.g. 
cat test.gz | rg -z test -
but zgrep and ugrep do.

ugrep .* doesn't match an empty line but grep and ripgrep do.

# GNU Grep

https://www.haktansuren.com/run-parallel-grep-for-faster-search/
https://drjohnstechtalk.com/blog/2011/06/gnu-parallel-really-helps-with-zcat/
https://saveriomiroddi.github.io/Running-shell-commands-in-parallel-via-gnu-parallel/
https://github.com/markjx/search2018

# Ripgrep

# Ugrep


# Benchmarks

