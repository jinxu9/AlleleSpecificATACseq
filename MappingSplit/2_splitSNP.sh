# script for split reads according to SNPs information 
# date 03-16-2015
# xujin937@gamil.com
########################################################################333
SNP="/home/jinxu/DB/mmu9/Combin_129S1_CASTEiJ_SNPSinform/Specific_SNPs/129_Cast_SNP_mm9.txt2.chr"
for file in `ls  */*.pe.q10.rmdup.bam`
do
echo "start $file"
SNPsplit    --snp_file $SNP   --paired  --conflicting $file  1>$file.log 2>$file.err 
echo "$file done "
done

for file in `ls */*.genome?.bam`
do
samtools sort $file $file
done
