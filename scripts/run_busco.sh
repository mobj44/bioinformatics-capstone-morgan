#!/bin/bash
set -e

INPUT=/input
OUTPUT=/output

for FILE in $INPUT/*.fna; do
  [ -e "$FILE" ] || { echo "No .fna files found"; exit 1; }

  BASE="$(basename "$FILE" .fna)"   

  busco \
  -i "$FILE" \
  -l bacteria_odb10 \
  -m genome \
  --out_path "$OUTPUT" \
  -o "$BASE"
done
