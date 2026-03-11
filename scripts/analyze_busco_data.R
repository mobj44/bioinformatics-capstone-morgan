library(tidyverse)
library(janitor)

busco_data <- read_csv('analysis/assembly_evaluation/busco_summary.csv') %>%
    clean_names()

selected_busco_data <- busco_data %>%
    rename(n50 = contigs_n50) %>%
    select(
        accession_number,
        complete_percentage,
        n50
        ) %>%
    arrange(desc(n50))

keep <- selected_busco_data %>%
    filter(complete_percentage >= 95)
get_rid <- selected_busco_data %>%
    filter(complete_percentage < 95)



# uncomment to get keep and get rid as md tables
# knitr::kable(keep, caption = "Genomes with a BUSCO above 95%")
# knitr::kable(get_rid, caption = "Genomes with a BUSCO below 95%")

write.csv(
    keep,
    file = 'analysis/assembly_evaluation/filtered_busco.csv',
    row.names = FALSE
)

write.table(keep$accession_number,
            file = 'analysis/assembly_evaluation/busco_filtered_accessions.txt',
            col.names = FALSE,
            row.names = FALSE
)
