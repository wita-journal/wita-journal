#!/bin/bash

mkdir -p vi/dist

# rsvg-convert vi/res/wm1.svg --format=pdf -o vi/dist/wm1.pdf
rsvg-convert vi/res/wm1.svg -h1600 -o vi/dist/wm1.png
magick vi/dist/wm1.png -trim +repage vi/dist/wm1.png
cp vi/dist/wm1.png vi/res/wm1.png
