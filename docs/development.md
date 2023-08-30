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

### Alerts

```markdown
> [!NOTE]
> An alert of type 'note' using global style 'callout'.

> [!TIP]
> An alert of type 'tip' using global style 'callout'.

> [!WARNING]
> An alert of type 'warning' using global style 'callout'.

> [!ATTENTION]
> An alert of type 'attention' using global style 'callout'.

> [!NOTE|style:flat]
> An alert of type 'note' using alert specific style 'flat' which overrides global style 'callout'.
```

Create custom headings or change styling.
https://github.com/fzankl/docsify-plugin-flexible-alerts

### LaTeX

- [LaTeX](https://oeis.org/wiki/List_of_LaTeX_mathematical_symbols)

### Emoji

- [Emoji](https://docsify.js.org/#/emoji?id=emoji) supported directly by Docsify
- [Unicode Arrows](http://xahlee.info/comp/unicode_arrows.html)