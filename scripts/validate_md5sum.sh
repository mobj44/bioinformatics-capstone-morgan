#!/bin/bash

#!/usr/bin/env bash

# loop over the gz files
for i in ./data/illumina_data_reads/*.gz; do
  # get the sample name , e.g. AC2 from AC2_S144_R1_001.fastq.gz
  sample="$(echo "$(basename "$i")" | cut -d _ -f1)"

  # determine if file is R1 or R2
  if echo "$i" | grep -q "_R1_"; then
    # expected R1 md5 is column 6 
    expected="$(cat ./data/illumina_data_reads/DNA_sequencing_stats.csv | grep "^$sample" | cut -d , -f6)"
  else
    # expected R2 md5 is column 7 
    expected="$(cat ./data/illumina_data_reads/DNA_sequencing_stats.csv | grep "^$sample" | cut -d , -f7)"
  fi

  # actual md5 from the file
  actual="$(md5sum "$i" | cut -d ' ' -f1)"

  # compare and print
  if [ "$actual" = "$expected" ]; then
    echo "OK   $i"
  else
    echo "FAIL $i"
    echo "  expected: $expected"
    echo "  actual:   $actual"
  fi
done

