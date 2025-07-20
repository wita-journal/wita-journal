#!/bin/bash
### Use this script to build website from templates and data
### PWD should be $REPODIR/website


### Purge working cache dir...?
# find data -type f -delete
# find build -type f -delete



(cd src && bash build.sh)


issues_arr="$(find ../issue -name dist.json | cut -d/ -f4 | cut -c1-6 | grep -v 000000 | sort -ur)"


### Step: Fetch issues data
while read -r IssueID; do
    year="${IssueID:0:4}"
    mkdir -p "data/issue/$year"
    cp -av "../issue/${IssueID:0:4}/$IssueID.tex.d/meta/dist.json" "data/issue/$year/$IssueID.json" 
    mkdir -p "build/issue/$year/$IssueID"
    mustache "data/issue/$year/$IssueID.json" src/templates/issue.html > "build/issue/$year/$IssueID/index.html"
done <<< "$issues_arr"



# ### Step: All articles
while read -r IssueID; do
    year="${IssueID:0:4}"
    issue_dir="../issue/$year/$IssueID.tex.d"
    seq=0
    while read -r EntryID; do
        seq=$((seq+1))
        mkdir -p "data/entry/$year" "build/issue/$year/$IssueID"
        (cd .. && bash utils/entryjson.sh "issue/$year/$IssueID.tex.d/entry/$EntryID") > "data/entry/$year/$EntryID.json"
        mustache "data/entry/$year/$EntryID.json" src/templates/entry.html > "build/issue/$year/$IssueID/$IssueID.$seq.html"
    done < <(cut -d, -f1 < "$issue_dir/meta/toc.csv")
done <<< "$issues_arr"


### Step: Generate homepage
mustache <(tomlq -r . site.toml) src/templates/home.html > "build/index.html"



### Step: Years
mkdir -p data/year
printf '' > data/years.txt
find ../issue/ -maxdepth 1 -mindepth 1 -type d | cut -d/ -f3 | sort -r | grep -v 0000 | while read -r year; do
    find "../issue/$year" -name dist.toml &&
    echo "$year" >> data/years.txt
done
(
    echo '[[year]]'
    while read -r year; do
        printf -- 'year_id = "%s"\n' "$year"
    done < data/years.txt
) | tomlq -r . > data/years.json
cat data/years.json
mustache data/years.json src/templates/yearslist.html > "build/issue/index.html"



### Step: Each year
while read -r year; do
    (
        printf -- 'year = "%s"\n' "$year"
        grep "^$year" <<< "$issues_arr" | sort -r | while read -r IssueID; do
            echo "[[issue]]"
            printf 'issue_id = "%s"\n' "$IssueID"
        done
    ) | tomlq -r . > "data/year/$year.json"
    mustache "data/year/$year.json" src/templates/year.html > "build/issue/$year/index.html"
done < data/years.txt



mkdir -p static/
rsync -auvpx --mkpath static/ www/static/
rsync -auvpx --mkpath ../vi/ www/static/vi/
rsync -auvpx --mkpath build/ www/
rsync -auvpx --mkpath data/ www/data/

bash blog.sh
