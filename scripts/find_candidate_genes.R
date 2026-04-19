#!/usr/bin/env Rscript

library(tidyverse)

# Paths
panaroo_dir <- "./data/core_pan/panaroo"
ppanggolin_dir <- "data/core_pan/ppanggolin"

bakta_dir <- "data/genome_annotation/bakta"

base_output_dir <- "analysis/core_pan"

panaroo_output_dir <- file.path(base_output_dir, "panaroo")
ppanggolin_output_dir <- file.path(base_output_dir, "ppanggolin")

dir.create(base_output_dir, showWarnings = FALSE)
dir.create(panaroo_output_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(ppanggolin_output_dir, showWarnings = FALSE, recursive = TRUE)


# Bakta parser
parse_bakta_tsv <- function(filepath) {
  lines <- readLines(filepath, warn = FALSE)
  data_lines <- lines[!startsWith(lines, "#")]
  if (length(data_lines) == 0) return(NULL)
  
  df <- read.table(
    text = paste(data_lines, collapse = "\n"),
    sep = "\t",
    header = FALSE,
    fill = TRUE,
    stringsAsFactors = FALSE,
    quote = ""
  )
  
  colnames(df) <- c(
    "Sequence_ID", "Type", "Start", "Stop",
    "Strand", "Locus_Tag", "Gene", "Product", "DbXrefs"
  )[1:ncol(df)]
  
  df <- df[df$Type == "cds", , drop = FALSE]
  df$Source_File <- basename(dirname(filepath))
  df
}

# load bakta files
bakta_files <- list.files(
  bakta_dir,
  pattern = "\\.tsv$",
  recursive = TRUE,
  full.names = TRUE
)

bakta_files <- bakta_files[!grepl("hypotheticals", bakta_files, ignore.case = TRUE)]
cat(sprintf("Found %d Bakta TSV files\n", length(bakta_files)))

all_bakta <- bind_rows(lapply(bakta_files, parse_bakta_tsv))

# gets candidates 
run_candidate_pipeline <- function(pres_abs, core_genes, accessory_genes, core_locus_tags, out_dir, prefix, all_bakta) {
  
  # summary report
  report_file <- file.path(out_dir, "pangenome_summary.txt")
  lines <- c(
    paste("Total genes:", nrow(pres_abs)),
    paste("Core genes:", nrow(core_genes)),
    paste("Accessory genes:", nrow(accessory_genes)),
    paste("Core %:", round(nrow(core_genes) / nrow(pres_abs) * 100, 2), "%"),
    paste("Accessory %:", round(nrow(accessory_genes) / nrow(pres_abs) * 100, 2), "%")
  )
  writeLines(lines, report_file)
  
  # save raw rows
  write.csv(core_genes,
            file.path(out_dir, paste0(prefix, "_core_gene_rows.csv")),
            row.names = FALSE)
  
  write.csv(accessory_genes,
            file.path(out_dir, paste0(prefix, "_accessory_gene_rows.csv")),
            row.names = FALSE)
  
  # match core locus tags to Bakta
  core_annotated <- all_bakta %>%
    filter(Locus_Tag %in% core_locus_tags) %>%
    select(Locus_Tag, Gene, Product, DbXrefs, Source_File)
  
  cat(prefix, "- Matched annotated core loci:", nrow(core_annotated), "\n")
  
  core_products <- core_annotated %>%
    group_by(Product) %>%
    summarise(
      Gene_Name   = first(Gene[Gene != "" & !is.na(Gene)]),
      Count       = n(),
      Example_Tag = first(Locus_Tag),
      DbXrefs     = first(DbXrefs),
      .groups = "drop"
    ) %>%
    arrange(desc(Count))
  
  cat(prefix, "- Full core product count:", nrow(core_products), "\n")
  
  write.csv(core_products,
            file.path(out_dir, "core_genes_annotated.csv"),
            row.names = FALSE)
  
  receptor_keywords <- c(
    "outer membrane", "OmpA", "OmpC", "OmpD", "OmpF", "OmpN", "OmpX",
    "porin", "TonB", "lipopolysaccharide", "LPS", "O-antigen", "lipid A", "Kdo",
    "rfb", "waa", "wab", "lpx", "flagell", "flagellin", "FlgE", "FliC", "FljB",
    "fimbriae", "fimbrial", "pilus", "pilin", "type IV", "transporter", "channel",
    "permease", "surface", "membrane protein", "integral membrane",
    "receptor", "binding protein", "adhesin", "BtuB", "FhuA", "FepA",
    "IutA", "OmpT", "TraT", "Tsx", "LamB", "MaltoporinF"
  )
  
  pattern <- paste(receptor_keywords, collapse = "|")
  
  candidates <- core_products %>%
    filter(
      grepl(pattern, Product, ignore.case = TRUE) |
        grepl(pattern, Gene_Name, ignore.case = TRUE)
    )
  
  cat(prefix, "- Receptor candidates:", nrow(candidates), "\n")
  
  write.csv(candidates,
            file.path(out_dir, "receptor_candidates.csv"),
            row.names = FALSE)
  
  tier1_keywords <- c(
    "OmpF", "OmpC", "OmpD", "OmpA", "OmpX", "OmpW",
    "maltoporin", "LamB", "porin", "TolC",
    "FimH", "fimH", "type I fimbri", "Type 1 fimbri",
    "flagellin", "FliC", "FljB", "hook",
    "LPS-assembly", "LptD", "LptE",
    "lipopolysaccharide assembly", "PgtE", "omptin",
    "outer membrane protein", "outer membrane lipoprotein",
    "Ail", "PagC", "PagN", "TonB", "BtuB", "FhuA", "FepA",
    "Tsx", "DNA uptake porin"
  )
  
  tier2_keywords <- c(
    "fimbrial usher", "fimbrial outer membrane",
    "outer membrane pore", "flagellar hook",
    "flagellar L-ring", "flagellar P-ring", "flagellar basal",
    "autotransporter", "inverse autotransporter",
    "outer membrane beta-barrel", "salt-induced outer membrane",
    "surface-exposed", "virulence membrane", "adhesin"
  )
  
  pattern1 <- paste(tier1_keywords, collapse = "|")
  pattern2 <- paste(tier2_keywords, collapse = "|")
  
  tier1 <- candidates %>%
    filter(
      grepl(pattern1, Product, ignore.case = TRUE) |
        grepl(pattern1, Gene_Name, ignore.case = TRUE)
    ) %>%
    mutate(Priority = "Tier 1 - Known phage receptor class")
  
  tier2 <- candidates %>%
    filter(!Product %in% tier1$Product) %>%
    filter(
      grepl(pattern2, Product, ignore.case = TRUE) |
        grepl(pattern2, Gene_Name, ignore.case = TRUE)
    ) %>%
    mutate(Priority = "Tier 2 - Surface-associated")
  
  prioritized <- bind_rows(tier1, tier2) %>%
    arrange(Priority, desc(Count))
  
  write.csv(prioritized,
            file.path(out_dir, "prioritized_candidates.csv"),
            row.names = FALSE)
  
  cat(prefix, "- Tier 1:", nrow(tier1), "| Tier 2:", nrow(tier2), "\n")
  
  final_candidates <- prioritized %>%
    filter(!grepl(
      "microcompartment|BamB|BamC|BamD|BamE|regulator of flagellin|assembly factor|LPS-assembly lipoprotein LptM|Lipopolysaccharide assembly protein A|Lipopolysaccharide assembly protein B|autotransporter assembly|FtsX",
      Product, ignore.case = TRUE
    )) %>%
    filter(
      !Gene_Name %in% c(
        "eutL", "eutS", "eutN", "eutK", "pduA", "pduB",
        "pduJ", "pduK", "pduT", "pduU", "bamB", "bamC",
        "bamD", "bamE", "tamA", "tamB"
      ) | is.na(Gene_Name)
    )
  
  write.csv(final_candidates,
            file.path(out_dir, "final_candidates.csv"),
            row.names = FALSE)
  
  cat(prefix, "- Final:", nrow(final_candidates), "\n")
  
  candidate_summary_file <- file.path(out_dir, "candidate_summary.txt")
  
  candidate_lines <- c(
    paste("Receptor candidates:", nrow(candidates)),
    paste("Tier 1 candidates:", nrow(tier1)),
    paste("Tier 2 candidates:", nrow(tier2)),
    paste("Prioritized candidates:", nrow(prioritized)),
    paste("Final candidates:", nrow(final_candidates))
  )
  
  writeLines(candidate_lines, candidate_summary_file)
  
  return(final_candidates)
}


# Panaroo
panaroo_pres_abs <- read.csv(
  file.path(panaroo_dir, "gene_presence_absence.csv"),
  header = TRUE,
  check.names = FALSE,
  stringsAsFactors = FALSE
)

panaroo_genome_cols <- 4:ncol(panaroo_pres_abs)
panaroo_n_genomes <- length(panaroo_genome_cols)

cat("Panaroo genomes detected:", panaroo_n_genomes, "\n")

panaroo_is_core <- apply(panaroo_pres_abs[, panaroo_genome_cols, drop = FALSE], 1, function(row) {
  sum(row != "" & !is.na(row)) == panaroo_n_genomes
})

panaroo_is_accessory <- apply(panaroo_pres_abs[, panaroo_genome_cols, drop = FALSE], 1, function(row) {
  present <- sum(row != "" & !is.na(row))
  present > 0 & present < panaroo_n_genomes
})

panaroo_core_genes <- panaroo_pres_abs[panaroo_is_core, , drop = FALSE]
panaroo_accessory_genes <- panaroo_pres_abs[panaroo_is_accessory, , drop = FALSE]

panaroo_core_locus_tags <- panaroo_core_genes[, panaroo_genome_cols, drop = FALSE] %>%
  as.matrix() %>%
  as.vector() %>%
  .[. != "" & !is.na(.)] %>%
  strsplit(";") %>%
  unlist() %>%
  trimws() %>%
  unique()

run_candidate_pipeline(
  pres_abs = panaroo_pres_abs,
  core_genes = panaroo_core_genes,
  accessory_genes = panaroo_accessory_genes,
  core_locus_tags = panaroo_core_locus_tags,
  out_dir = panaroo_output_dir,
  prefix = "panaroo",
  all_bakta = all_bakta
)

# PPanGGOLiN

ppanggolin_pres_abs <- read.delim(
  file.path(ppanggolin_dir, "gene_presence_absence.Rtab"),
  header = TRUE,
  check.names = FALSE,
  stringsAsFactors = FALSE
)

ppanggolin_genome_cols <- 2:ncol(ppanggolin_pres_abs)
ppanggolin_n_genomes <- length(ppanggolin_genome_cols)

cat("PPanGGOLiN genomes detected:", ppanggolin_n_genomes, "\n")

# Core families = present in all genomes
ppanggolin_is_core <- apply(
  ppanggolin_pres_abs[, ppanggolin_genome_cols, drop = FALSE],
  1,
  function(row) {
    sum(row > 0, na.rm = TRUE) == ppanggolin_n_genomes
  }
)

# Accessory families = present in some but not all genomes
ppanggolin_is_accessory <- apply(
  ppanggolin_pres_abs[, ppanggolin_genome_cols, drop = FALSE],
  1,
  function(row) {
    present <- sum(row > 0, na.rm = TRUE)
    present > 0 & present < ppanggolin_n_genomes
  }
)

ppanggolin_core_genes <- ppanggolin_pres_abs[ppanggolin_is_core, , drop = FALSE]
ppanggolin_accessory_genes <- ppanggolin_pres_abs[ppanggolin_is_accessory, , drop = FALSE]

cat("PPanGGOLiN core families:", nrow(ppanggolin_core_genes), "\n")
cat("PPanGGOLiN accessory families:", nrow(ppanggolin_accessory_genes), "\n")

# Get core family IDs
ppanggolin_core_families <- ppanggolin_core_genes$Gene

# Load per-genome family/gene tables
ppanggolin_table_files <- list.files(
  file.path(ppanggolin_dir, "table"),
  pattern = "\\.tsv$",
  full.names = TRUE
)

parse_ppanggolin_table <- function(filepath) {
  df <- read.delim(
    filepath,
    header = TRUE,
    stringsAsFactors = FALSE,
    check.names = FALSE
  )
  
  df$Source_File <- basename(filepath)
  df
}

ppanggolin_tables <- bind_rows(lapply(ppanggolin_table_files, parse_ppanggolin_table))

# Extract locus tags (gene column) for core families
ppanggolin_core_locus_tags <- ppanggolin_tables %>%
  filter(family %in% ppanggolin_core_families) %>%
  pull(gene) %>%
  unique()

cat("PPanGGOLiN unique core locus tags:", length(ppanggolin_core_locus_tags), "\n")

ppanggolin_core_family_gene_map <- ppanggolin_tables %>%
  filter(family %in% ppanggolin_core_families)

write.csv(
  ppanggolin_core_family_gene_map,
  file.path(ppanggolin_output_dir, "ppanggolin_core_family_gene_map.csv"),
  row.names = FALSE
)

run_candidate_pipeline(
  pres_abs = ppanggolin_pres_abs,
  core_genes = ppanggolin_core_genes,
  accessory_genes = ppanggolin_accessory_genes,
  core_locus_tags = ppanggolin_core_locus_tags,
  out_dir = ppanggolin_output_dir,
  prefix = "ppanggolin",
  all_bakta = all_bakta
)
