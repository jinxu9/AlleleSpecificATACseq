#!/usr/bin/perl -w 
#Author : xujin937@gmail.com
#Aim : merge SNPs for two mouse strains 
#      129SV	CAST
#	C/A	-/-	keep SNP as  A/C
#	-/-	C/A	keep SNP as  C/A
#	C/A	C/G	keep SNP as  A/G	
#	C/A	C/A	keep SNP as  C/A & output in file2, modified BL6 using file2 
#####################################################################
use strict;
use warnings;

if(@ARGV<2)
{
	print "Usage perl $0 <129Sv SNPs> <CASTEiJ SNPs>\n";
	exit;
}
my $SNP1=shift;
my $SNP2=shift;

open(S1,$SNP1) or die ($!);
#while(<S1>){last;}
open(S2,$SNP2) or die ($!);
#while(<S2>){last;}
my $snp1=undef;
my $snp2=undef;
while(1)
{
	$snp1=&parse_snp_line(\*S1) unless ($snp1);
	$snp2=&parse_snp_line(\*S2) unless ($snp2);
	#print $snp1->[2], "\t",$snp2->[2],"\n";
	if(!$snp1 && !$snp2)
	{
		last;
	}
	if(!$snp1 && $snp2 ) 
	{
		print join("\t",@$snp2),"\t","G2\n";
		undef $snp2; next;
	}
	if(!$snp2 && $snp1)
	{
		print join("\t",@$snp1),"\t","G1\n";
                undef $snp1; next;
	}
	if($snp1->[2] >$snp2->[2] )
	{
		print join("\t",@$snp2),"\t","G2\n";
		undef $snp2; next;
	}	
	if($snp1->[2] <$snp2->[2])
	{	# need to reverse the allele  C/A to A/C
		
		my @alleles=split(/\//,$snp1->[4]);
			$snp1->[4]=$alleles[1]."/".$alleles[0];
		print join("\t",@$snp1),"\t","G1\n";
                undef $snp1; next;

	}
	if($snp1->[2] == $snp2->[2])
	{
		if($snp1->[4] eq $snp2->[4])
		{
			print STDERR join("\t",@$snp1),"\t","Common\n";
		}
		else
		{
			my @allele1=split(/\//,$snp1->[4]);
			my @allele2=split(/\//,$snp2->[4]);
			$snp1->[4]=$allele1[1]."/".$allele2[1];
			print join("\t",@$snp1),"\t","SameSites\n";

		}
			undef $snp1; undef $snp2; next;
			
	}

}

close S1;
close S2;
1;

sub parse_snp_line {
	my $fh = shift;
	while(<$fh>){
		my @tabs = split;
		#print join("\t",@tabs),"\n";
		return \@tabs;
	}
}

