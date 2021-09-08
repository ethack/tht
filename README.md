<h1 align="center">
  THT &mdash; Threat Hunting Toolkit
</h1>

<h4 align="center">

[GitHub][github-url] |
[DockerHub][docker-url] |
[Docs][docs-url]

[![Docker Image Size][docker-size-badge]][docker-url]
[![Docker Pull Count][docker-pulls-badge]][docker-url]
[![MIT license][mit-badge]](#license)

</h4>

The Threat Hunting Toolkit (<span title="Think Happy Thoughts  (⌒‿⌒)">THT</span>) is a Swiss Army knife for threat hunting, log processing, and security-focused data science. It incorporates many CLI tools into one place for ease of deployment and includes wrappers and convenience features for ease of use. It comes packaged as a Docker image that can be deployed with a single command. Spend less time struggling with installation, configuration, or environment differences, and more on filtering, slicing, and data stacking.

## Features

**Easy to Install**

- Small - Keep download size under 500 MB.
- Portable - Works across a variety of systems thanks to Docker.

**Fast to Learn**

- Consistent - You get the same environment configuration on every system, which means you can have a familiar environment everywhere.
- Format Agnostic - Use the same processes to work with a variety of data formats including Zeek, CSV, TSV, and JSON. Avoid swapping between similar tools with annoying syntax variations for different formats.
- Remove Boilerplate - Remove the boilerplate for common use cases with the included custom scripts, shell functions, and aliases.
- Documented - There are guides, examples, and documentation available to get started right away.

**Fast to Run**

- Optimized - Everything is benchmarked to find the fastest methods when there are several options.
- Parallel - Many of the components take advantage of multiple CPU cores to process data in parallel.

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

<details>
<summary>You can also start THT with a docker command.</summary>

**From DockerHub**
```bash
docker run \
    --rm -it \
    -h $(hostname) \
    --init \
    --pid host \
    -v /etc/localtime:/etc/localtime \
    -v /:/host \
    -w "/host/$(pwd)" \
    ethack/tht
```

**From GitHub Container Registry**
```bash
docker run \
    --rm -it \
    -h $(hostname) \
    --init \
    --pid host \
    -v /etc/localtime:/etc/localtime \
    -v /:/host \
    -w "/host/$(pwd)" \
    ghcr.io/ethack/tht
```

</details>

However, you will lose all the convenience features the `tht` wrapper script provides.

If you'd like to build the image or documentation manually, see [here](https://ethack.github.io/tht/development/).

## Documentation

For the current documentation, see [here](https://ethack.github.io/tht/).

## License

The source code in this project is licensed under the [MIT license](LICENSE).

The [documentation](docs/content/) is licensed under the [CC BY-NC-SA 4.0 license][cc-url]. 


[github-url]: https://github.com/ethack/tht
[docker-url]: https://hub.docker.com/r/ethack/tht
[docs-url]: https://ethack.github.io/tht/

<!-- [![GitHub][github-badge]][github-url] -->
<!-- [![DockerHub][docker-badge]][docker-url] -->
<!-- [![Documentation][docs-badge]][docs-url] -->
<!-- [github-badge]: https://img.shields.io/badge/--181717?style=flat&logo=github&logoColor=white -->
<!-- [docker-badge]: https://img.shields.io/badge/--white?style=flat&logo=docker -->
<!-- [docs-badge]: https://img.shields.io/badge/--EEEEEE?style=flat&logo=readthedocs -->
<!-- [github-badge]: https://badgen.net/badge/icon/GitHub?icon=github&label&color=black -->
<!-- [docker-badge]: https://badgen.net/badge/icon/DockerHub?icon=docker&label&color=blue -->
<!-- [docs-badge]: https://badgen.net/badge/icon/Docs?icon=terminal&label&color=green -->

[docker-size-badge]: https://badgen.net/docker/size/ethack/tht
[docker-pulls-badge]: https://badgen.net/docker/pulls/ethack/tht
<!-- [docker-size-badge]: https://img.shields.io/docker/image-size/ethack/tht?sort=date -->
<!-- [docker-pulls-badge]: https://img.shields.io/docker/pulls/ethack/tht?label=pulls -->

[mit-badge]: https://badgen.net/badge/license/MIT/green
<!--[![CC BY-NC-SA 4.0 license][cc-badge]][cc-url]-->
<!-- [cc-badge]: https://licensebuttons.net/l/by-nc-sa/4.0/80x15.png -->
<!-- [cc-url]: https://creativecommons.org/licenses/by-nc-sa/4.0/ -->
<!-- [mit-badge]: https://img.shields.io/badge/License-MIT-blue.svg -->
<!-- [cc-badge]: https://licensebuttons.net/l/by-nc-sa/4.0/88x31.png -->
