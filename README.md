<h1 align="center">
    <a id="user-content-threat-hunting-toolkit" class="anchor" aria-hidden="true" href="#threat-hunting-toolkit">
        <svg class="octicon octicon-link" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true"><path fill-rule="evenodd" d="M7.775 3.275a.75.75 0 001.06 1.06l1.25-1.25a2 2 0 112.83 2.83l-2.5 2.5a2 2 0 01-2.83 0 .75.75 0 00-1.06 1.06 3.5 3.5 0 004.95 0l2.5-2.5a3.5 3.5 0 00-4.95-4.95l-1.25 1.25zm-4.69 9.64a2 2 0 010-2.83l2.5-2.5a2 2 0 012.83 0 .75.75 0 001.06-1.06 3.5 3.5 0 00-4.95 0l-2.5 2.5a3.5 3.5 0 004.95 4.95l1.25-1.25a.75.75 0 00-1.06-1.06l-1.25 1.25a2 2 0 01-2.83 0z"></path></svg>
    </a>
    Threat Hunting Toolkit
</h1>

<p align="center">
  <a href="https://github.com/ethack/tht">GitHub</a> | 
  <a href="https://hub.docker.com/r/ethack/tht">DockerHub</a> | 
  <a href="https://ethack.github.io/tht/">Docs</a>
</p>

The Threat Hunting Toolkit (<span title="Think Happy Thoughts  (⌒‿⌒)">THT</span>) is a Swiss Army knife for threat hunting, log processing, and security-focused data science. Deploy the pre-configured container image onto any system rather than struggling with installation, configuration, or environment differences. You can be cleaning, filtering, sorting, data stacking, and more in no time.

## Goals

**Easy to Install**

- Small - Keep download size under 500 MB.
- Portable - Works across a variety of systems thanks to Docker.

**Fast to Learn**

- Consistent - You get the same environment configuration on every system, which means you can have a familiar environment everywhere.
<!-- - Bring your existing knowledge - Know SQL, Pandas, or R? Are you a grep/sed/awk wizard? Use the skills you already have and gradually introduce new ones into your existing workflow. -->
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

