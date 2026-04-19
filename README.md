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
| Bakta  | <version>   |   |
| Panaroo | | | 
| PPanGGOLiN | | |





### How to Use

1. Clone git repo.  
1. Navigate to project root. Everything will be run from here.  
1. Ensure Docker is installed and running.  
1. Run `./scripts/download_genomes.sh`  
1. Run `docker compose up -d busco`  
1. Run `./scripts/assembly_evaluation.py`    
1. View analysis `csv` files located in `analysis/assembly_evaluation/`  
1. Run `./scripts/analyze_busco_data.R` to filter out genomes with low busco scores
1. Run `docker compose up -d bakta` for Bakta annotation
1. Run 

## Naming Conventions and Directory Structure

```
.
├── analysis
│   ├── assembly_evaluation
│   └── README.md
├── bioinformatics-capstone-morgan.Rproj
├── data
│   ├── accession_files
│   ├── assemblies
│   ├── assembly_evaluation
│   ├── core_pan
│   ├── databases
│   ├── genome_annotation
│   ├── genomes_raw
│   └── README.md
├── docker-compose.yml
├── Dockerfile
├── LICENSE
├── README.md
├── rstudio_libs
└── scripts
    ├── analyze_busco_data.R
    ├── bakta_annotate.sh
    ├── assembly_evaluation.py
    ├── download_genomes.sh
    ├── panaroo_graphs.R
    ├── panaroo_pangenome.sh
    ├── ppanggolin_pangenome.sh
    ├── run_busco.sh
    └── visualize_pangenome.R
```
## BUSCO Analysis
Table: Genomes with a BUSCO above 90%

|accession_number | complete_percentage|     n50|
|:----------------|-------------------:|-------:|
|GCF_000022165.1  |                98.4| 4870265|
|GCF_000020925.1  |                98.4| 4842908|
|GCF_000020885.1  |                99.2| 4798660|
|GCF_000007545.1  |               100.0| 4791961|
|GCF_000170215.1  |                98.4| 4719855|
|GCF_000020745.1  |                98.4| 4709075|
|GCF_000171535.2  |               100.0| 3027433|
|GCF_000171415.1  |                98.4|  484233|
|GCF_000171515.1  |                93.5|  370713|

Table: Genomes with a BUSCO below 90%, removed from use going forward.

|accession_number | complete_percentage|    n50|
|:----------------|-------------------:|------:|
|GCF_000171255.1  |                80.6| 471765|
|GCF_000171315.1  |                67.7| 308442|
|GCF_000171275.1  |                67.7| 233156|
|GCF_000170255.1  |                69.4| 103713|

These scores were filtered using `./scripts/analyze_busco_data.R` this script filters by score and saves the results in a keep file that will be used in the pangenome analysis scripts. 

## Annotation with BAKTA
### Bakta Parameters

Mode: `-m genome`  
Lineage: `-l bacteria_odb10`

1. To get the Docker image run:
`docker pull quay.io/biocontainers/bakta:1.8.2--pyhdfd78af_0`

1. Download Bakta DB  
If you want the light database add use db-light instead of db  
    ```
    wget ./data/databases/https://zenodo.org/record/  10522951/files/db.tar.gz
    ```
    ```  
    md5sum ./data/database/db.tar.gz  
    ```
    The resuslt should match:  
    Full: f8823533b789dd315025fdcc46f1a8c1  
    Light: 31b3fbdceace50930f8607f8d664d3f4
    ```
    tar -xzf db.tar.gz  
    ```
    ```
    mv ./data/databases/db ./data/databases/bakta_db  
    ```

1. Run: `docker compose up -d bakta`

to watch the logs as this runs you can run 
`docker compose logs -f bakta`
when you want to exit logs: `ctrl+c`

## Pangenome analysis

### Panaroo

### PPanGGOLiN