# go get installs tools to /go/bin/
ARG GO_BIN=/go/bin
# cargo installs tools to /usr/local/cargo/bin/
ARG RUST_BIN=/usr/local/cargo/bin

# Golang Builder Stage #
FROM golang:buster as go-builder

    # Used for cache busting to grab latest version of tools
    COPY .cache-buster /tmp/

    # https://golang.org/ref/mod#version-queries
    RUN go install github.com/zmap/zannotate/cmd/zannotate@master
    RUN go install github.com/JustinAzoff/json-cut@master
    # Help find the path to the data you want
    RUN go install github.com/tomnomnom/gron@master
    # zeek passive dns
    RUN go install github.com/JustinAzoff/bro-pdns@main
    # pxl - image viewer
    RUN go install github.com/ichinaski/pxl@master

# Rust Builder Stage #
FROM rust:buster as rust-builder
    ARG RUST_BIN

    # Used for cache busting to grab latest version of tools
    COPY .cache-buster /tmp/

    RUN git clone https://github.com/ogham/dog.git /tmp/dog \
     && cd /tmp/dog \
     && cargo build --release \
     && cargo test \
     && cp target/release/dog $RUST_BIN
    RUN cargo install exa
    RUN cargo install fd-find
    RUN cargo install grex
    RUN cargo install hyperfine
    RUN cargo install ripgrep
    RUN cargo install zoxide
    RUN cargo install bat
    RUN cargo install xsv
    RUN cargo install du-dust --bin dust
    # RUN cargo install navi
    RUN cargo install tealdeer

# C/C++ Builder Stage #
FROM ubuntu:21.04 as c-builder

    ENV DEBIAN_FRONTEND noninteractive
    ENV DEBCONF_NONINTERACTIVE_SEEN true

    # Used for cache busting to grab latest version of tools
    COPY .cache-buster /tmp/

    # SiLK IPSet
    RUN apt-get update && apt-get -y install --no-install-recommends wget make gcc g++ libpcap-dev python python-dev libglib2.0-dev ca-certificates
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
    # TODO pspg

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

    # nq
    RUN apt-get update && apt-get -y install --no-install-recommends git ca-certificates gcc make
    ARG NQ_VERSION=master
    RUN git clone https://github.com/leahneukirchen/nq.git /tmp/nq \
     && cd /tmp/nq \
     && git checkout $NQ_VERSION \
     && make all

    # moreutils - https://joeyh.name/code/moreutils/
    RUN apt-get update && apt-get -y install --no-install-recommends make gcc git
    RUN git clone git://git.joeyh.name/moreutils /tmp/moreutils \
    && cd /tmp/moreutils \
    && make isutf8 ifdata ifne pee sponge mispipe lckdo parallel errno

    # boxes - https://boxes.thomasjensen.com/build.html
    RUN apt-get update && apt-get -y install --no-install-recommends make gcc git diffutils flex bison libunistring-dev libpcre2-dev vim-common
    ARG BOXES_VERSION=2.1.1
    RUN git clone -b v$BOXES_VERSION --depth=1 https://github.com/ascii-boxes/boxes /tmp/boxes \
    && cd /tmp/boxes \
    && make && make test

# Package Installer Stage #
FROM ubuntu:21.04 as base
ARG GO_BIN
ARG RUST_BIN
ENV BIN=/usr/local/bin
ENV ZSH_COMPLETIONS=/usr/share/zsh/vendor-completions


# NOTE: Intentionally written with many layers for efficient caching
# and readability. All layers are squashed at the end.

## Setup ##
    ENV DEBIAN_FRONTEND noninteractive
    ENV DEBCONF_NONINTERACTIVE_SEEN true

    # Used for cache busting to grab latest version of tools
    COPY .cache-buster /tmp/
    RUN apt-get update

    # set default shell to zsh so apt automatically detects and adds zsh completions
    RUN apt-get -y install zsh git curl wget
    SHELL ["zsh", "-c"]

