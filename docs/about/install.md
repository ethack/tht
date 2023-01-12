## Installation

The Threat Hunting Toolkit (THT) is the name of the project, a docker image, as well as a wrapper script for launching. While you can use the docker image manually, the recommended way is through the wrapper script.

This will install the `tht` script in `/usr/local/bin/tht`.

```bash
sudo curl -o /usr/local/bin/tht 'https://raw.githubusercontent.com/ethack/tht/main/tht' && sudo chmod +x /usr/local/bin/tht
```

> [!NOTE|style:flat]
> You will need docker to use THT. If you don't already have docker you can either install [Docker Desktop](https://docs.docker.com/get-docker/) or on Linux use this one-liner:
> 
> ```bash
> curl -fsSL https://get.docker.com | sh -
> ```

## Usage

Launch THT using the script you installed.

```bash
tht
```

This will give you a customized ZSH shell inside a new THT container. All the tools and examples from this documentation can now be used. 

> [!TIP|style:flat]
> Your host's filesystem is accessible from `/host`.

## Updating

This will pull the latest image as well as latest `tht` script.

```bash
tht update
```

## Advanced Usage

With `tht` you can also execute scripts from your host that run within the context of a THT container. The usage is much like you would with a shell such as `bash` or `zsh`. This is useful if you want to automate or schedule certain tasks from the host system.

This will run an existing script.

```bash
tht my_script.sh
```

You can provide a script on stdin like this:

```bash
tht <<\SCRIPT
message=GREAT!
echo -n "Running multiple commands "
echo -n "without escaping feels $message "
echo {1..3}
SCRIPT
```

    Running multiple commands without escaping feels GREAT! 1 2 3

Another example:

```bash
tht <<\SCRIPT
#!/usr/bin/env python3
print('Here is an example python program')
SCRIPT
```

    Here is an example python program

You can also use `tht` in a shell script's hash-bang where you would normally have your shell executable.

For instance, you might want to put a script like this in your host's cron scheduler `/etc/cron.hourly/pdns`.

```bash
#!/usr/local/bin/tht

cd /host/opt/zeek/logs/

nice flock -n "/host/tmp/pdns.lock" \
fd 'dns.*log' | sort | xargs -n 24 bro-pdns index
```

See the [cron/](https://github.com/ethack/tht/tree/main/cron) directory in the code repo for more examples of cron scripts.

> [!TIP|style:flat]
> You can use `tht` as a shell executable in [Ansible's `shell` module](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/shell_module.html). E.g. 
> ```yaml
> - name: Count the number of HTTP server errors to POST requests
>   ansible.builtin.shell: |
>     echo -n "Number of HTTP server errors to POSTs: "
>     filter --http POST 500 | count
>   args:
>     executable: /usr/local/bin/tht
>     chdir: "/opt/zeek/logs"
> ```


