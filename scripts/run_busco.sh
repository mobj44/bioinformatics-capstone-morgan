#!/bin/bash
set -e

IMG="ezlabgva/busco:v6.0.0_cv1"
THREADS=8

mkdir -p data/busco/busco_downloads

for f in data/genomes_raw/*.fna; do
  [ -e "$f" ] || { echo "No .fna files found"; exit 1; }
  name="${f%.fna}"

  docker run --rm \
    -v "$PWD:/work" -w /work \
    -v "$PWD/busco_downloads:/busco_downloads" \
    -e BUSCO_DOWNLOADS_DIR=data/busco/busco_downloads \
    "$IMG" \
    busco -i "$f" -f -l bacteria_odb10 -m genome -o data/busco/ -c "$THREADS"
done

