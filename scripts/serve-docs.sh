#!/bin/bash

# scripts/hugo -s docs server -D

docker run --rm -it -v $(pwd)/docs:/docs --workdir /docs -p 1313:1313 klakegg/hugo:asciidoctor server -D