# Golang Builder Stage #
FROM golang:buster as go-builder

    RUN go get -v -u github.com/zmap/zannotate/cmd/zannotate
    # RUN go get -v -u github.com/brimdata/zed/cmd/zq
    RUN go get -v -u github.com/JustinAzoff/json-cut
    # Go re-implementation of jq
    RUN go get -v -u github.com/itchyny/gojq/cmd/gojq
    # Help find the path to the data you want
    RUN go get -v -u github.com/tomnomnom/gron
    # du alternative
    RUN go get -v -u github.com/viktomas/godu

# C/C++ Builder Stage #
FROM ubuntu:hirsute as c-builder

    ENV DEBIAN_FRONTEND noninteractive
    ENV DEBCONF_NONINTERACTIVE_SEEN true

    RUN apt-get update

    # SiLK IPSet
    RUN apt-get -y install --no-install-recommends wget make gcc g++ libpcap-dev python python-dev libglib2.0-dev ca-certificates
    ARG IPSET_VERSION=3.18.0
    RUN wget -nv -O /tmp/silk-ipset.tar.gz https://tools.netsa.cert.org/releases/silk-ipset-${IPSET_VERSION}.tar.gz \
     && cd /tmp \
     && tar -xzf silk-ipset.tar.gz \
     && cd /tmp/silk-ipset-${IPSET_VERSION} \
     && ./configure --prefix=/opt/silk --enable-ipv6 --enable-ipset-compatibility=${IPSET_VERSION} \
     && make \
     && make install

# Package Installer Stage #
# Pick hirsute to get the latest possible version of each tool
FROM ubuntu:hirsute as base

# NOTE: Intentionally written with many layers for efficient caching
# and readability. All layers are squashed at the end.

## Setup ##
    ENV DEBIAN_FRONTEND noninteractive
    ENV DEBCONF_NONINTERACTIVE_SEEN true

    # Used for cache busting
    COPY Dockerfile /tmp/
    RUN apt-get update

    # set default shell to zsh so apt automatically detects and adds zsh completions
    RUN apt-get -y install zsh
    SHELL ["zsh", "-c"]

## System Utils ##
    RUN apt-get -y install curl
    # ls alternative
    RUN apt-get -y install exa
    # find alternative
    RUN apt-get -y install fd-find && ln -s $(which fdfind) /usr/local/bin/fd
    # fuzzy finder
    RUN apt-get -y install fzf
    # process monitor
    RUN apt-get -y install htop
    RUN apt-get -y install less
    # RUN apt-get -y install parallel # problems with sysstat
    RUN apt-get -y install unzip
    RUN apt-get -y install wget
    RUN apt-get -y install vim

    # broot - file lister and browser
    RUN apt-get -y install libxcb1
    RUN wget -nv -O /usr/local/bin/broot https://dystroy.org/broot/download/x86_64-linux/broot \
     && chmod +x /usr/local/bin/broot \
     && broot --install

    # godu - du alternative
    COPY --from=go-builder /go/bin/godu /usr/local/bin/

    # hyperfine - command benchmarking; like time on steroids
    ARG HYPERFINE_VERSION=1.11.0
    RUN wget -nv -O /tmp/hyperfine.deb https://github.com/sharkdp/hyperfine/releases/download/v${HYPERFINE_VERSION}/hyperfine_${HYPERFINE_VERSION}_amd64.deb
    RUN dpkg -i /tmp/hyperfine.deb

    # interactively - run commands interactively
    RUN wget -nv -O /usr/local/bin/interactively https://github.com/bigH/interactively/raw/master/bin/interactively \
     && chmod +x /usr/local/bin/interactively
    # for some infuriating reason [ -r ] and [ -w ] are only working in zsh and not bash
    RUN sed -i '0,/env bash$/s//env zsh/' /usr/local/bin/interactively

    # zoxide - better directory traversal
    ARG ZOXIDE_VERSION=0.5.0
    RUN wget -nv -O /usr/local/bin/zoxide https://github.com/ajeetdsouza/zoxide/releases/download/v${ZOXIDE_VERSION}/zoxide-x86_64-unknown-linux-musl \
     && chmod +x /usr/local/bin/zoxide

