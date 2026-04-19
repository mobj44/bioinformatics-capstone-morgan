# Genome Annotation Reflection
Morgan Johnston

Table: Bakta Summary

|Genome ID       | Genome Size (bp)| N50 (bp)| GC Content (%)| Coding Density (%)| CDS Count| Hypothetical Proteins| Pseudogenes| tRNAs| rRNAs| CRISPR Arrays|
|:---------------|----------------:|--------:|--------------:|------------------:|---------:|---------------------:|-----------:|-----:|-----:|-------------:|
|GCF_000007545.1 |          4791961|  4791961|           52.1|               88.4|      4618|                    85|          27|    80|    22|             1|
|GCF_000020745.1 |          4823887|  4709075|           52.2|               88.7|      4533|                    69|           6|    86|    22|             2|
|GCF_000020885.1 |          4836638|  4798660|           52.0|               88.7|      4496|                    82|           5|    86|    22|             2|
|GCF_000020925.1 |          4917459|  4842908|           52.1|               88.6|      4669|                    69|          10|    86|    22|             0|
|GCF_000022165.1 |          4964097|  4870265|           52.2|               88.8|      4639|                    52|           6|    88|    22|             2|
|GCF_000170215.1 |          4726474|  4719855|           52.3|               88.9|      4336|                    40|           3|    80|    22|             2|
|GCF_000171415.1 |          4948011|   484233|           52.1|               88.5|      4678|                    89|           8|    65|     2|             5|
|GCF_000171515.1 |          4793325|   370713|           52.3|               88.6|      4444|                    58|           5|    85|    32|             2|
|GCF_000171535.2 |          4876885|  3027433|           52.1|               88.7|      4579|                    65|          11|    86|    22|             2|


The Bakta results across the nine *Salmonella enterica* genomes look pretty consistent overall, which is a good sign. Genome sizes, GC content (~52%), and coding density (~88%) are all very similar, so the assemblies seem comparable. CDS counts are in the expected range, and while there’s some variation in hypothetical proteins and CRISPR arrays, that likely reflects real biological differences between strains. Overall, the genomes appear to be suitable for pangenome analysis with only minor outliers.

Overall, the data looks good and should work well for downstream analyses like pangenome work and identifying candidate genes. The process itself wasn’t too bad. The hardest part was just getting the Bakta database downloaded and set up since it’s pretty large. Once that was done, everything else ran smoothly.
