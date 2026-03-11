#!/bin/bash

INPUT=/input
OUTPUT=/output

mkdir -p $OUTPUT

while read ACC; do
    ACC=$(echo "$ACC" | tr -d '"')

    GENOME="/input/${ACC}_*.fna"

    for file in $GENOME; do
        echo "Running Bakta for $ACC"

        bakta \
            --db /db/db \
            --output /output/"$ACC" \
            --prefix "$ACC" \
            --force \
            "$file"
    done

done < /selection/busco_filtered_accessions.txt