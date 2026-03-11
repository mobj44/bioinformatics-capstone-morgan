# CLEAR Task #2: Data Evaluation and Quality Control - Reflect
## Relevance of Metrics
What metrics and data were generated from your analyses?   
Which of these make sense to use given the context of our analysis?   
What criteria were you looking for to ensure the genome assemblies were "good"?  

My analysis generated busco scores and N50 scores. The serovars with the lowest busco scores (less than 95%) are also the ones with the lowest N50. There are 5 lower than 95%.  

## Assembly Evaluation Results
Did any serovars show poor genome assembly?  
Are there any genomes you feel should be excluded from downstream analyses?  

Table: Genomes with a BUSCO above 95% sorted by n50

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

Table: Genomes with a BUSCO below 95% sorted by n50

|accession_number | complete_percentage|    n50|
|:----------------|-------------------:|------:|
|GCF_000171255.1  |                80.6| 471765|
|GCF_000171515.1  |                93.5| 370713|
|GCF_000171315.1  |                67.7| 308442|
|GCF_000171275.1  |                67.7| 233156|
|GCF_000170255.1  |                69.4| 103713|
## Tool execution
Did your selected tool(s) perform as expected?  
Did you have to shift from your original plans for the selected tools? If so, why? How did you choose the next tool to implement?  
Were there any surprising results or confusing aspects of the tool output?  
If you were to repeat this assembly evaluation process on a new dataset, would you use the same tool(s) and settings? Why or why not?  
