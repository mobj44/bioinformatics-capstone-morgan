#!/bin/bash
set -euo pipefail

INPUT=/input
OUTPUT=/output/ppanggolin
SELECTION=/selection/busco_filtered_accessions.txt
GENOMES_LIST=$OUTPUT/genomes.tsv

mkdir -p "$OUTPUT"
rm -f "$GENOMES_LIST"

echo "Checking selection file..."
ls -l "$SELECTION"

echo "Building PPanGGOLiN input list..."
while read -r ACC; do
    ACC=$(echo "$ACC" | tr -d '"')
    BGFF="$INPUT/${ACC}/${ACC}.gbff"

    if [ ! -f "$BGFF" ]; then
        echo "Missing: $GBFF"
        continue
    fi

    BAD_CDS=$(awk -F'\t' '
    $0 !~ /^#/ && $3=="CDS" && $9 !~ /(^|;)locus_tag=/ {count++}
    END {print count+0}
    ' "$BGFF")

    if [ "$BAD_CDS" -gt 0 ]; then
        echo "Skipping $ACC: $BAD_CDS CDS entries missing locus_tag"
        continue
    fi

    echo -e "${ACC}\t${BGFF}" >> "$GENOMES_LIST"
done < "$SELECTION"

if [ ! -f "$GENOMES_LIST" ]; then
    echo "No PPanGGOLiN input file was created"
    exit 1
fi

if [ ! -s "$GENOMES_LIST" ]; then
    echo "PPanGGOLiN input file is empty"
    exit 1
fi

echo "Running PPanGGOLiN"
cat "$GENOMES_LIST"

ppanggolin all \
    --anno "$GENOMES_LIST" \
    --output "$OUTPUT" \
    --cpu 4 \
    -f