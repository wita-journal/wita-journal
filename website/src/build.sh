#!/bin/bash

bash sh/partial.sh

find proto -name '*.html' | cut -d/ -f2 | sed 's|.html$||' | while read -r class; do
    echo "[INFO] Working on $class ..."
    mustache partial.json "proto/$class.html" > "templates/$class.html"
done