## System Utils ##
    # bat - fancy cat
    COPY --from=rust-builder $RUST_BIN/bat $BIN
    # boxes
    RUN apt-get -y install libunistring2 libpcre2-32-0
    COPY --from=c-builder /tmp/boxes/out/boxes $BIN
    RUN wget -nv -O /usr/share/boxes https://raw.githubusercontent.com/ascii-boxes/boxes/master/boxes-config
    # docker cli
    # COPY --from=docker:20.10 /usr/local/bin/docker $BIN
    # dust - du alternative
    COPY --from=rust-builder $RUST_BIN/dust $BIN
    # entr - perform action on file change
    RUN apt-get -y install entr
    # exa - ls alternative
    COPY --from=rust-builder $RUST_BIN/exa $BIN
    # fd - find alternative
    COPY --from=rust-builder $RUST_BIN/fd $BIN
    RUN apt-get -y install file
    # fzf - fuzzy finder
    ARG FZF_VERSION=0.27.3
    RUN wget -nv -O /tmp/fzf.tar.gz https://github.com/junegunn/fzf/releases/download/${FZF_VERSION}/fzf-${FZF_VERSION}-linux_amd64.tar.gz \
     && tar -xz -f /tmp/fzf.tar.gz -C $BIN
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
    # COPY --from=rust-builder $RUST_BIN/navi $BIN
    # /root/.local/share/navi/
    ARG NAVI_VERSION=2.17.0
    RUN wget -nv -O /tmp/navi.tar.gz https://github.com/denisidoro/navi/releases/download/v${NAVI_VERSION}/navi-v${NAVI_VERSION}-x86_64-unknown-linux-musl.tar.gz \
     && tar -xzf /tmp/navi.tar.gz -C $BIN \
     && mkdir -p /root/.local/share/navi/cheats
    COPY zsh/.config/navi/config.yaml /root/.config/navi/config.yaml
    # tealdeer - tldr client
    COPY --from=rust-builder $RUST_BIN/tldr $BIN/
    COPY zsh/.config/tealdeer/config.toml /root/.config/tealdeer/config.toml
    RUN mkdir -p /usr/share/zsh/site-functions/ \
     && wget -nv -O /usr/share/zsh/site-functions/_tldr https://raw.githubusercontent.com/dbrgn/tealdeer/master/zsh_tealdeer
    # nq
    COPY --from=c-builder /tmp/nq/nq /tmp/nq/fq $BIN/
    #RUN apt-get -y install parallel
    # pspg - Pager
    RUN apt-get -y install pspg
    # pv - Pipeviewer
    RUN apt-get -y install pv
    RUN apt-get -y install --no-install-recommends python3 \
     && ln -s /usr/bin/python3 /usr/bin/python
    RUN apt-get -y install unzip
    # zoxide - better directory traversal
    COPY --from=rust-builder $RUST_BIN/zoxide $BIN

