# syntax=docker/dockerfile:1.3-labs
# Golang Builder Stage #
FROM golang:buster as go-builder

    # Used for cache busting to grab latest version of tools
    COPY .cache-buster /tmp/

    # https://golang.org/ref/mod#version-queries
    RUN go install github.com/zmap/zannotate/cmd/zannotate@master
    RUN go install github.com/JustinAzoff/json-cut@master
    # gron - help find the path to the json data you want
    RUN go install github.com/tomnomnom/gron@master
    # zeek passive dns
    RUN go install github.com/JustinAzoff/zeek-pdns@main
    # pxl - image viewer
    RUN go install github.com/ichinaski/pxl@master
    # geoipupdate - Maxmind data downloader
    #RUN go install github.com/maxmind/geoipupdate/v4/cmd/geoipupdate@master
    # miller - text delimited processor
    RUN go install github.com/johnkerl/miller/cmd/mlr@main
    # RUN go install github.com/brimdata/zync/cmd/zync@main

# Rust Builder Stage #
FROM rust:buster as rust-builder

    # Used for cache busting to grab latest version of tools
    COPY .cache-buster /tmp/

    # NOTE: try adding --locked if builds rail in the future

    # exa - fancy ls
    #RUN cargo install exa
    # fd - better find
    RUN cargo install fd-find
    # hyperfine - benachmarking
    RUN cargo install hyperfine
    # ripgrep - fast grep
    RUN cargo install ripgrep
    # zoxide - smart cd
    RUN cargo install zoxide
    # bat - fancy cat
    RUN cargo install bat
    # qsv - fast csv / text delimited processing
    # https://github.com/jqnatividad/qsv#installation
    RUN apt-get update && apt-get install -y clang \
     && cargo install qsv --locked --features feature_capable,apply,foreach,luau
    # RUN git clone https://github.com/jqnatividad/qsv /tmp/qsv \
    #  && cd /tmp/qsv \
    #  && cargo build --release --locked --features full,apply,foreach,generate,luau,to \
    #  && mv target/release/qsv /usr/local/cargo/bin
    # dust - file / directory size analyzer
    RUN cargo install du-dust --bin dust
    # tealdeer - tldr cheatsheet client
    RUN cargo install tealdeer
    # zellij - terminal multiplexer
    RUN cargo install zellij
    # amp - text editor
    RUN cargo install amp
    # sd - better find and replace (sed)
    RUN cargo install sd
    # frawk - fast awk (TODO: check readme for better build instructions)
    # RUN cargo +nightly install frawk --no-default-features --features use_jemalloc,allow_avx2,unstable
    #RUN cargo install frawk --no-default-features --features use_jemalloc,allow_avx2
    # zet - set operations on files
    RUN cargo install zet
    # huniq - sort | uniq with hashtables
    # https://github.com/koraa/huniq
    RUN cargo install huniq

