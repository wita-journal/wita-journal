#!/bin/bash

### Use this script to build website from templates and data

issues_arr="$(find ../issue -name meta.json | cut -d/ -f4 | cut -c1-6 | grep -v 000000 | sort -u)"

while read -r IssueID; do
    cp -av "../issue/${IssueID:0:4}/$IssueID.tex.d/meta/meta.json" "data/issue-$IssueID.json" 
done <<< "$issues_arr"


while read -r IssueID; do
    year="${IssueID:0:4}"
    mkdir -p build/issue/"$year"
    mustache "data/issue-$IssueID.json" src/issue.html > "build/issue/$year/$IssueID.html"
done <<< "$issues_arr"



rsync -auvpx --mkpath build/ www/

find data -type f -delete
find build -type f -delete


[[ -n $PNG ]] && { find www/files/issue -name '*.pdf' | while read -r pdf; do
    # outpath="$pdf.png"
    pdftoppm -png -f 1 -l 1 -scale-to-y 2000 -singlefile "$pdf" "${pdf/.pdf/}"
done }
