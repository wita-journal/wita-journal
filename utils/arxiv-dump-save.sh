#!/bin/bash




### Paste from clipboard
if [[ ! -t 0 ]]; then
    mkdir -p .tmp/arxiv-dump-save
    cat /dev/stdin >> .tmp/arxiv-dump-save/staging.txt
fi



### Aggregate list
cat .tmp/arxiv-dump-save/staging.txt | sort -u > .tmp/arxiv-dump-save/staging.txt.2
mv .tmp/arxiv-dump-save/staging.txt.2 .tmp/arxiv-dump-save/staging.txt


(
    while read -r line; do
        [[ "$(wc -c <<< "$line")" -lt 8 ]] && continue
        f_id="$(cut -d'|' -f1 <<< "$line")"
        f_title="$(cut -d'|' -f2 <<< "$line")"
        printf '\\arxivdigestentry{%s}{%s}\n' "$f_id" "$f_title"
    done < .tmp/arxiv-dump-save/staging.txt
) > .tmp/arxiv-dump-save/staging.tex
