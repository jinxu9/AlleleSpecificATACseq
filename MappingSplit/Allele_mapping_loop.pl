#!/usr/bin/perl
#use strict;
#use warnings;

############################################
#Allelic mapping 
#2015-02-12
#2015-02-24 modification
# 2015-02-25 fix pair-end reads filter by samtools 
#xujin937@gmail.com
############################################

###parameters#######################################
##Mapping step###########################################

if(@ARGV<1)
{
	print "Usage perl $0 <configure.txt>\n";
	print "congfigure.txt example: \n";
	print "\tref_index=path	\n";
	print "\tref_size=path	\n";
	print "\tmax_thread=n\n";
	print "\tRead1\tRead2\t ouput dir1\t outdir/$output file prefix1 \n";
	print "\tRead1\tRead2\t ouput dir2\t outdir/$output file prefix2 \n";
	print "\t.\n";
	print "\t.\n";
	print "\t.\n";

	exit;
}
open CON, "$ARGV[0]" or die "can not open $ARGV[0]\n";

my $total_thread=1;
my $ref;
my $ref_size;
my @samples;
while(<CON>)
{
chomp;
#print $_,"\n";
if(/^ref_index=(\S+)/)
{
	$ref=$1;
	#print $ref,"\n";
}
elsif(/^ref_size=(\S+)/)
{
	$ref_size=$1;
	#print $ref_size,"\n";
}
elsif(/^max_thread=(\d+)/)
	{
		$total_thread=$1;
	#	print $total_thread,"\n";
	}
else
{
#	print $_,"\n";
	push @sample, $_;
}

}


foreach my $item(@sample)
{
chomp($item);
my @a=split(/\s+/,$item);
#print join("\t",@a),"\n";
my $file1=$a[0];
my $file2=$a[1];
my $outdir=$a[2];
#print $outdir,"\n";
my $output=$a[3];
my $thread=int($total_thread/($#sample+1));
#print $#sample,"\n";
if(! -d $outdir)
{
mkdir $outdir
}

my $script=$outdir."/".$output.".sh";
print $script,"\n";
open OUT, ">$script" or die "can not open $script \n";


print OUT   qq(
echo "trimming adaptor"
time=`date`
echo \$time
cutadapt -b CTGTCTCTTATACACATCTCCGAGCCCACGAGA  -m 25   -o $file1.tmp.fq  -p $file2.tmp.fq  $file1 $file2
cutadapt  -b CTGTCTCTTATACACATCTGACGCTGCCGACGA  -m 25   -o $file2.trimmed.gz  -p $file1.trimmed.gz   $file2.tmp.fq $file1.tmp.fq
rm $file1.tmp.fq
rm $file2.tmp.fq
echo "trimming adaptor finished "
time=`date`
echo \$time
echo "Mapping by bowtie2"
time=`date`
echo \$time
bowtie2   -p $thread   --very-sensitive   -x $ref -1 $file1.trimmed.gz -2 $file2.trimmed.gz  -S  $outdir/$output.sam 
awk '\$3!="chrM"' $outdir/$output.sam |samtools view -S -b -f 0x2 -q 10 - |samtools sort -  $outdir/$output.pe.q10.sort
java -jar /home/jinxu/Software/broadinstitute-picard-5f5ba77/dist/picard.jar  MarkDuplicates  REMOVE_DUPLICATES=true METRICS_FILE=$outdir/$output.pe.q10.dup.txt AS=true INPUT=$outdir/$output.pe.q10.sort.bam OUTPUT=$outdir/$output.pe.q10.rmdup.bam
rm $outdir/$output.sam
echo "Mapping by bowtie2 finished"
time=`date`
echo \$time

);

close OUT;
# run each script in background
system('sh $script 1>$script.log 2>$script.err &')

}
