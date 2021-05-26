# Golang Builder Stage #
FROM golang:buster as go-builder

    # go get installs tools to /go/bin/
    RUN go get -v -u github.com/zmap/zannotate/cmd/zannotate
    # RUN go get -v -u github.com/brimdata/zed/cmd/zq
    RUN go get -v -u github.com/JustinAzoff/json-cut
    # Help find the path to the data you want
    RUN go get -v -u github.com/tomnomnom/gron
    # du alternative
    RUN go get -v -u github.com/viktomas/godu
    # TODO fzf https://github.com/junegunn/fzf/blob/master/BUILD.md or https://github.com/junegunn/fzf/blob/master/install

# Rust Builder Stage #
FROM rust:buster as rust-builder

    # cargo installs tools to /usr/local/cargo/bin/
    RUN git clone https://github.com/ogham/dog.git /tmp/dog \
     && cd /tmp/dog \
     && cargo build --release \
     && cargo test \
     && cp target/release/dog /usr/local/cargo/bin/
    RUN cargo install exa
    RUN cargo install fd-find
    RUN cargo install grex
    RUN cargo install hyperfine
    RUN cargo install ripgrep
    RUN cargo install zoxide

# C/C++ Builder Stage #
FROM ubuntu:hirsute as c-builder

    ENV DEBIAN_FRONTEND noninteractive
    ENV DEBCONF_NONINTERACTIVE_SEEN true

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
    RUN apt-get update && apt-get -y install --no-install-recommends wget make gcc g++ git
    # Version 3; change to "main" for latest
    ARG GREPCIDR_VERSION=b80b0c6ad1fce7f81bef0457a3e3b1208a3d76e3
    RUN git clone https://github.com/jrlevine/grepcidr3.git /tmp/grepcidr \
     && cd /tmp/grepcidr \
     && git checkout $GREPCIDR_VERSION \
     && make

    # TODO jq https://github.com/stedolan/jq
    # TODO pspg

    # ugrep
    RUN apt-get update && apt-get -y install --no-install-recommends git gcc g++ make libpcre2-dev libz-dev
    RUN git clone https://github.com/Genivia/ugrep.git /tmp/ugrep \
     && cd /tmp/ugrep \
     && ./build.sh

     # zeek-cut
    RUN apt-get update && apt-get -y install --no-install-recommends wget gcc
    RUN wget -nv -O /tmp/zeek-cut.c https://raw.githubusercontent.com/zeek/zeek-aux/master/zeek-cut/zeek-cut.c \
     && gcc --static -o /tmp/zeek-cut /tmp/zeek-cut.c

# Package Installer Stage #
# Pick 20.04 to get the latest possible version of each tool
FROM ubuntu:20.04 as base

# NOTE: Intentionally written with many layers for efficient caching
# and readability. All layers are squashed at the end.

## Setup ##
    ENV DEBIAN_FRONTEND noninteractive
    ENV DEBCONF_NONINTERACTIVE_SEEN true

    # Used for cache busting
    # COPY Dockerfile /tmp/
    RUN apt-get update

    # set default shell to zsh so apt automatically detects and adds zsh completions
    RUN apt-get -y install zsh
    SHELL ["zsh", "-c"]

## System Utils ##
    RUN apt-get -y install curl
    # ls alternative
    COPY --from=rust-builder /usr/local/cargo/bin/exa /usr/local/bin/
    # find alternative
    COPY --from=rust-builder /usr/local/cargo/bin/fd /usr/local/bin/
    # process monitor
    RUN apt-get -y install htop
    RUN apt-get -y install less
    # Pager
    RUN apt-get -y install pspg
    # RUN apt-get -y install parallel # problems with sysstat
    RUN apt-get -y install unzip
    RUN apt-get -y install wget
    RUN apt-get -y install vim

    # docker cli
    COPY --from=docker:20.10 /usr/local/bin/docker /usr/local/bin/

    # fzf - fuzzy finder
    ARG FZF_VERSION=0.27.1
    RUN wget -nv -O /tmp/fzf.tar.gz https://github.com/junegunn/fzf/releases/download/${FZF_VERSION}/fzf-${FZF_VERSION}-linux_amd64.tar.gz \
     && tar -xz -f /tmp/fzf.tar.gz -C /usr/local/bin/

    # godu - du alternative
    COPY --from=go-builder /go/bin/godu /usr/local/bin/

    # hyperfine - command benchmarking; like time on steroids
    COPY --from=rust-builder /usr/local/cargo/bin/hyperfine /usr/local/bin/

    # skim - run commands interactively and fzf alternative
    RUN wget -nv -O /tmp/skim.tar.gz https://github.com/lotabout/skim/releases/download/v0.9.4/skim-v0.9.4-x86_64-unknown-linux-musl.tar.gz \
     && tar -xz -f /tmp/skim.tar.gz -C /usr/local/bin/

    # zoxide - better directory traversal
    COPY --from=rust-builder /usr/local/cargo/bin/zoxide /usr/local/bin/

