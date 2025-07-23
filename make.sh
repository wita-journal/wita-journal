#!/bin/bash

export PATH="$PATH:$PWD/node_modules/libshneruthes/bin"

if [[ -e "$2" ]]; then
    for arg in "$@"; do
        ./make.sh "$arg" || exit $?
    done
    exit $?
fi

case "$1" in
    issue/ )
        exec ./make.sh issue/*/*.tex.d/
        ;;
    issue/*/*. )
        [[ -e "${1}tex" ]] && ./make.sh "${1}tex"
        ;;
    issue/*/*.tex.d/entry/*/ )
        issue_id="$(cut -d/ -f3 <<< "$1" | cut -d. -f1)"
        if [[ -e "${1}main.tex" ]]; then
            find .tmp               -name   "Preprint.$issue_id.*"      -delete
            find workdir/preprint   -name   "Preprint.$issue_id.*"      -delete
            bash utils/preprint.sh "$1"
        fi
        ;;
    issue/*/*.tex.d/ )
        ### Build for issue metadata
        tmp_prefix=".tmp/$(cut -d/ -f3 <<< "$1")"
        printf '' > "$tmp_prefix.map"
        printf '' > "$tmp_prefix.list"
        (
            ### Verbatim metadata
            cat "$1/meta/meta.toml"
            # entry_id_list="$(cut -d, -f1 < "$1/meta/toc.csv")"

            ### Articles
            counter=0
            while read -r line; do
                counter=$((counter+1))
                id="$(cut -d, -f1 <<< "$line")"
                toml_path="$1/entry/$id/info.toml"
                ### Some to map
                (
                    printf '"%s" = "%s"\n' "$id" "$counter"
                ) >> "$tmp_prefix.map"

                ### Some to list
                (
                    cat "$toml_path";
                    echo "index = $counter"
                ) >> "$tmp_prefix.list"
            done < "$1/meta/toc.csv"

            ### Send to stdout
            echo '[id_seq_map]'
            cat "$tmp_prefix.map"
            cat "$tmp_prefix.list"
        ) > "$1/meta/dist.toml"
        tomlq -r . "$1/meta/dist.toml" > "$1/meta/dist.json"
        cat "$1/meta/dist.toml"
        cp -av "$tmp_prefix.map" "$1/meta/map.toml"
        ;;

    issue/*/*.tex )
        ### Build LaTeX to PDF
        [[ -d "$1.d" ]] || exit 1
        ./make.sh "$1.d" || exit 1
        year="$(cut -d/ -f2 <<< "$1")"
        issue_id="$(cut -d/ -f3 <<< "$1" | cut -d. -f1)"
        find "issue/$year/" -name '*.bbl' -delete
        find "issue/$year/" -name '*.bcf' -delete
        find .tmp               -name   "$issue_id.*"      -delete
        ntex "$1"
        cp -av ".tmp/$issue_id.bcf" "issue/$year/$issue_id.bcf"
        biber "issue/$year/$issue_id"
        cp -av "issue/$year/$issue_id.bbl" ".tmp/$issue_id.bbl"
        ntex "$1" --2
        pdf_path="_dist/issue/$year/$issue_id.pdf"
        bash utils/splitpdf.sh "$pdf_path"
        pdftoppm -png -f 1 -l 1 -scale-to-y 2000 -singlefile "$pdf_path" "${pdf_path/.pdf/}"
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

    snswg/*/*.tex )
        ntex "$1"
        ;;
    vi | vi/ )
        ### Generate VI assets
        for sh in vi/sh/*.sh; do
            bash "$sh"
        done
        ;;
    website/ )
        for kk in issue entry snswg; do rsync -auvpx --mkpath _dist/$kk/ website/www/files/$kk/ ; done
        cd website && bash build.sh
        ;;
esac
