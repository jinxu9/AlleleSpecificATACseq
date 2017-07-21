# AlleleSpecificATACseq
The allele specific ATACseq pipeline including three major steps. 
The scripts to process the first two steps were inlcuded in this sites. The last step can be easily done with bedtools and shell commands, which was not included. 

1. Build allelic-specific genome. 
In the Nature Genetic paper, the reference genome is mm9 and matched dbSNP(v132) were used to extract the allelic information between 129S1 and Cast. 
For people who want use a different genome version. It's important to match your dbSNP version with your genome version. 
For mm10, any versions above v137 should match to mm10. The current version is  v142(ftp://ftp-mouse.sanger.ac.uk/current_snps/). 
The process for SNP_mask genome including : 
	a) Filter SNP sites for each strain from dbSNP 
	b) Change common SNP from reference allele to strains specific allele.
	c) Change difference allele between two strains into “N”.
    d) Then build up genome index for bowtie2. 
Filter : Only single nucleotide polymorphism were kept for this step. 

2. Genome Alignment and Split allelic reads 
 	a) Set the reference as allelic-specific genome
	b) Run the normal ATACseq pipeline
	c) Run "SNPsplit" to split allelic reads
	
3.Allele informative peaks 
	Peaks with >=10 allelic reads were filtered as allele informative peaks. 
