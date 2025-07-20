#!/bin/bash

### Use this script to render blog posts
### Run from bulid.sh
### PWD should be $REPODIR/website

export TZ=UTC


function get_post_hash() {
    markdown="$1"
    sha256sum <<< "$markdown" | cut -c1-14
}

function process_mdfn() {
    markdown="$1"
    json="$(yq -arc . < "$markdown" | head -n1)"
    content="$(yq -arc . < "$markdown" | tail -n1)"
    echo "=============================== //"
    # echo "json=$json"
    # echo "content=$content"
    echo "-----------"
    yq -arc . < "$markdown"
    echo "// ==============================="
    # jq -r . <<< "$json"
    year="$(cut -d/ -f2 <<< "$markdown")"
    finaldir="www/blog/$year/$(get_post_hash "$markdown")"
    mkdir -p "$finaldir"
    # mustache <(echo "$json") src/templates/post.html > "$finaldir/index.html"
    # sed -i 's|!POSTBODY!|{{{postbody}}}|' "$finaldir/index.html"
    # mustache <(printf '{"postbody":%s}' "$content") "$finaldir/index.html" > "$finaldir/index.html.2"
    # mv "$finaldir/index.html.2" "$finaldir/index.html"

    ### Also write to data dir
    mkdir -p "data/blog/year/"
    function get_md_fm() {
        printf '%s = %s\n' "$1"  "$(jq ."$1" <<< "$json")"
    }
    post_toml="$(
        get_md_fm title
        get_md_fm author
        get_md_fm date
        printf '%s = "%s"\n' url "$(cut -d/ -f4- <<< "$finaldir")"
        printf '%s = "%s"\n' year "$year"
        printf '%s = %s\n' content "$content"
    )"
    (
        echo "[[post]]"
        echo "$post_toml"
    ) >> "data/blog/year/year-$year.toml"
    echo "$year" >> data/blog/years.txt

    ### Finally render HTML
    mustache <(tomlq . <<< "$post_toml") src/templates/post.html > "$finaldir/index.html"
    # sed -i 's|!POSTBODY!|{{{postbody}}}|' "$finaldir/index.html"
}



find data/blog -type f -delete

find _blog -name '*.md' | sort -r | while read -r mdfn; do
    echo "[INFO] Working on $mdfn"
    process_mdfn "$mdfn"
done

sort -ru data/blog/years.txt > data/blog/years.txt.2
mv data/blog/years.txt.2 data/blog/years.txt


echo "[INFO] Building blogyear ..."
while read -r year; do
    echo year="$year"
    mustache <( (echo "year = \"$year\""; cat "data/blog/year/year-$year.toml") | tomlq . ) src/templates/blogyear.html > "www/blog/$year/index.html"
done < data/blog/years.txt



echo "[INFO] Building blogroot ..."
while read -r year; do
    echo '[[year]]'
    echo "year_id = \"$year\""
done < data/blog/years.txt > data/blog/years.txt.toml
mustache <(tomlq . data/blog/years.txt.toml) src/templates/blogroot.html > "www/blog/index.html"
