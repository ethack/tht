# Threat Hunting Toolkit

[GitHub](https://github.com/ethack/tht) | [DockerHub](https://hub.docker.com/r/ethack/tht) | [Docs](https://ethack.github.io/tht/)

Container image with a suite of tools useful for threat hunting. Download a pre-configured environment onto any system rather than struggling to install and configure everything yourself.

## Goals
- Small - Keep download size under 500 MB.
- Portable - Be able to load it up on a variety of systems.
- Useful - Prune anything that doesn't get used. Provide guides and documentation on how to use the tools.

## Running

The recommended method to run THT is with the wrapper script included in the repo.

**Download and install**
```bash
sudo curl -o /usr/local/bin/tht https://raw.githubusercontent.com/ethack/tht/main/tht && sudo chmod +x /usr/local/bin/tht
```

**Run**
```bash
tht
```

You can also start THT with a docker command. This method will not have all the same convenience features as the wrapper script.

**From DockerHub**
```bash
docker run --rm -it -h $(hostname) --init --pid host -v /etc/localtime:/etc/localtime -v /:/host -w "/host/$(pwd)" ethack/tht
```

**From GitHub Container Registry**
```bash
docker run --rm -it -h $(hostname) --init --pid host -v /etc/localtime:/etc/localtime -v /:/host -w "/host/$(pwd)" ghcr.io/ethack/tht
```

If you'd like to build the image or documentation manually, see [here](https://ethack.github.io/tht/development/).