# C/C++ Builder Stage #
FROM ubuntu:22.04 as c-builder

    ENV DEBIAN_FRONTEND noninteractive
    ENV DEBCONF_NONINTERACTIVE_SEEN true

    # Used for cache busting to grab latest version of tools
    COPY .cache-buster /tmp/

    # RUN apt-get update && apt-get -y install ca-certficates git gcc g++ make wget

    # SiLK IPSet
    RUN apt-get update && apt-get -y install --no-install-recommends wget make gcc g++ libpcap-dev python3 python3-dev libglib2.0-dev ca-certificates
    ARG IPSET_VERSION=3.18.0
    RUN wget -nv -O /tmp/silk-ipset.tar.gz https://tools.netsa.cert.org/releases/silk-ipset-${IPSET_VERSION}.tar.gz \
     && cd /tmp \
     && tar -xzf silk-ipset.tar.gz \
     && cd /tmp/silk-ipset-${IPSET_VERSION} \
     && ./configure --prefix=/opt/silk --enable-ipv6 --enable-ipset-compatibility=${IPSET_VERSION} \
     && make \
     && make install

     # grepcidr
    RUN apt-get update && apt-get -y install --no-install-recommends wget make gcc g++ git ca-certificates
    # Version 3; change to "main" for latest
    ARG GREPCIDR_VERSION=main
    RUN git clone https://github.com/jrlevine/grepcidr3.git /tmp/grepcidr \
     && cd /tmp/grepcidr \
     && git checkout $GREPCIDR_VERSION \
     && make

    # TODO jq https://github.com/stedolan/jq

    # pspg - pager
    RUN apt-get update && apt-get -y install --no-install-recommends wget make gcc g++ git ca-certificates libpq-dev libncurses-dev
    ARG PSPG_VERSION=5.7.8
    RUN git clone https://github.com/okbob/pspg.git /tmp/pspg \
     && cd /tmp/pspg \
     && git checkout $PSPG_VERSION \
     && ./configure \
     && make

    # ugrep
    RUN apt-get update && apt-get -y install --no-install-recommends git ca-certificates gcc g++ make libpcre2-dev libz-dev
    ARG UGREP_VERSION=master
    RUN git clone https://github.com/Genivia/ugrep.git /tmp/ugrep \
     && cd /tmp/ugrep \
     && git checkout $UGREP_VERSION \
     && ./build.sh

     # zeek-cut
    RUN apt-get update && apt-get -y install --no-install-recommends wget gcc
    RUN wget -nv -O /tmp/zeek-cut.c https://raw.githubusercontent.com/zeek/zeek-aux/master/zeek-cut/zeek-cut.c \
     && gcc --static -o /tmp/zeek-cut /tmp/zeek-cut.c

    # moreutils - https://joeyh.name/code/moreutils/
    RUN apt-get update && apt-get -y install --no-install-recommends make gcc git
    RUN git clone git://git.joeyh.name/moreutils /tmp/moreutils \
    && cd /tmp/moreutils \
    && make isutf8 ifdata ifne pee sponge mispipe lckdo parallel errno

    # boxes - https://boxes.thomasjensen.com/build.html
    RUN apt-get update && apt-get -y install --no-install-recommends make gcc git diffutils flex bison libunistring-dev libpcre2-dev vim-common
    ARG BOXES_VERSION=2.2.0
    RUN git clone -b v$BOXES_VERSION --depth=1 https://github.com/ascii-boxes/boxes /tmp/boxes \
    && cd /tmp/boxes \
    && make && make test

    # xe - https://github.com/leahneukirchen/xe
    RUN apt-get update && apt-get -y install --no-install-recommends make gcc git
    RUN git clone --depth=1 https://github.com/leahneukirchen/xe /tmp/xe \
    && cd /tmp/xe \
    && make all

# Package Installer Stage #
FROM ubuntu:22.04 as base
    # go install puts tools in /go/bin
    ENV GO_BIN=/go/bin
    # cargo puts tools in /usr/local/cargo/bin
    ENV RUST_BIN=/usr/local/cargo/bin
    # put all THT tools in /usr/local/bin
    ENV BIN=/usr/local/bin
    ENV ZSH_COMPLETIONS=/usr/share/zsh/vendor-completions

# NOTE: Intentionally written with many layers for efficient build caching
# and readability. All layers are squashed in the final stage.

## Setup ##
    ENV DEBIAN_FRONTEND noninteractive
    ENV DEBCONF_NONINTERACTIVE_SEEN true

    # Used for cache busting to grab latest version of tools
    COPY .cache-buster /tmp/
    RUN apt-get update

    # set default shell to zsh so apt automatically detects and adds zsh completions
    RUN apt-get -y install zsh git curl unzip wget
    SHELL ["zsh", "-c"]
    # let tht scripts run inside tht as well
    RUN ln -s /usr/bin/zsh /usr/local/bin/tht

