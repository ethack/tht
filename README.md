# Threat Hunting Toolkit

[GitHub](https://github.com/ethack/tht) | [DockerHub](https://hub.docker.com/r/ethack/tht) | [Docs](https://ethack.github.io/tht/)

Container image with a suite of tools useful for threat hunting.

```diff
# THT can also stand for "Think Happy Thoughts" ;)
```

## Goals
- Small - Keep the main image size under 1 GB.
- Portable - Be able to load it up on any system. Nearly a given with Docker.
- Useful - Prune anything that doesn't get used. 

## Running

```bash
docker run --rm -it -h $(hostname) --init --pid host -v /etc/localtime:/etc/localtime -v /:/host -w "/host/$HOME" ethack/tht
```

Or

```bash
docker run --rm -it -h $(hostname) --init --pid host -v /etc/localtime:/etc/localtime -v /:/host -w "/host/$HOME" ghcr.io/ethack/tht
```

## Building Manually

If you want to build manually, you'll need to acquire a free [Maxmind license key](https://support.maxmind.com/account-faq/license-keys/where-do-i-find-my-license-key/).

```bash
docker build --build-arg MAXMIND_LICENSE=yourkeyhere -t ethack/tht .
```

## Future Ideas

Tools to add or investigate:
- [go command](https://blog.patshead.com/2011/05/my-take-on-the-go-command.html)
- [nnn](https://github.com/jarun/nnn), [ranger](https://github.com/ranger/ranger), or [midnight commander](https://midnight-commander.org/). File managers.
- tmux, [nq](https://github.com/leahneukirchen/nq), screen, and/or [byobou](https://www.byobu.org/)
- filter - This is a wrapper script I wrote to save keystrokes and make searching faster.
- [harpoon](https://github.com/Te-k/harpoon) - Threat intel from cli. Like TheHive Cortex. Will require lots of API keys.
- [VAST](https://github.com/tenzir/vast). I tried this awhile back and wasn't impressed. Take another look.
- sqlite - https://antonz.org/sqlite-is-not-a-toy-database/

Other ideas:
- Auto-increment version tags.
- Export container image tar (`docker image export`) and upload as release. Provide one-liner for installing using this method.
- Build portable versions of tools where possible and make available outside of docker (`docker cp`) then upload as release artifacts. [Ref](https://gist.github.com/ethack/6bd3a9551c02bbf8b404af0d2023114d). Go and Rust tools are generally good. C tools are good if compiled using musl.
- Test and provide usage with [Podman](https://podman.io/) and possibly [Buildah](https://buildah.io/).
- Create example usage guides around the tools. Use [Threat Hunting Labs](https://github.com/activecm/threat-hunting-labs/) and [Hugo Learn Theme](https://learn.netlify.app/en/) for inspiration.
    - `miller`
    - `zq`
    - `jq` w/ `awk`, `cut`, `grep`, etc.
    - `ugrep -Q`
    - `ripgrep`
- Create cheatsheets. Possibly use [navi](https://github.com/denisidoro/navi).
- Provide different image flavors. Similar to [Jupyter](https://jupyter-docker-stacks.readthedocs.io/en/latest/using/selecting.html) and [ml-workspace](https://github.com/ml-tooling/ml-workspace). Would love to have a heavy flavor that uses ml-workspace as a base. Here are possible candidates for that images.
    - Jupyter/Spark flavor
        - [VAST](https://github.com/tenzir/vast)
        - [ZAT](https://github.com/SuperCowPowers/zat)
    - Pcap flavor
        - Pcap tools for summarizing, combining, parsing, etc.
        - tcpdump, [termshark](https://termshark.io/) (will need special execution instructions for live capture)
        - [passer](https://github.com/activecm/passer)
        - https://github.com/brimdata/zed/tree/main/cmd/pcap
    - Julia flavor
        - https://github.com/KristofferC/OhMyREPL.jl
        - https://github.com/joshday/OnlineStats.jl
    - Download and include datasets (e.g. Microsoft's IP space).
  - [Azure IP Ranges and Service Tags – Public Cloud](https://www.microsoft.com/en-us/download/details.aspx?id=56519)
[Microsoft Public IP Space](https://www.microsoft.com/en-us/download/details.aspx?id=53602)
- Consider running `unminimize` and restoring man pages `apt install man-db`.
- I like the prompt that Kali uses.
- Create a rust/cargo builder image as well.

## Issues
- `fx` requires a JSON array to get the interactive features (e.g. `jq -s | fx`). I'm thinking fx isn't going to be too useful.
- `jiq` is super slow. `interactively 'jq -C'` is faster and better looking.
- Home and end keys don't seem to work in MobaXterm.
- All created files are owned by root. Change the user id and name of the container user to match the host and make sudo nopasswd the default.
- `g` zsh function is not loading
- Need to save `zoxide` database in a volume. Which probably means making a wrapper script.
- Problems installing `parallel`.