## Editors ##
    RUN apt-get -y install nano
    RUN (cd $BIN; curl https://getmic.ro | bash)
    RUN apt-get -y install --no-install-recommends vim

## Data Processing ##
    # CSV/TSV/JSON toolkit and lightweight streaming stats
    ARG MILLER_VERSION=5.10.2
    RUN wget -nv -O $BIN/mlr https://github.com/johnkerl/miller/releases/download/v${MILLER_VERSION}/mlr.linux.x86_64 \
     && chmod +x $BIN/mlr
    # CSV/TSV toolkit
    COPY --from=rust-builder $RUST_BIN/xsv $BIN
    # CSV/TSV toolkit
    ARG TSVUTILS_VERSION=2.2.0
    RUN wget -nv -O /tmp/tsv-utils.tar.gz https://github.com/eBay/tsv-utils/releases/download/v${TSVUTILS_VERSION}/tsv-utils-v${TSVUTILS_VERSION}_linux-x86_64_ldc2.tar.gz \
     && tar -xzf /tmp/tsv-utils.tar.gz -C /tmp \
     && mv /tmp/tsv-utils-v${TSVUTILS_VERSION}_linux-x86_64_ldc2/bin/keep-header $BIN \
     && mv /tmp/tsv-utils-v${TSVUTILS_VERSION}_linux-x86_64_ldc2/bin/csv2tsv $BIN \
    #  && mv /tmp/tsv-utils-v${TSVUTILS_VERSION}_linux-x86_64_ldc2/bin/number-lines $BIN \
     && mv /tmp/tsv-utils-v${TSVUTILS_VERSION}_linux-x86_64_ldc2/bin/tsv-append $BIN \
     && mv /tmp/tsv-utils-v${TSVUTILS_VERSION}_linux-x86_64_ldc2/bin/tsv-filter $BIN \
     && mv /tmp/tsv-utils-v${TSVUTILS_VERSION}_linux-x86_64_ldc2/bin/tsv-join $BIN \
    #  && mv /tmp/tsv-utils-v${TSVUTILS_VERSION}_linux-x86_64_ldc2/bin/tsv-pretty $BIN \
     && mv /tmp/tsv-utils-v${TSVUTILS_VERSION}_linux-x86_64_ldc2/bin/tsv-sample $BIN \
     && mv /tmp/tsv-utils-v${TSVUTILS_VERSION}_linux-x86_64_ldc2/bin/tsv-select $BIN \
     && mv /tmp/tsv-utils-v${TSVUTILS_VERSION}_linux-x86_64_ldc2/bin/tsv-split $BIN \
     && mv /tmp/tsv-utils-v${TSVUTILS_VERSION}_linux-x86_64_ldc2/bin/tsv-summarize $BIN \
     && mv /tmp/tsv-utils-v${TSVUTILS_VERSION}_linux-x86_64_ldc2/bin/tsv-uniq $BIN \
     && mv /tmp/tsv-utils-v${TSVUTILS_VERSION}_linux-x86_64_ldc2/extras/scripts/tsv-sort $BIN \
     && mv /tmp/tsv-utils-v${TSVUTILS_VERSION}_linux-x86_64_ldc2/extras/scripts/tsv-sort-fast $BIN

    # Misc useful tools from https://www.datascienceatthecommandline.com/
    ADD https://raw.githubusercontent.com/jeroenjanssens/dsutils/master/body $BIN
    ADD https://raw.githubusercontent.com/jeroenjanssens/dsutils/master/cols $BIN
    ADD https://raw.githubusercontent.com/jeroenjanssens/dsutils/master/header $BIN
    ADD https://raw.githubusercontent.com/jeroenjanssens/dsutils/master/dseq $BIN
    ADD https://raw.githubusercontent.com/jeroenjanssens/dsutils/master/trim $BIN
    RUN chmod +x $BIN/*

    ### Graphing ###
    RUN apt-get install -y colortest
    RUN apt-get -y install python3-pip
    RUN python3 -m pip install git+https://github.com/piccolomo/plotext#egg=plotext
    COPY --from=go-builder $GO_BIN/pxl $BIN

    ### Grep ###
    # grep, sed, awk, etc
    RUN apt-get -y install coreutils
    # RUN apt-get -y install ripgrep
    COPY --from=rust-builder $RUST_BIN/rg $BIN
    RUN wget -nv -O $ZSH_COMPLETIONS/_rg https://raw.githubusercontent.com/BurntSushi/ripgrep/master/complete/_rg
    # RUN apt-get -y install ugrep
    COPY --from=c-builder /tmp/ugrep/bin/ugrep $BIN
    COPY --from=c-builder /tmp/ugrep/bin/ug $BIN

    COPY --from=rust-builder $RUST_BIN/grex $BIN

    ### Zeek ###
    # bro-pdns - Passive DNS for Zeek logs
    COPY --from=go-builder $GO_BIN/bro-pdns $BIN

    # zeek-cut
    COPY --from=c-builder /tmp/zeek-cut $BIN/zeek-cut

    # zq - zeek file processor
    ARG ZQ_VERSION=0.31.0
    RUN wget -nv -O /tmp/zq.zip https://github.com/brimdata/zed/releases/download/v${ZQ_VERSION}/zed-v${ZQ_VERSION}.linux-amd64.zip \
     && unzip -j -d /tmp/ /tmp/zq.zip \
     && mv /tmp/zq $BIN

    # trace-summary
    # install pysubnettree dependency
    RUN apt-get -y install python3-pip
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

    # Maxmind geolocation data
    ARG MAXMIND_LICENSE
    RUN mkdir -p /usr/share/GeoIP
    RUN wget -nv -O /tmp/geoip-city.tar.gz "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-City&license_key=${MAXMIND_LICENSE}&suffix=tar.gz" \
     && tar -xz -f /tmp/geoip-city.tar.gz -C /tmp/ \
     && mv -f /tmp/GeoLite2-City_*/GeoLite2-City.mmdb /usr/share/GeoIP/ \
     || echo "Failed to download Maxmind City data. Skipping."
    RUN wget -nv -O /tmp/geoip-asn.tar.gz "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-ASN&license_key=${MAXMIND_LICENSE}&suffix=tar.gz" \
     && tar -xz -f /tmp/geoip-asn.tar.gz -C /tmp/ \
     && mv -f /tmp/GeoLite2-ASN_*/GeoLite2-ASN.mmdb /usr/share/GeoIP/ \
     || echo "Failed to download Maxmind ASN data. Skipping."

## Network Utils ##
    # dog - dig alternative
    RUN apt-get -y install libc6 \
     && wget -nv -O $ZSH_COMPLETIONS/_dog https://raw.githubusercontent.com/ogham/dog/master/completions/dog.zsh
    COPY --from=rust-builder $RUST_BIN/dog $BIN
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
    # Remove pip
    RUN apt-get -y remove python3-pip
    # Remove unecessary packages
    RUN apt-get -y autoremove

## Shell customization ##
    # cache file that powerline10k will grab on startup
    # ARG GITSTATUSD_VERSION=1.5.1
    # RUN wget -nv -O /tmp/gitstatusd-linux-x86_64.tar.gz https://github.com/romkatv/gitstatus/releases/download/v${GITSTATUSD_VERSION}/gitstatusd-linux-x86_64.tar.gz \
    #  && mkdir -p /root/.cache/gitstatus \
    #  && tar -xz -C /root/.cache/gitstatus -f /tmp/gitstatusd-linux-x86_64.tar.gz
    
    COPY zsh/.vimrc /root/
    COPY zsh/.zshrc /root/
    COPY zsh/.zlogout /root/
    # COPY zsh/.p10k.zsh /root/
    COPY zsh/.config/fd/ignore /root/.config/fd/ignore
    
    # zinit - plugin manager for zsh
    # svn required for some zinit functions
    RUN apt-get -y install subversion
    RUN git clone https://github.com/zdharma-continuum/zinit.git /root/.zinit
    # https://github.com/zdharma/zinit/issues/484#issuecomment-785665617
    RUN TERM=${TERM:-screen-256color} zsh -isc "@zinit-scheduler burst"

## Cleanup ##
    RUN rm -rf /tmp/*

# Squash layers #
FROM ubuntu:21.04
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
