#!/bin/bash
FILE="$1"
convert "$FILE" -white-threshold 90% "${FILE%%.pdf}.mod1.pdf"
pdfcrop --margins "0 0 0 -30" "${FILE%%.pdf}.mod1.pdf" "${FILE%%.pdf}.mod.pdf"
rm "${FILE%%.pdf}.mod1.pdf"
