#!/bin/bash

export PATH="$PATH:$PWD/node_modules/libshneruthes/bin"

if [[ -e "$2" ]]; then
    for arg in "$@"; do
        ./make.sh "$arg" || exit $?
    done
    exit $?
fi

case "$1" in
    issue/*/*.tex.d/ )
        ### Build for issue metadata
        (
            cat "$1/meta/meta.toml"
            find "$1"/entry -type f -name info.toml | sort | while read -r toml_path; do
                cat "$toml_path"
            done
        ) | tomlq . > "$1/meta/meta.json"
        ;;

    issue/*/*.tex )
        ### Build LaTeX to PDF
        [[ -d "$1.d" ]] || exit 1
        year="$(cut -d/ -f2 <<< "$1")"
        issue_id="$(cut -d/ -f3 <<< "$1" | cut -d. -f1)"
        ntex "$1"
        cp -av ".tmp/$issue_id.bcf" "issue/$year/$issue_id.bcf"
        biber "issue/$year/$issue_id"
        cp -av "issue/$year/$issue_id.bbl" ".tmp/$issue_id.bbl"
        ntex "$1" --2
        pdf_path="_dist/issue/$year/$issue_id.pdf"
        bash utils/splitpdf.sh "$pdf_path"
        ;;

    issue/*/*.tex.d/meta/cover.js )
        ### Generate issue cover art
        node "$1"
        ./make.sh "$1.svg"
        ;;

    issue/*/*.tex.d/meta/cover.js.svg )
        ### Generate issue cover art
        rsvg-convert "$1" -h2100 --format=pdf -o "$1.pdf"
        ;;

    vi | vi/ )
        ### Generate VI assets
        for sh in vi/sh/*.sh; do
            bash "$sh"
        done
        ;;
esac
