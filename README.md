# bioinformatics-capstone-morgan

# Comparative Genomic Analysis of Phage Susceptibility in Salmonella enterica

## Purpose

This project uses comparative genomics to compare phage-susceptible and non-susceptible Salmonella enterica strains from the same serovar in order to identify differences in gene presence and absence. By finding genes that consistently appear in susceptible strains, this study aims to create a short list of candidate genes that can be tested in future phage susceptibility experiments.

## Data Source

Data was gathered from a previous study:

> Fricke WFMammel MK, McDermott PF, Tartera C, White DG, LeClerc JE, Ravel J, Cebula TA.2011.Comparative Genomics of 28 Salmonella enterica Isolates: Evidence for CRISPR-Mediated Adaptive Sublineage Evolution . J Bacteriol193:.https://doi.org/10.1128/jb.00297-11

### How the Sequences were generated

These genomes were originally generated using Sanger sequencing of fosmid libraries, as outlined in the above source publication.

## Tools Used

| Tool   | Version    | Notes                                            |
| ------ | ---------- | ------------------------------------------------ |
| Docker | v24.0.6    | All tools are containerized for reproducibility. |
| BUSCO  | v6.0.0_cv1 |
| QUAST  | v5.2.0     |

### Parameters

Mode: `-m genome`  
Lineage: `-l bacteria_odb10`

### How to Use

1. Clone git repo.  
1. Navigate to project root. Everything will be run from here.  
1. Ensure Docker is installed and running.  
1. Run `./scripts/download_genomes.sh`  
1. Run `docker compose up -d`  
1. Run `./scripts/assembly_evaluation.py`    
1. View analysis `csv` files located in `analysis/assembly_evaluation/`  

## Naming Conventions and Directory Structure

```
├── analysis
│   ├── assembly_evaluation
│   │   ├── busco_summary.csv
│   │   └── quast_summary.csv
├── data
│   ├── accession_files
│   ├── assemblies
│   │   └── ncbi_dataset
│   ├── assembly_evaluation
│   │   ├── busco
│   │   └── quast
│   └── genomes_raw
├── docker
│   └── quast
└── scripts
    ├── download_genomes.sh
    ├── run_busco.sh
    └── run_quast.sh
```
