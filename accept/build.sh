#!/bin/bash

list_path="$1" # Example: /accept/0000/list.txt
year="$(cut -d/ -f2 <<< "$list_path")"

grep -v '^#' "$list_path" | while read -r line; do
    # date, sender, issue, letterid, author, title
    f_date="$(cut -d'|' -f1 <<< "$line")"
    f_sender="$(cut -d'|' -f2 <<< "$line")"
    f_issue="$(cut -d'|' -f3 <<< "$line")"
    f_letterid="$(cut -d'|' -f4 <<< "$line")"
    f_author="$(cut -d'|' -f5 <<< "$line")"
    f_title="$(cut -d'|' -f6- <<< "$line")"

    texfn="accept/$year/EB.$f_letterid.tex"
    cp accept/_tmpl-1.tex "$texfn"

    sed -i "s|f_date|$f_date|g" "$texfn"
    sed -i "s|f_sender|$f_sender|g" "$texfn"
    sed -i "s|f_issue|$f_issue|g" "$texfn"
    sed -i "s|f_letterid|$f_letterid|g" "$texfn"
    sed -i "s|f_author|$f_author|g" "$texfn"
    sed -i "s|f_title|$f_title|g" "$texfn"
done

cmd_run_alt="echo"
[[ "$2" == ! ]] && cmd_run_alt="command"
$cmd_run_alt ntex "accept/$year/EB.*.tex"
