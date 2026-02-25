#!/bin/bash
set -e

INPUT=/input
OUTPUT=/output



for FILE in $INPUT/*.fna; do
  [ -e "$FILE" ] || { echo "No .fna files found"; exit 1; }

  BASE="$(basename "$FILE" .fna)"   

  quast.py $FILE -o "${OUTPUT}/${BASE}"
done
