#!/bin/bash


echo "[INFO] To to https://arxiv.org/list/cs/recent?skip=0&show=2000"
echo '      $' xclip -selection clipboard '<' utils/arxiv-list-extract.js

echo "[INFO] After copying from browser web console..."
echo '      $' xclip -selection clipboard -o '|' bash utils/arxiv-dump-save.sh
