#!/usr/bin/env bash

cd "$(dirname "$0")"

/usr/bin/man ./ochre.1 | ./cat2html > ochre.1.html
