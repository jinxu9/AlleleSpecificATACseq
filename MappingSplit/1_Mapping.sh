# mapping with bowtie2 and filter mapping result

echo "trimming adaptor"
time=`date`
echo $time
cutadapt -b CTGTCTCTTATACACATCTCCGAGCCCACGAGA  -m 25 -O 1  -o /home/jinxu/Data/RME_ATAC-seq/Test_SNP_fromEdithLab/GEO/SRR2121007_1.fastq.tmp.fq  -p /home/jinxu/Data/RME_ATAC-seq/Test_SNP_fromEdithLab/GEO/SRR2121007_2.fastq.tmp.fq  /home/jinxu/Data/RME_ATAC-seq/Test_SNP_fromEdithLab/GEO/SRR2121007_1.fastq /home/jinxu/Data/RME_ATAC-seq/Test_SNP_fromEdithLab/GEO/SRR2121007_2.fastq
cutadapt  -b CTGTCTCTTATACACATCTGACGCTGCCGACGA  -m 25  -O 1 -o /home/jinxu/Data/RME_ATAC-seq/Test_SNP_fromEdithLab/GEO/SRR2121007_2.fastq.trimmed.gz  -p /home/jinxu/Data/RME_ATAC-seq/Test_SNP_fromEdithLab/GEO/SRR2121007_1.fastq.trimmed.gz   /home/jinxu/Data/RME_ATAC-seq/Test_SNP_fromEdithLab/GEO/SRR2121007_2.fastq.tmp.fq /home/jinxu/Data/RME_ATAC-seq/Test_SNP_fromEdithLab/GEO/SRR2121007_1.fastq.tmp.fq

rm /home/jinxu/Data/RME_ATAC-seq/Test_SNP_fromEdithLab/GEO/SRR2121007_1.fastq.tmp.fq
rm /home/jinxu/Data/RME_ATAC-seq/Test_SNP_fromEdithLab/GEO/SRR2121007_2.fastq.tmp.fq

echo "trimming adaptor finished "
time=`date`
echo $time
echo "Mapping by bowtie2"
time=`date`
echo $time
bowtie2   -p 16   --very-sensitive   -x /home/jinxu/DB/mmu9/129S1_CASTEiJ_mm9/129S1_CASTEiJ_mm9 -1 /home/jinxu/Data/RME_ATAC-seq/Test_SNP_fromEdithLab/GEO/SRR2121007_1.fastq.trimmed.gz -2 /home/jinxu/Data/RME_ATAC-seq/Test_SNP_fromEdithLab/GEO/SRR2121007_2.fastq.trimmed.gz  -S  /home/jinxu/Data/RME_ATAC-seq/Test_SNP_fromEdithLab/GEO/output/SRR2121007/SRR2121007.sam 

awk '$3!="chrM"' /home/jinxu/Data/RME_ATAC-seq/Test_SNP_fromEdithLab/GEO/output/SRR2121007/SRR2121007.sam |samtools view -S -b -f 0x2 -q 10 - |samtools sort -  /home/jinxu/Data/RME_ATAC-seq/Test_SNP_fromEdithLab/GEO/output/SRR2121007/SRR2121007.pe.q10.sort

java -jar /home/jinxu/Software/broadinstitute-picard-5f5ba77/dist/picard.jar  MarkDuplicates  REMOVE_DUPLICATES=true METRICS_FILE=/home/jinxu/Data/RME_ATAC-seq/Test_SNP_fromEdithLab/GEO/output/SRR2121007/SRR2121007.pe.q10.dup.txt AS=true INPUT=/home/jinxu/Data/RME_ATAC-seq/Test_SNP_fromEdithLab/GEO/output/SRR2121007/SRR2121007.pe.q10.sort.bam OUTPUT=/home/jinxu/Data/RME_ATAC-seq/Test_SNP_fromEdithLab/GEO/output/SRR2121007/SRR2121007.pe.q10.rmdup.bam

echo "Mapping by bowtie2 finished"

time=`date`
echo $time

