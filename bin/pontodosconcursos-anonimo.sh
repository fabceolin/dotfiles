#!/bin/bash
FILE="$1"
convert "$FILE" -white-threshold 90% "$FILE"
pdfcrop --margins "0 0 0 -30" "$FILE" "$FILE"