## System Utils ##
    # bat - fancy cat
    COPY --from=rust-builder $RUST_BIN/bat $BIN
    # boxes
    RUN apt-get -y install libunistring2 libpcre2-32-0
    COPY --from=c-builder /tmp/boxes/out/boxes $BIN
    RUN wget -nv -O /usr/share/boxes https://raw.githubusercontent.com/ascii-boxes/boxes/master/boxes-config
    # dust - du alternative
    COPY --from=rust-builder $RUST_BIN/dust $BIN
    # entr - perform action on file change
    RUN apt-get -y install entr
    # exa - ls alternative
    ARG EXA_VERSION=0.10.1
    RUN wget -nv -O /tmp/exa.zip https://github.com/ogham/exa/releases/download/v${EXA_VERSION}/exa-linux-x86_64-v${EXA_VERSION}.zip \
     && unzip -d /tmp/exa /tmp/exa.zip \
     && mv /tmp/exa/bin/exa $BIN
    # fd - find alternative
    COPY --from=rust-builder $RUST_BIN/fd $BIN
    RUN apt-get -y install file
    # fzf - fuzzy finder
    ARG FZF_VERSION=0.42.0
    RUN wget -nv -O /tmp/fzf.tar.gz https://github.com/junegunn/fzf/releases/download/${FZF_VERSION}/fzf-${FZF_VERSION}-linux_amd64.tar.gz \
     && tar -xz -f /tmp/fzf.tar.gz -C $BIN
    ARG HCK_VERSION=0.9.2
    RUN wget -nv -O $BIN/hck https://github.com/sstadick/hck/releases/download/v${HCK_VERSION}/hck-linux-amd64 \
     && chmod +x $BIN/hck
    # htop - process monitor
    RUN apt-get -y install htop
    # hyperfine - command benchmarking; like time on steroids
    COPY --from=rust-builder $RUST_BIN/hyperfine $BIN
    RUN apt-get -y install less
    # moreutils
    COPY --from=c-builder /tmp/moreutils/chronic $BIN
    COPY --from=c-builder /tmp/moreutils/combine $BIN
    COPY --from=c-builder /tmp/moreutils/ifne $BIN
    COPY --from=c-builder /tmp/moreutils/pee $BIN
    COPY --from=c-builder /tmp/moreutils/sponge $BIN
    COPY --from=c-builder /tmp/moreutils/zrun $BIN
    # navi - cheatsheet
    # /root/.local/share/navi/
    ARG NAVI_VERSION=2.22.1
    RUN wget -nv -O /tmp/navi.tar.gz https://github.com/denisidoro/navi/releases/download/v${NAVI_VERSION}/navi-v${NAVI_VERSION}-x86_64-unknown-linux-musl.tar.gz \
     && tar -xzf /tmp/navi.tar.gz -C $BIN \
     && mkdir -p /root/.local/share/navi/cheats
    COPY zsh/.config/navi/config.yaml /root/.config/navi/config.yaml
    # tealdeer - tldr client
    COPY --from=rust-builder $RUST_BIN/tldr $BIN/
    COPY zsh/.config/tealdeer/config.toml /root/.config/tealdeer/config.toml
    RUN mkdir -p /usr/share/zsh/site-functions/ \
     && wget -nv -O /usr/share/zsh/site-functions/_tldr https://raw.githubusercontent.com/dbrgn/tealdeer/master/completion/zsh_tealdeer
    #RUN apt-get -y install parallel
    # xe - job execution
    COPY --from=c-builder /tmp/xe/xe $BIN
    COPY --from=c-builder /tmp/xe/_xe /usr/share/zsh/site-functions/_xe
    # pspg - Pager
    RUN apt-get -y install libpq5
    COPY --from=c-builder /tmp/pspg/pspg $BIN
    # pv - Pipeviewer
    RUN apt-get -y install pv
    # Python
    RUN apt-get -y install --no-install-recommends python3 python3-pip \
     && ln -s /usr/bin/python3 /usr/bin/python
    COPY --from=rust-builder $RUST_BIN/sd $BIN
    # zoxide - better directory traversal
    COPY --from=rust-builder $RUST_BIN/zoxide $BIN
    # zutils - better zcat
    RUN apt-get -y install zutils

## Terminal Multiplexers ##
    COPY --from=rust-builder $RUST_BIN/zellij $BIN
    RUN apt-get -y install tmux

