for file in `ls ../dbSNP_132/129_SNPs/SNPs_Sanger/*.txt`
do
file2=`echo $file|sed 's/129/Cast/g'`
chr=`basename $file`

head -1 $file >head
sed '1,1d' $file >129.tmp
sed '1,1d' $file2 >CAST.tmp
echo $file 
echo $file2
echo $chr

perl Combine_SNPs.pl  129.tmp CAST.tmp 1> $chr.specific.tmp 2>$chr.common.tmp
cat head $chr.specific.tmp >$chr.specific
cat head $chr.common.tmp >$chr.common
rm *.tmp

done


