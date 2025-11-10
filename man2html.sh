#!/usr/bin/env bash
# Convert man page to HTML document

cd "$(dirname "$0")"

/usr/bin/man ./ochre.1 | ./cat2html > ochre.1.html
