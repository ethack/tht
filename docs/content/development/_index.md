---
title: "Development"
date: 2021-05-08
draft: false
weight: 1000
---

## Running

Clone the THT repo.

```bash
git clone https://github.com/ethack/tht.git
```

Then run THT in development mode.

```bash
cd tht
./tht --dev
```

This mounts certain files from this repository directly into the container which allows making changes to scripts without having to rebuild the image.

## Building Docker Image

You can build the image manually with the following command. However, the Maxmind geo information will not be included.

```bash
docker build -t ethack/tht .
```

If you want to build with Maxmind data, you'll need to sign up for a free [Maxmind license key](https://support.maxmind.com/account-faq/license-keys/where-do-i-find-my-license-key/). You can then specify your key when building.

```bash
docker build --build-arg MAXMIND_LICENSE=yourkeyhere -t ethack/tht .
```

## Building Documentation

You'll need [Hugo](https://gohugo.io/). Official install instructions are [here](https://gohugo.io/getting-started/installing) though the easiest way is to grab the latest [Github release](https://github.com/gohugoio/hugo/releases) for your platform. Hugo is a single binary so there's really not much to install.

Once you have Hugo you can compile and host the documentation locally with:

```bash
hugo -s docs server -D
```

Then access the local website http://localhost:1313 in your browser.

> Note:If you see a blank page or see warnings from hugo like `found no layout file` you need to download the theme, which you can do with:
> `git submodule update --init`