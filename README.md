<h1 align="center">Threat Hunting Toolkit</h1>

<p align="center">
  <a href="https://github.com/ethack/tht">GitHub</a> | 
  <a href="https://hub.docker.com/r/ethack/tht">DockerHub</a> | 
  <a href="https://ethack.github.io/tht/">Docs</a>
</p>

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
docker run --rm -it -h $(hostname) --init --pid host -v /etc/localtime:/etc/localtime -v /:/host -w "/host/$(pwd)" ethack/tht
```

**From GitHub Container Registry**
```bash
docker run --rm -it -h $(hostname) --init --pid host -v /etc/localtime:/etc/localtime -v /:/host -w "/host/$(pwd)" ghcr.io/ethack/tht
```

</details>

However, you will lose all the convenience features the `tht` wrapper script provides.

If you'd like to build the image or documentation manually, see [here](https://ethack.github.io/tht/development/).

## Documentation

For the current documentation, see [here](https://ethack.github.io/tht/).

## License

The source code in this project is licensed under the [MIT license](LICENSE). 

The [documentation](docs/content/) is licensed under the [CC BY-NC-SA 4.0 license](https://creativecommons.org/licenses/by-nc-sa/4.0/).

