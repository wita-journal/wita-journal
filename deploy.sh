#!/bin/bash


wrangler pages deploy website/www --project-name="weightintheattention" --commit-dirty=true --branch=main && printf "Upload finished\n\n"

if [[ -d ../wita-journal.github.io ]]; then
    rsync -auvpx website/www/ ../wita-journal.github.io/docs/
    echo "[INFO] Remember to commit and push 'wita-journal.github.io' repo."
fi
