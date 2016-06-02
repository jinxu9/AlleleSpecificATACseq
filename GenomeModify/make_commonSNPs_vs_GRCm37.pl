#/usr/bin/perl
use warnings;
use strict;

### Adapted for Sanger SNPs for the Mus musculus 129S1 on 11 April 2014 for Andrew Dimond
### The original script were got from Filex 
### modification for ATACseq pipeline  12 DEC 2014
### modify common SNPs into 129 and Cast common SNPs.
###			  add "chr" to output fa file.
my $new_total = 0;
my $already_total = 0;
my $low_confidence = 0;

for my $chr ('Y','M',1..19,'X') {
  create_modified_chromosome($chr);
}

warn "\n\nSummary\n$new_total SNPs were newly introduced in total\n\n";


sub create_modified_chromosome {

  my ($chr) = @_;

  warn "Processing chr$chr\n";

  my $sequence = read_black6_sequence($chr);

  my @snps = @{read_snps($chr)};
  @snps = () unless (@snps);

  my $count = 0;

  my $lastPos = 0;

  my $already = 0;
  my $warn = 0;
  my $new = 0;
  foreach my $snp (@snps) {
    # Apply the SNP
    ++$count;

    if ($snp->[0] == $lastPos) {
      # Duplicate SNP
      next;
    }

    $lastPos = $snp->[0];

    # Check if the B6 base is already the C3H SNP
    if (substr ($sequence,$snp->[0]-1,1) eq $snp->[2]) {
      #	warn "Skipping $snp->[0] $snp->[1]/$snp->[2] since the B6 base is already a C3H SNP\n";
      ++$already;
      next;
    }

    # Check the B6 base is correct
    elsif (substr ($sequence,$snp->[0]-1,1) ne $snp->[1]) {
      #	warn "Skipping $snp->[0] $snp->[1]/$snp->[2] since the B6 base didn't match\n";
      $warn++;
      next;
    }

     substr($sequence,$snp->[0]-1,1,$snp->[2]); # previouse : substr the SNP by dbSNP information, using this for common SNPs
#    substr($sequence,$snp->[0]-1,1,"N"); # Revise: make SNPs sites to be N. using this for specific SNPs
   
	 ++$new;
  }
  $new_total += $new;
  $already_total += $already;

  write_129S1_chromosome($chr,$sequence);
  warn "$count SNPs read in total\n";
  warn "$new SNPs were newly introduced\n\n";

}

sub write_129S1_chromosome {

    warn "Writing modified chromosome\n";

    my ($chr,$sequence) = @_;

    warn "Starting sequence is ".length($sequence)."bp\n";

    open (OUT,'>',"/home/jinxu/DB/mmu9/Combin_129S1_CASTEiJ/chr_withCommon_SNPs/chr$chr.fa") or die $!;

    print OUT ">$chr\n";

    my $pos = 0;

    while ($pos < length($sequence)-100) {
      print OUT substr($sequence,$pos,100),"\n";
      $pos += 100;
    }
    print OUT substr($sequence,$pos),"\n";

    close OUT or die $!;

}

sub read_snps {

    warn "Reading SNPs\n";

    my ($chr) = @_;
    my @snps = ();
    my $file = "/home/jinxu/DB/mmu9/Combin_129S1_CASTEiJ/Common_SNPs/chr$chr.txt.common";

    unless (-e $file) {
      warn "Couldn't find SNP file for '$chr' '$file' didn't exist. Skipping...\n";
      return \@snps;
    }

    open (IN,$file) or die $!;

    while (<IN>) {
      chomp;
      next unless ($_);

      my (undef,undef,$pos,$strand,$allele) = split(/\t/);

      my ($b6_allele,$strain129_allele);

      next unless ($allele);

      if ($allele =~ /^([GATC])\/([GATC])$/) {
	$b6_allele = $1;
	$strain129_allele = $2;
      }
      else {
	warn "Skipping allele $allele\n";
	next;
      }

      if ($strand == -1) {
	$b6_allele =~ tr/GATC/CTAG/;
	$strain129_allele =~ tr/GATC/CTAG/;
      }

      push @snps,[$pos,$b6_allele,$strain129_allele];
    }

    @snps = sort {$a->[0] <=> $b->[0]} @snps;
	
    return \@snps;

    close IN;

}

sub read_black6_sequence {

  warn "Reading WT Black6 sequence (GRCm38)\n";
  my ($chr) = @_;

  my $file = "/home/jinxu/DB/mmu9/mm9_UCSC/chromosomes/chr$chr.fa";

  unless (-e $file) {
    die "Couldn't find file for '$chr' '$file' didn't exist";
  }

  open (IN,$file) or die $!;

  $_ = <IN>;
  my $sequence;

  while (<IN>) {
    chomp;
    #	warn "Read $_\n";
    $sequence .= uc$_;
  }

  close IN;

  return $sequence;

}
