## Custom THT Tools

|                   Command | Purpose                                        |                   Alternative                    |
| -------------------------:|:---------------------------------------------- |:------------------------------------------------:|
|                `[[chop]]` | **select** columns                             |               `cut` or `zeek-cut`                |
|                    `cols` |                                                |                                                  |
|        `[[conn-summary]]` | displays **connection summary** given Zeek logs|                `trace-summary`                   |
|                   `count` | non-comment line **count**                     |      <code>grep -v '^#' &vert; wc -l</code>      |
|                    `card` | **count of unique** elements (**cardinality**) |    <code>sort &vert; uniq &vert; wc -l</code>    |
|                `distinct` | **unique** elements                            |          <code>sort &vert; uniq</code>           |
|                  `domain` | truncates a full **domain** to (default 2) elements | <code>rev &vert; cut -d. -f1-2 &vert; rev</code> |
|              `[[filter]]` | **search** within files                        |          <code>find &vert; grep</code>           |
|                   `first` | sorts and prints the **first** element         |         <code>sort &vert; head -1</code>         |
|                    `freq` | **frequency** counts                           |         <code>sort &vert; uniq -c</code>         |
|                 `headers` |                                                |                                                  |
|                    `last` | sorts and prints the **last** element          |         <code>sort &vert; tail -1</code>         |
|                     `lfo` | **least frequent occurrences** first           | <code>sort &vert; uniq -c &vert; sort -n</code>  |
|                     `mfo` | **most frequent occurrences** first            | <code>sort &vert; uniq -c &vert; sort -nr</code> |
|                `plot-bar` | produce a bar **graph**                        |                                                  |
|              `random-tip` | prints a random cheatsheet tip entry           |                                                  |
|                    `skip` | **skips** elements and prints the rest         |                   `tail -n +2`                   |
|                     `ts2` | convert/truncate **timestamps**                |                                                  |
|                  `viewer` | displays results in a scrollable table         |                    `less -S`                     |
|          `[[whois-bulk]]` | bulk lookups on IPs for ASN and owning Orgs    |                     `whois`                      |


## Shell Utils
These are purely to enhance the interactive experience of THT.
- [`bat`](https://github.com/sharkdp/bat) - Like `cat` but with line numbers, syntax highlighting, and scrolling.
- `boxes` - Used by `random-tip`
- `entr` - File change watcher
- `exa` - `ls` alternative
- `fzf` - Fuzzy finder
- `navi` - Interactive cheatsheets
- `nq` - Enqueue commands to run in the background
- `pspg` - Used by `viewer`
- [`pv`](https://catonmat.net/unix-utilities-pipe-viewer) - Show a progress bar for long-running commands.
- [`pxl`](https://github.com/ichinaski/pxl) - Display images in the terminal. Useful if you generate a chart and save it as an image.
- `tldr` - Cheatsheets
- `tmux`
- `trim` - Truncates output to fit in the terminal and prevent line wrapping (not scrollable). Useful for copy-pasting.
- `zellij`
- `zcat` from `zutils` - Used by `filter`.
- `zoxide` - Better directory traversal. Used by `g`.

### Aliases & Functions
These are shell constructs that can be used to save some keystrokes in an interactive session. However, they cannot be used in shell scripts.

|         Command | Alternative                                                  |
| ---------------:|:------------------------------------------------------------ |
|             `g` | `cd`                                                         |
|         `cheat` | `navi --print`                                               |
|   `cardinality` | `card`                                                       |
| `countdistinct` | `card`                                                       |
| `distinctcount` | `card`                                                       |
|    `stackcount` | `mfo`                                                        |
|     `shorttail` | `mfo`                                                        |
|      `longtail` | `lfo`                                                        |
|    `cv` / `cvt` | `viewer csv`                                                 |
|    `tv` / `tvt` | `viewer tsv`                                                 |
|    `zv` / `zvt` | `viewer zeek`                                                |
|           `z2z` | `zq -f zeek ${@} -`                                          |
|           `z2j` | `zq -f json ${@} -`                                          |
|           `z2c` | `zq -f csv ${@} -`                                           |
|           `z2t` | <code>sed -e '0,/^#fields\t/s///' &vert; grep -v '^#'</code> |
<!-- TODO: make these defined automatically -->

## Set Theory

|        Command | Purpose |
| --------------:|:------- |
|      `ipcount` |         |
|      `ipdiffs` |         |
|  `ipintersect` |         |
|      `ipunion` |         |
|      `setdiff` |         |
| `setintersect` |         |
|     `setunion` |         |
|   `rwsetbuild` |         |
|     `rwsetcat` |         |
|  `rwsetmember` |         |
|    `rwsettool` |         |

## IP Addresses

|    Command | Purpose |
| ----------:|:------- |
|  `cidr2ip` |         |
|  `ip2cidr` |         |
| `grepcidr` |         |

Also see [Set Theory](#set-theory).

## Other Tools
- `chronic`
- `combine`
- `dseq`
- `fd` - File finder. Like `find` but better.
- `gron`
- `hck`
- `header`
- `ifne`
- `jq`
- `json-cut` - Like `zeek-cut` but for JSON logs.
- `mlr` / `mlr5` / `mlr6`
- `pee`
- `rg`
- `sd`
- `sponge`
- `tsv-select`
- `ug` / `ugrep`
- `xsv`
- `zed`
- `zeek-cut`
- `zet`
- `zq`
- `zrun`

<!-- TODO: make these link to their homepages -->

## OSINT
### Online
- [`asn`](https://github.com/nitefood/asn)
- `dig`
- `mtr`
- `ncat`
- `netcat`
- `ping`
- `whois`
- `[[whois-bulk]]`

### Offline
- `bro-pdns`
- `ipcalc`
- `zannotate`
- `trace-summary` - Used by `conn-summary`.

## System Utils
These are for monitoring system resources and troubleshooting.

|     Command | Purpose                                                |
| -----------:|:------------------------------------------------------ |
|      `dust` | File size analyzer.                                    |
|      `htop` | System resource viewer. Like `top` but prettier.       |
| `hyperfine` | Benchmarking tool similar to `time` but more features. | 

## Text Editors
- `amp`
- `nano` - For those who have to have it
- `micro` - For `nano` users who want better while still staying simple
- `vim` - For emacs users who have not yet seen the light :P