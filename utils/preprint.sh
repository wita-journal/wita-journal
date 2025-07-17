#!/bin/bash

### This script generates preprint for single article.

entry_dir="$(realpath --relative-to . "$1")"
EntryID="$(basename "$entry_dir")"
year="$(cut -d/ -f2 <<< "$entry_dir")"
IssueID="$(cut -d/ -f3 <<< "$entry_dir" | cut -d. -f1)"

mkdir -p workdir/preprint
(
    printf -- '\\input{utils/deps/preprint.H.tex}'
    # cat utils/deps/preprint.H.tex
    printf -- '\\setdocmetadata%s\n' "{$year}{$IssueID}{NaN}"
    # printf -- '\\addcitebib{%s}\n' "$EntryID"
    printf -- '\\addbibresource{%s/cite.bib}\n' "$entry_dir"
    printf -- '\\begin{document}\n'
    printf -- '\\importarticle{%s}\n' "$EntryID"
    # printf -- '\\input{%s}\n' "$entry_dir/main.tex"
    # cat "$entry_dir/main.tex"
    # printf -- '\\printbibliography\n'
    printf -- '\\end{document}\n'
) > "workdir/preprint/Preprint.$IssueID.$EntryID.tex"

jobname="Preprint.$IssueID.$EntryID"

ntex "workdir/preprint/$jobname.tex"
cp -av ".tmp/$jobname.bcf" "workdir/preprint/$jobname.bcf"
biber "workdir/preprint/$jobname"
cp -av "workdir/preprint/$jobname.bbl" ".tmp/$jobname.bbl"
ntex "workdir/preprint/$jobname.tex" --2
