#!/bin/bash

years_list="$(find office/archive/stream -name '*.tex' | cut -d/ -f5 | sort -ru)"

index_file=office/archive/stream-catalog.md
namespaces="P EB"

function work_on_file() {
    texfn="$1"
    d_title="$(grep TITLE= "$texfn" | head -n1 | cut -d= -f2-)"
    d_docid="$(basename "$texfn" | sed 's|.tex$||g')"
    printf '| %s | %s |\n' "$d_docid" "$d_title"
}

function work_on_year_pref() {
    year="$1"
    pref="$2"
    dir_path="office/archive/stream/$pref/$year"
    [[ ! -d "$dir_path" ]] && return 0 # Skip if no directory
    raw_list="$(find "$dir_path" -name '*.tex')"
    [[ 0 == "$(wc -l <<< "$raw_list")" ]] && return 0 # Skip if directory is empty
    prefexpl="$(grep "^$pref|" office/archive/stream/prefixes.txt | head -n1 | cut -d'|' -f2)"
    echo ''
    echo "### $prefexpl ($pref)"
    echo '| ID | Title |'
    echo '| --- | --- |'
    echo "$raw_list" | sort -t- -k2,2n | while read -r texfn; do
        work_on_file "$texfn"
    done
}

function work_on_year() {
    year="$1"
    echo ''
    echo "## $year"
    echo ''
    for pref in $namespaces; do
        work_on_year_pref "$year" "$pref"
    done
}

echo "# Archive Stream Catalog" > "$index_file"
for year in $years_list; do
    work_on_year "$year"
done >> "$index_file"


pandoc -f gfm -i "$index_file" -t html -o "${index_file/md/html}" --shift-heading-level-by=-1 -s || :
# --number-section