## Editors ##
    RUN apt-get -y install nano
    RUN (cd $BIN; curl https://getmic.ro | bash)
    RUN apt-get -y install --no-install-recommends vim
    COPY --from=rust-builder $RUST_BIN/amp $BIN

## Data Processing ##
    # CSV/TSV/JSON toolkit and lightweight streaming stats
    COPY --from=go-builder $GO_BIN/mlr $BIN
    # VisiData
    #RUN apt-get -y install visidata
    # CSV/TSV toolkit
    COPY --from=rust-builder $RUST_BIN/qsv $BIN
    RUN ln -s $BIN/qsv $BIN/xsv
    # CSV/TSV toolkit
    ARG TSVUTILS_VERSION=2.2.0
    RUN wget -nv -O /tmp/tsv-utils.tar.gz https://github.com/eBay/tsv-utils/releases/download/v${TSVUTILS_VERSION}/tsv-utils-v${TSVUTILS_VERSION}_linux-x86_64_ldc2.tar.gz \
     && tar -xzf /tmp/tsv-utils.tar.gz -C /tmp \
     && mv /tmp/tsv-utils-v${TSVUTILS_VERSION}_linux-x86_64_ldc2/bin/tsv-select $BIN
    #COPY --from=rust-builder $RUST_BIN/frawk $BIN
    # DuckDB
    ARG DUCKDB_VERSION=0.8.1
    RUN wget -nv -O /tmp/duckdb.zip https://github.com/duckdb/duckdb/releases/download/v${DUCKDB_VERSION}/duckdb_cli-linux-amd64.zip \
     && unzip -d /tmp/duckdb /tmp/duckdb.zip \
     && mv /tmp/duckdb/duckdb $BIN

    # Misc useful tools from https://www.datascienceatthecommandline.com/
    RUN wget -nv -O $BIN/body https://raw.githubusercontent.com/jeroenjanssens/dsutils/master/body
    RUN wget -nv -O $BIN/cols https://raw.githubusercontent.com/jeroenjanssens/dsutils/master/cols
    RUN wget -nv -O $BIN/explain https://raw.githubusercontent.com/jeroenjanssens/dsutils/master/explain
    RUN wget -nv -O $BIN/header https://raw.githubusercontent.com/jeroenjanssens/dsutils/master/header
    RUN wget -nv -O $BIN/trim https://raw.githubusercontent.com/jeroenjanssens/dsutils/master/trim
    RUN chmod +x $BIN/*

    RUN apt-get -y install dateutils \
     && for d in /usr/bin/dateutils.*; do ln -s $d /usr/local/bin/${d##*.}; done

    COPY --from=rust-builder $RUST_BIN/zet $BIN
    COPY --from=rust-builder $RUST_BIN/huniq $BIN

    ### Graphing ###
    RUN apt-get -y install colortest
    #RUN python3 -m pip install git+https://github.com/piccolomo/plotext
    RUN python3 -m pip install 'plotext'

    ### Grep ###
    # grep, sed, awk, etc
    RUN apt-get -y install coreutils
    COPY --from=rust-builder $RUST_BIN/rg $BIN
    RUN wget -nv -O $ZSH_COMPLETIONS/_rg https://raw.githubusercontent.com/BurntSushi/ripgrep/master/complete/_rg
    COPY --from=c-builder /tmp/ugrep/bin/ugrep $BIN
    COPY --from=c-builder /tmp/ugrep/bin/ug $BIN

    ### Zeek ###
    # zeek-pdns - Passive DNS for Zeek logs
    COPY --from=go-builder $GO_BIN/zeek-pdns $BIN

    # zeek-cut
    COPY --from=c-builder /tmp/zeek-cut $BIN/zeek-cut

    # zq - zeek file processor
    ARG ZQ_VERSION=1.9.0
    RUN wget -nv -O /tmp/zq.tar.gz https://github.com/brimdata/zed/releases/download/v${ZQ_VERSION}/zed-v${ZQ_VERSION}.linux-amd64.tar.gz \
     && tar -xf /tmp/zq.tar.gz -C /tmp \
     && mv /tmp/zq $BIN
    #  && mv /tmp/zed $BIN
    # COPY --from=go-builder $GO_BIN/zync $BIN

    # TODO: set up a python-builder stage
    # trace-summary
    # install pysubnettree dependency
    RUN apt-get -y install build-essential python3-dev
    RUN python3 -m pip install pysubnettree
    RUN wget -nv -O $BIN/trace-summary https://raw.githubusercontent.com/zeek/trace-summary/master/trace-summary \
     && chmod +x $BIN/trace-summary

    ### JSON ###
    RUN apt-get -y install jq
    COPY --from=go-builder $GO_BIN/json-cut $BIN
    COPY --from=go-builder $GO_BIN/gron $BIN

    ### IP Addresses and OSINT ###
    # grepcidr
    COPY --from=c-builder /tmp/grepcidr/grepcidr $BIN

    # ipcalc
    RUN apt-get -y install ipcalc

    # SiLK IPSet
    COPY --from=c-builder /opt/silk/bin $BIN
    COPY --from=c-builder /opt/silk/include /usr/local/include/
    COPY --from=c-builder /opt/silk/lib /usr/local/lib/
    COPY --from=c-builder /opt/silk/share /usr/local/share/

    # zannotate
    COPY --from=go-builder $GO_BIN/zannotate $BIN
    RUN apt-get -y install geoipupdate

    RUN apt-get -y install --no-install-recommends aha bind9-host mtr-tiny ncat
    COPY <<-'EOF' $BIN/nmap
		#!/bin/bash

		# hacky wrapper script to fulfill this functionality and avoid installing nmap:
		# https://github.com/nitefood/asn/blob/1f794b9b26d10863070f9bf4fd9978c159d77542/asn#L1488

		echo "$3" | cidr2ip | sed 's/^/Nmap scan report for /g'
EOF
    RUN wget -nv -O $BIN/asn https://raw.githubusercontent.com/nitefood/asn/master/asn \
     && chmod +x $BIN/asn $BIN/nmap

## Network Utils ##
    # dig
    RUN apt-get -y install dnsutils
    # traceroute alternative
    RUN apt-get -y install mtr
    RUN apt-get -y install netcat
    # ping
    RUN apt-get -y install iputils-ping
    RUN apt-get -y install whois

## Cleanup ##
    # Strip binaries
    RUN apt-get -y install binutils
    RUN find /usr/local/bin -type f -exec strip {} \; || true
    RUN apt-get -y remove binutils
    # Remove unnecessary files
    RUN rm -rf /usr/share/icons
    # Remove unecessary packages
    RUN apt-get -y remove build-essential python3-dev
    RUN apt-get -y autoremove

## Shell customization ##
    COPY zsh/.vimrc /root/
    COPY zsh/.zshrc /root/
    COPY zsh/.zlogout /root/
    COPY zsh/.config/fd/ignore /root/.config/fd/ignore

    # sheldon - plugin manager for zsh (and others)
    ENV XDG_CONFIG_HOME /root/.config
    ARG SHELDON_VERSION=0.7.3
    RUN wget -nv -O /tmp/sheldon.tar.gz https://github.com/rossmacarthur/sheldon/releases/download/${SHELDON_VERSION}/sheldon-${SHELDON_VERSION}-x86_64-unknown-linux-musl.tar.gz \
     && tar -C /tmp -xzf /tmp/sheldon.tar.gz \
     && mv /tmp/sheldon $BIN
    COPY zsh/.config/sheldon /root/.config/sheldon
    RUN sheldon lock
    # technically, sheldon source also does a sheldon lock if it doesn't exist
    RUN sheldon source >/root/.config/sheldon/source.zsh
    # delete the binary; it's large and we don't need it at runtime
    RUN rm $BIN/sheldon

## Cleanup ##
    RUN rm -rf /tmp/*

# Squash layers #
FROM ubuntu:22.04

## Squash all previous layers ##
    COPY --from=base / /

## Local files ##
    COPY bin/* /usr/local/bin/
    COPY cheatsheets/* /root/.local/share/navi/cheats/

## Version info ##
    ARG THT_HASH=undefined
    RUN echo 'NAME="Threat Hunting Toolkit"' > /etc/tht-release \
     && echo "HASH=$THT_HASH" >> /etc/tht-release \
     && echo "DATE=$(date +%Y.%m.%d)" >> /etc/tht-release

CMD ["zsh"]

# Metadata #
LABEL org.opencontainers.image.source https://github.com/ethack/tht
