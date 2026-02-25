#!/bin/bash


# download_genomes.sh
# -------------------
# This script downloads genome assemblies from NCBI using a list of GCF_ or GCA_ accession numbers.
#ACKNOWLEDGEMENT THAT CHATGPT WAS USED TO ASSIST IN CREATING THIS FILE
# Usage: bash download_genomes.sh

# Requirements: NCBI Datasets CLI tool (https://www.ncbi.nlm.nih.gov/datasets/docs/v2/download-and-install/)
# Prior to running, accession file was Cleaned to remove carriage returns and empty lines
 #cat assembly_accessions.txt | tr -d '\r' | sed '/^$/d' > cleaned_accession.txt

WORKING_DIR="$(pwd)"

# Define input file (each line = one valid accession like GCF_000006945.2)
INPUT_FILE="${WORKING_DIR}/data/accession_files/cleaned_accession.txt"

# Define output directory for downloaded files
OUTPUT_DIR="${WORKING_DIR}/data/assemblies"
RAW_FASTA_DIR="${WORKING_DIR}/data/genomes_raw"

# Create folders if they don't exist
mkdir -p "$OUTPUT_DIR"
mkdir -p "$RAW_FASTA_DIR"

# Step 1: Download all assemblies in one ZIP
echo "Downloading assemblies listed in $INPUT_FILE..."
datasets download genome accession \
  --inputfile "$INPUT_FILE" \
  --include genome \
  --filename "$OUTPUT_DIR/genomes.zip"

# Step 2: Unzip the result
echo "Unzipping downloaded genomes..."
unzip -q "$OUTPUT_DIR/genomes.zip" -d "$OUTPUT_DIR"

# Step 3: Extract .fna files and copy to genomes_raw/
echo "Extracting .fna files..."
find "$OUTPUT_DIR" -name "*.fna" -exec cp {} "$RAW_FASTA_DIR" \;

echo "Done! FASTA files are in: $RAW_FASTA_DIR"