## Data Processing ##
    # lightweight stats
    RUN apt-get -y install datamash
    # CSV/TSV/JSON parser and lightweight streaming stats
    ARG MILLER_VERSION=5.10.2
    RUN wget -nv -O /usr/local/bin/mlr https://github.com/johnkerl/miller/releases/download/v${MILLER_VERSION}/mlr.linux.x86_64 \
     && chmod +x /usr/local/bin/mlr

    ### Grep ###
    # grep, sed, awk, etc
    RUN apt-get -y install coreutils
    # RUN apt-get -y install ripgrep
    COPY --from=rust-builder /usr/local/cargo/bin/rg /usr/local/bin/
    # RUN apt-get -y install ugrep
    COPY --from=c-builder /tmp/ugrep/bin/ugrep /usr/local/bin/
    COPY --from=c-builder /tmp/ugrep/bin/ug /usr/local/bin/

    COPY --from=rust-builder /usr/local/cargo/bin/grex /usr/local/bin/

    ### Zeek ###
    COPY --from=c-builder /tmp/zeek-cut /usr/local/bin/

    # zq - zeek file processor
    ARG ZQ_VERSION=0.29.0
    RUN wget -nv -O /tmp/zq.zip https://github.com/brimdata/zq/releases/download/v${ZQ_VERSION}/zq-v${ZQ_VERSION}.linux-amd64.zip \
     && unzip -j -d /tmp/ /tmp/zq.zip \
     && mv /tmp/zq /usr/local/bin/
    # COPY --from=go-builder /go/bin/zq /usr/local/bin/

    # trace-summary
    RUN apt-get -y install --no-install-recommends python3
    # install pysubnettree dependency with pip
    RUN apt-get -y install python3-pip
    RUN python3 -m pip install pysubnettree
    # remove pip (and auto dependencies further down) to save space
    RUN apt-get -y remove python3-pip
    RUN wget -nv -O /usr/local/bin/trace-summary https://raw.githubusercontent.com/zeek/trace-summary/master/trace-summary
    RUN chmod +x /usr/local/bin/trace-summary

    ### JSON ###
    RUN apt-get -y install jq

    COPY --from=go-builder /go/bin/json-cut /usr/local/bin/
    COPY --from=go-builder /go/bin/gron /usr/local/bin/

    ### IP Addresses ###
    RUN apt-get -y install ipcalc

    # SiLK IPSet
    COPY --from=c-builder /opt/silk/bin /usr/local/bin/
    COPY --from=c-builder /opt/silk/include /usr/local/include/
    COPY --from=c-builder /opt/silk/lib /usr/local/lib/
    COPY --from=c-builder /opt/silk/share /usr/local/share/

    # zannotate
    COPY --from=go-builder /go/bin/zannotate /usr/local/bin/
    ARG MAXMIND_LICENSE
    RUN mkdir -p /usr/share/GeoIP
    RUN wget -nv -O /tmp/geoip-country.tar.gz "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-Country&license_key=${MAXMIND_LICENSE}&suffix=tar.gz" \
     && tar -xz -f /tmp/geoip-country.tar.gz -C /tmp/ \
     && mv -f /tmp/GeoLite2-Country_*/GeoLite2-Country.mmdb /usr/share/GeoIP/ \
     || echo "Failed to download Maxmind Country data. Skipping."
    RUN wget -nv -O /tmp/geoip-asn.tar.gz "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-ASN&license_key=${MAXMIND_LICENSE}&suffix=tar.gz" \
     && tar -xz -f /tmp/geoip-asn.tar.gz -C /tmp/ \
     && mv -f /tmp/GeoLite2-ASN_*/GeoLite2-ASN.mmdb /usr/share/GeoIP/ \
     || echo "Failed to download Maxmind ASN data. Skipping."

     # grepcidr
     COPY --from=c-builder /tmp/grepcidr/grepcidr /usr/local/bin/

## Network Utils ##
    RUN apt-get -y install netcat
    RUN apt-get -y install whois
    # ping
    RUN apt-get -y install iputils-ping
    # dig
    RUN apt-get -y install dnsutils
    # dog - dig replacement
    RUN apt-get -y install libc6
    COPY --from=rust-builder /usr/local/cargo/bin/dog /usr/local/bin/

## Cleanup ##
    RUN apt-get -y autoremove
    RUN rm -rf /tmp/*

## Local scripts (moved to end for efficient caching)
    COPY bin/* /usr/local/bin/

## Customization ##
    COPY zsh/.zshrc /root/.zshrc

# Squash Layers Stage #
FROM scratch
COPY --from=base / /
CMD ["zsh"]

# Metadata #
LABEL org.opencontainers.image.source https://github.com/ethack/tht
