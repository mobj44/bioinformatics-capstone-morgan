#!/bin/bash
set -euo pipefail

INPUT=/input
OUTPUT=/output/panaroo
SELECTION=/selection/busco_filtered_accessions.txt

mkdir -p $OUTPUT
rm -f $OUTPUT/panaroo_inputs.txt

echo "Checking selection file..."
ls -l $SELECTION

echo "Building Panaroo input list..."
while read -r ACC; do
    ACC=$(echo "$ACC" | tr -d '"')
    GFF="$INPUT/${ACC}/${ACC}.gff3"

    if [ -f "$GFF" ]; then
        echo "$GFF" >> $OUTPUT/panaroo_inputs.txt
    else
        echo "Missing: $GFF"
    fi
done < $SELECTION

if [ ! -f $OUTPUT/panaroo_inputs.txt ]; then
    echo "No panaroo input file was created"
    exit 1
fi

if [ ! -s $OUTPUT/panaroo_inputs.txt ]; then
    echo "Panaroo input file is empty"
    exit 1
fi

echo "Running Panaroo"
cat $OUTPUT/panaroo_inputs.txt

panaroo \
    -i $(cat $OUTPUT/panaroo_inputs.txt) \
    -o $OUTPUT \
    -t 4 \
    --clean-mode strict \
    --remove-invalid-genes