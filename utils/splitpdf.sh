#!/bin/bash

RAW_PDF_PATH="$1"
year="$(cut -d/ -f3 <<< "$RAW_PDF_PATH")"
issue_id="$(cut -d/ -f4 <<< "$RAW_PDF_PATH" | cut -d. -f1)"

dirname="issue/$year/$issue_id.tex.d/meta"
toml_path="$dirname/meta.toml"

[[ -e "$toml_path" ]] || { echo "[ERROR] Cannot find 'meta.toml' file for given PDF path!"; exit 1; }


EntrySeqCounter=0
while read -r entry_id; do
    EntrySeqCounter=$((EntrySeqCounter+1))
    # echo "$entry_id"
    # pages_range="$(tomlq -r ".pages[\"$entry_id\"]" "$toml_path")"
    pages_range="$(grep "^$entry_id," "$dirname/toc.csv" | cut -d, -f2 )"
    echo "id=$entry_id, range=$pages_range, counter=$EntrySeqCounter"
    # exit 0
    RANGED_PDF_PATH_DIR="_dist/entry/$year/$issue_id"
    RANGED_PDF_PATH="$RANGED_PDF_PATH_DIR/WITA.$issue_id.$EntrySeqCounter.pdf"
    mkdir -p "$RANGED_PDF_PATH_DIR"
    pdftk "$RAW_PDF_PATH" cat "$pages_range" output "$RANGED_PDF_PATH" || exit 1
    realpath "$RANGED_PDF_PATH" | xargs du -h
done <<< "$(cut -d, -f1 < "$dirname/toc.csv")"

