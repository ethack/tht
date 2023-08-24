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
|                    `skip` | **skips** elements and prints the rest         |                   `tail -n +2`                   |
|                     `ts2` | convert/truncate **timestamps**                |                                                  |
|                  `viewer` | displays results in a scrollable table         |                    `less -S`                     |
|          `[[whois-bulk]]` | bulk lookups on IPs for ASN and owning Orgs    |                     `whois`                      |


## Shell Utils
These are purely to enhance the interactive shell experience of THT.
- [`bat`](https://github.com/sharkdp/bat) - Like `cat` but with line numbers, syntax highlighting, and scrolling.
- `boxes` - Used by `random-tip`
- `cheat` - Cheatsheet browser
- `entr` - File change watcher
- `exa` - `ls` alternative
- `fzf` - Fuzzy finder
- `navi` - Interactive cheatsheets
- `nq` - Enqueue commands to run in the background
- `pspg` - Used by `viewer`
- [`pv`](https://catonmat.net/unix-utilities-pipe-viewer) - Show a progress bar for long-running commands.
- `random-tip` - prints a random cheatsheet tip entry
- `tldr` - Cheatsheets
- `tmux` - Terminal multiplexer
- `trim` - Truncates output to fit in the terminal and prevent line wrapping (not scrollable). Useful for copy-pasting.
- `zellij` - Terminal workspace (like `tmux`)
- `zcat` from `zutils` - Used by `filter`.
- `zoxide` - Better directory traversal. Used by `g`.

### Aliases & Functions
These are shell constructs that can be used to save some keystrokes in an interactive session. However, they cannot be used in shell scripts.

|         Command | Purpose                                                                     | Alternative                                                  |
| ---------------:|:----------------------------------------------------------------------------|:------------------------------------------------------------:|
|             `g` | Change directories by frecency and list contents                            | `cd`                                                         |
|         `cheat` | View the included cheatsheets                                               | `navi --print`                                               |
|    `cv` / `cvt` | Pipe CSV logs to `cv` for an interactive pager or `cvt` for an ascii table  | `viewer csv`                                                 |
|    `tv` / `tvt` | Pipe TSV logs to `tv` for an interactive pager or `tvt` for an ascii table  | `viewer tsv`                                                 |
|    `zv` / `zvt` | Pipe Zeek logs to `zv` for an interactive pager or `zvt` for an ascii table | `viewer zeek`                                                |
|           `z2z` | Convert (any) Zeek logs to Zeek TSV format                                  | `zq -f zeek ${@} -`                                          |
|           `z2j` | Convert (any) Zeek logs to JSON format                                      | `zq -f json ${@} -`                                          |
|           `z2c` | Convert Zeek logs logs to CSV format                                        | `zq -f csv ${@} -`                                           |
|           `z2t` | Convert Zeek logs to TSV (not Zeek) format                                  | <code>sed -e '0,/^#fields\t/s///' &vert; grep -v '^#'</code> |
<!-- TODO: make these defined automatically -->

## Set Theory

|        Command | Purpose                                      |
| --------------:|:-------------------------------------------- |
|      `ipcount` | Count number of IP addresses in ranges       |
|      `ipdiffs` |                                              |
|  `ipintersect` | IPs that intersect given ranges              |
|      `ipunion` | Union of all IP ranges                       |
|      `setdiff` | Set difference for newline separated lists   |
| `setintersect` | Set intersection for newline separated lists |
|     `setunion` | Set union for newline separated lists        |
|          `zet` | Set operations all in one command            |

## IP Addresses

|    Command | Purpose                                                |
| ----------:|:------------------------------------------------------ |
|  `cidr2ip` | Convert CIDR ranges to list of individual IP addresses |
|  `ip2cidr` | Convert list of individual IP addresses to CIDR ranges |
| `grepcidr` | Membership test for given IP in CIDR ranges            |

Also see [Set Theory](#set-theory).

## Other Tools
- `combine`
- `duckdb` - Embedded OLAP SQL engine and database.
- `dseq`
- `fd` - File finder. Like `find` but better.
- `gron`
- `hck`
- `header`
- `ifne`
- `jq`
- `json-cut` - Like `zeek-cut` but for JSON logs.
- `mlr` - Miller
- `pee`
- `rg` - Ripgrep
- `sd`
- `sponge`
- `tsv-select`
- `ug` / `ugrep`
- `xsv` / `qsv` - Fash CSV / TSV processor.
- `zed`
- `zeek-cut`
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
- `zeek-pdns`
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