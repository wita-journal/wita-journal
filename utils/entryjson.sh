#!/bin/bash

### Use this script to generate JSON for entry, including the issue it belongs to

entry_dir="$(realpath --relative-to . "$1")"
toml_path="$entry_dir/info.toml"
eid="$(tomlq -r '.article[0].id' "$toml_path")"

(
    cat "$toml_path" | sed 's/\[\[article\]\]/[article]/'
    issue_toml="$(cut -d/ -f1-3 <<< "$entry_dir")/meta/meta.toml"
    map_toml="$(cut -d/ -f1-3 <<< "$entry_dir")/meta/map.toml"
    printf '%s = "%s"\n' "month" "$(tomlq -r .issue "$issue_toml" | cut -c5-6)"
    printf '%s = %s\n' "index" "$(tomlq -r ".\"$eid\"" "$map_toml")"
    printf -- '\n\n\n'
    echo '[issue]'
    cat "$issue_toml"
    echo '[map]'
    cat "$map_toml"
) | tomlq -r .
