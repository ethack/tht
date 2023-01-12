## Setup

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

You can build the image manually with the following command.

```bash
docker build -t ethack/tht .
```

## Documentation

Start a local web server in the docs directory.

```bash
cd docs
python3 -m http.server 3000
```
Then access the local website http://localhost:3000 in your browser.

When you make changes, just force refresh your browser.