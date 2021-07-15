# Threat Hunting Toolkit

[GitHub](https://github.com/ethack/tht) | [DockerHub](https://hub.docker.com/r/ethack/tht) | [Docs](https://ethack.github.io/tht/)

The Threat Hunting Toolkit (THT) is a Swiss Army knife for threat hunting, log processing, and security-focused data science. Deploy the pre-configured container image onto any system rather than struggling with installation, configuration, or environment differences. You can be cleaning, filtering, sorting, data stacking, and more in no time.

## Goals

**Easy to Install**

- Small - Keep download size under 500 MB.
- Portable - Works across a variety of systems thanks to Docker.

**Fast to Learn**

- Consistent - You get the same environment configuration on every system, which means you can learn your tools once and use them everywhere.
<!-- - Bring your existing knowledge - Know SQL, Pandas, or R? Are you a grep/sed/awk wizard? Use the skills you already have and gradually introduce new ones into your existing workflow. -->
- Format Agnostic - Use the same tools to work with a variety of data formats including Zeek, CSV, TSV, and JSON. Avoid swapping between similar tools with annoying syntax variations for different formats.
- Remove Boilerplate - Remove the boilerplate for common use cases with the included custom scripts, shell functions, and aliases.
- Documented - There are guides, examples, and documentation available to get started right away.

**Fast to Run**

- Optimized - The tools, documentation, and custom wrappers are benchmarked to find the fastest when there are several options.
- Parallel - Many of the tools and documentation take advantage of multiple CPU cores to process data in parallel.

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

## Documentation

See [here](https://ethack.github.io/tht/) for the current documentation.

## License

The source code in this project is licensed under the [MIT license](LICENSE). The documentation in [docs/content/](docs/content/) is licensed under the [Creative Commons Attribution NonCommercial ShareAlike 4.0 International license](https://creativecommons.org/licenses/by-nc-sa/4.0/).