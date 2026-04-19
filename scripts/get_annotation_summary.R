library(tidyverse)

# Paths
bakta_dir <- "data/genome_annotation/bakta"
output_dir <- "analysis/genome_annotation"

# Make Output Dir
dir.create(output_dir)

# Find all .txt files in bakta_dir recursively
txt_files <- list.files(
  path = bakta_dir,
  pattern = "\\.txt$",
  recursive = TRUE,
  full.names = TRUE
)

# Function to read one Bakta summary txt file
read_bakta_summary <- function(file) {
  lines <- readLines(file, warn = FALSE)
  
  data_list <- list()
  current_section <- NULL
  
  for (line in lines) {
    line <- trimws(line)
    
    if (line == "") next
    
    # Section headers end with ":" and have no value after them
    if (grepl(":$", line)) {
      current_section <- sub(":$", "", line)
      next
    }
    
    # Key-value lines
    if (grepl(":", line)) {
      parts <- strsplit(line, ":", fixed = TRUE)[[1]]
      
      key <- trimws(parts[1])
      value <- trimws(paste(parts[-1], collapse = ":"))
      
      col_name <- paste(current_section, key, sep = "_")
      col_name <- gsub("[^A-Za-z0-9_]", "", col_name)
      
      data_list[[col_name]] <- value
    }
  }
  
  # Use parent folder name as genome ID
  genome_id <- basename(dirname(file))
  data_list[["genome"]] <- genome_id
  data_list[["source_file"]] <- file
  
  as.data.frame(data_list, stringsAsFactors = FALSE)
}

# Read all files
bakta_list <- lapply(txt_files, read_bakta_summary)

# Combine into one dataframe
bakta_df <- do.call(rbind, bakta_list)

# Move genome column to front
bakta_df <- bakta_df[, c("genome", setdiff(names(bakta_df), "genome"))]

bakta_df <- bakta_df %>% 
  select(
    genome,
    Sequences_Length,
    Sequences_N50,
    Sequences_GC,
    Sequences_codingdensity,
    Annotation_CDSs,
    Annotation_hypotheticals,
    Annotation_pseudogenes,
    Annotation_tRNAs,
    Annotation_rRNAs,
    Annotation_CRISPRarrays
  ) 
colnames(bakta_df) <- c(
  "Genome ID",
  "Genome Size (bp)",
  "N50 (bp)",
  "GC Content (%)",
  "Coding Density (%)",
  "CDS Count",
  "Hypothetical Proteins",
  "Pseudogenes",
  "tRNAs",
  "rRNAs",
  "CRISPR Arrays"
)

# Convert columns to numeric where possible
bakta_df[] <- lapply(bakta_df, function(x) type.convert(x, as.is = TRUE))

colnames(bakta_df)

# Save to CSV
write.csv(bakta_df, file.path(output_dir, "bakta_summary_compiled.csv"), row.names = FALSE)
knitr::kable(bakta_df, caption = "Bakta Summary")
