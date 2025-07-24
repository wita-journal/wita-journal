#!/bin/bash


wrangler pages deploy website/www --project-name="weightintheattention" --commit-dirty=true --branch=main && printf "Upload finished\n\n"

if [[ -d ../wita-journal.github.io ]]; then
    rsync --dry-run -auvpx --mkpath website/www/ ../wita-journal.github.io/docs/
fi
