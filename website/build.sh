#!/bin/bash

### Use this script to build website from templates and data
(cd src && bash build.sh)

issues_arr="$(find ../issue -name meta.json | cut -d/ -f4 | cut -c1-6 | grep -v 000000 | sort -u)"

while read -r IssueID; do
    cp -av "../issue/${IssueID:0:4}/$IssueID.tex.d/meta/meta.json" "data/issue-$IssueID.json" 
done <<< "$issues_arr"


while read -r IssueID; do
    year="${IssueID:0:4}"
    mkdir -p build/issue/"$year"
    mustache "data/issue-$IssueID.json" src/templates/issue.html > "build/issue/$year/$IssueID.html"
done <<< "$issues_arr"



rsync -auvpx --mkpath ../vi/ www/static/vi/
rsync -auvpx --mkpath build/ www/
# mv build/home.html build/index.html

# find data -type f -delete
# find build -type f -delete