## Data Processing ##
    # lightweight stats
    RUN apt-get -y install datamash
    # CSV/TSV/JSON parser and lightweight streaming stats
    RUN apt-get -y install miller

    ### Grep ###
    # grep, sed, awk, etc
    RUN apt-get -y install coreutils
    RUN apt-get -y install ripgrep
    RUN apt-get -y install ugrep

    ARG GREX_VERSION=1.2.0
    RUN wget -nv -O /tmp/grex.tar.gz https://github.com/pemistahl/grex/releases/download/v${GREX_VERSION}/grex-v${GREX_VERSION}-x86_64-unknown-linux-musl.tar.gz \
     && tar -xz -f /tmp/grex.tar.gz -C /usr/local/bin/

    ### Zeek ###
    RUN apt-get -y install zeek-aux

    # zq - zeek file processor
    ARG ZQ_VERSION=0.29.0
    RUN wget -nv -O /tmp/zq.zip https://github.com/brimdata/zq/releases/download/v${ZQ_VERSION}/zq-v${ZQ_VERSION}.linux-amd64.zip \
     && unzip -j -d /tmp/ /tmp/zq.zip \
     && mv /tmp/zq /usr/local/bin/
    # COPY --from=go-builder /go/bin/zq /usr/local/bin/

    COPY bin/filter /usr/local/bin/

    # trace-summary
    RUN apt-get -y install --no-install-recommends python3
    # install pysubnettree dependency with pip
    RUN apt-get -y install python3-pip
    RUN python3 -m pip install pysubnettree
    # remove pip (and auto dependencies further down) to save space
    RUN apt-get -y remove python3-pip
    RUN wget -nv -O /usr/local/bin/trace-summary https://raw.githubusercontent.com/zeek/trace-summary/master/trace-summary
    RUN chmod +x /usr/local/bin/trace-summary
    COPY bin/conn-summary /usr/local/bin/

    ### JSON ###
    RUN apt-get -y install jq

    # fx - json processor
    # ARG FX_VERSION=20.0.2
    # RUN wget -nv -O /tmp/fx.zip https://github.com/antonmedv/fx/releases/download/${FX_VERSION}/fx-linux.zip \
    #  && unzip -j -d /usr/local/bin/ /tmp/fx.zip \
    #  && mv /usr/local/bin/fx-linux /usr/local/bin/fx

    COPY --from=go-builder /go/bin/json-cut /usr/local/bin/
    COPY --from=go-builder /go/bin/gojq /usr/local/bin/
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
     && mv -f /tmp/GeoLite2-Country_*/GeoLite2-Country.mmdb /usr/share/GeoIP/
    RUN wget -nv -O /tmp/geoip-asn.tar.gz "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-ASN&license_key=${MAXMIND_LICENSE}&suffix=tar.gz" \
     && tar -xz -f /tmp/geoip-asn.tar.gz -C /tmp/ \
     && mv -f /tmp/GeoLite2-ASN_*/GeoLite2-ASN.mmdb /usr/share/GeoIP/

## Network Utils ##
    RUN apt-get -y install netcat
    RUN apt-get -y install whois
    # ping
    RUN apt-get -y install iputils-ping
    # dig
    RUN apt-get -y install dnsutils
    # dog - dig replacement
    RUN apt-get -y install libc6
    ARG DOG_VERSION=0.1.0
    RUN wget -nv -O /tmp/dog.zip https://github.com/ogham/dog/releases/download/v${DOG_VERSION}/dog-v${DOG_VERSION}-x86_64-unknown-linux-gnu.zip \
     && unzip -j -d /tmp/ /tmp/dog.zip \
     && mv /tmp/dog /usr/local/bin/

## Customization ##
    COPY zsh/.zshrc /root/.zshrc
    COPY zsh/site-functions/* /usr/local/share/zsh/site-functions/

## Cleanup ##
    RUN apt-get -y autoremove
    RUN rm -rf /tmp/*

# Squash Layers Stage #
FROM scratch
COPY --from=base / /
CMD ["zsh"]

# Metadata #
LABEL org.opencontainers.image.source https://github.com/ethack/tht
