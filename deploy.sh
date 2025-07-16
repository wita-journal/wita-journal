#!/bin/bash


wrangler pages deploy website/www --project-name="weightintheattention" --commit-dirty=true --branch=main && printf "Upload finished\n\n"
