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

The recommended method to run THT is with the wrapper script included in the repo.

Download and install:
```bash
sudo curl -O /usr/local/bin/tht https://github.com/ethack/tht/raw/main/tht && sudo chmod +x /usr/local/bin/tht
```

Run:
```bash
tht
```

You can also start it without the wrapper script with a docker command. This method will not have all the same convenience features as the script.

From DockerHub:
```bash
docker run --rm -it -h $(hostname) --init --pid host -v /etc/localtime:/etc/localtime -v /:/host -w "/host/$(pwd)" ethack/tht
```

From GitHub Container Registry:
```bash
docker run --rm -it -h $(hostname) --init --pid host -v /etc/localtime:/etc/localtime -v /:/host -w "/host/$(pwd)" ghcr.io/ethack/tht
```

If you'd like to build the image or documentation manually, see [here](https://ethack.github.io/tht/development/).
