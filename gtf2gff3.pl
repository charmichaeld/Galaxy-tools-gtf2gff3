#!/usr/bin/perl -w
use strict;
use Getopt::Long qw(:config no_ignore_case);

my $usage = qq{
Synopsis:
    This script is a wrapper for gtf2gff3.
};

my ($gtf_file, $gff3_file, $attr_regex, $attr_delim, $start_in_cds, $stop_in_cds);
my $config_file;
GetOptions (
                't=s' => \$gtf_file,
                'f=s' => \$gff3_file,
                'r=s' => \$attr_regex,
                'd=s' => \$attr_delim,
                's=i' => \$start_in_cds,
                'p=i' => \$stop_in_cds,
                "c=s" => \$config_file,
);

$attr_regex =~ s/X$/\$/;
$attr_regex = &translate_regex($attr_regex);
$attr_delim = &translate_regex($attr_delim);

my $config_text = qq{
#This config file allows the user to customize the gtf2gff3
#converter.

[INPUT_FEATURE_MAP]
#Use INPUT_FEATURE_MAP to map your GTF feature types (column 3 in GTF) to valid SO types.
#Don't edit the SO tags below.
#Mapping must be many to one.  That means that exon_this and exon_that could both
#map to the SO exon tag, but exon_this could not map to multiple SO tags.

#GTF Tag                  #SO Tag
gene         	      	  = gene
mRNA         	      	  = mRNA
exon         	      	  = exon
five_prime_utr            = five_prime_UTR
start_codon  	      	  = start_codon
CDS          	      	  = CDS
stop_codon   	      	  = stop_codon
three_prime_utr           = three_prime_UTR
3UTR         	      	  = three_prime_UTR
3'-UTR       	      	  = three_prime_UTR
5UTR         	      	  = five_prime_UTR
5'-UTR       	      	  = five_prime_UTR
ARS                   	  = ARS
binding_site          	  = binding_site
BLASTN_HIT            	  = nucleotide_match
CDS_motif             	  = nucleotide_motif
CDS_parts             	  = mRNA_region
centromere            	  = centromere
chromosome            	  = chromosome
conflict              	  = conflict
Contig                	  = contig
insertion             	  = insertion
intron                	  = intron
LTR                   	  = long_terminal_repeat
misc_feature          	  = sequence_feature
misc_RNA              	  = transcript
transcript                = transcript
nc_primary_transcript 	  = nc_primary_transcript
ncRNA                 	  = ncRNA
nucleotide_match      	  = nucleotide_match
polyA_signal          	  = polyA_signal_sequence
polyA_site            	  = polyA_site
promoter              	  = promoter
pseudogene            	  = pseudogene
real_mRNA             	  = mRNA
region                	  = region
repeat_family         	  = repeat_family
repeat_region         	  = repeat_region
repeat_unit           	  = repeat region
rep_origin            	  = origin_of_replication
rRNA                  	  = rRNA
snoRNA                	  = snoRNA
snRNA                 	  = snRNA
source                	  = sequence_feature
telomere              	  = telomere
transcript_region     	  = transcript_region
transposable_element  	  = transposable_element
transposable_element_gene = transposable_element
tRNA                      = tRNA

[GTF_ATTRB_MAP]
#Maps attribute keys to keys used internally in the code.
#Don't edit the code tags.
#Note that the gene_id and transcript_id tags tell the script
#who the parents of a feature are.

#Code Tag    #GTF Tag
gene_id    = gene_id
gene_name  = gene_name
trnsc_id   = transcript_id
trnsc_name = transcript_name
id         = ID
parent     = PARENT
name       = NAME

[GFF3_ATTRB_MAP]
#Maps tags used internally to output GFF3 attribute tags.
#Also, when LIMIT_ATTRB is set to 1 only these tags will be
#Output to the GFF3 attributes column.

#Code Tag  #GFF3 Tag
parent   = Parent
id       = ID
name     = Name

[MISC]
# Limit the attribute tags printed to only those in the GFF3_ATTRB_MAP
LIMIT_ATTRB     = 1
#A perl regexp that splits the attributes column into seperate attributes.
ATTRB_DELIMITER = $attr_delim
#A perl regexp that captures the tag value pairs.
ATTRB_REGEX     = $attr_regex
#If CDSs are annotated in the GTF file, are the start codons already included (1=yes 0=no)
START_IN_CDS    = $start_in_cds
#If CDSs are annotated in the GTF file, are the stop codons already included (1=yes 0=no)
STOP_IN_CDS     = $stop_in_cds
#Use the following value (+ or -) for a features strand as the default if an invalid value is passed.
#DEFAULT_STRAND  = +
};

open (CONFIG, ">", $config_file) || die $!;
print CONFIG $config_text;
close CONFIG;

`gtf2gff3 --cfg $config_file $gtf_file > $gff3_file`;

sub translate_regex {
	my $regex = shift;
	$regex =~ s#XX#;#g;
	$regex =~ s#X#\\#g;
	$regex =~ s#__dq__#"#g;
	$regex =~ s#__ob__#[#g;
	$regex =~ s#__cb__#]#g;

	return $regex;
}
