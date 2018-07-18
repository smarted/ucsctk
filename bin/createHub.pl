#!/usr/bin/perl -w

use strict;
use Getopt::Long;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
use File::Path qw(make_path);
use Data::Dumper;
use Cwd qw(abs_path);

&usage if @ARGV<1;

sub usage {
        my $usage = << "USAGE";

        This script create hub directory for ucsc .
        Author: zhoujj2013\@gmail.com 
        Usage: $0 config.cfg

USAGE
print "$usage";
exit(1);
};

my $conf=shift;
my %conf;
&load_conf($conf, \%conf);

# create hub directory
my @dirs;
my @dirs_raw = glob("*");
foreach my $f (@dirs_raw){
	if(-d $f){
		if($f eq "$conf{'hub'}"){
			die "Error, the duplicated hub name ($conf{'hub'}) is detected.\n";
		}
	}
}

`mkdir $conf{'hub'}`;

# create hub.txt
open OUT,">","$conf{'hub'}/hub.txt" || die $!;
print OUT "hub $conf{'hub'}\n";
print OUT "shortLabel $conf{'shortLabel'}\n";
print OUT "longLabel $conf{'longLabel'}\n";
print OUT "genomesFile genomes.txt\n";
print OUT "email $conf{'email'}\n";
close OUT;

# create genomes.txt and directories
open OUT,">","$conf{'hub'}/genome.txt" || die $!;
my @g = split /,/,$conf{'genome_version'};
foreach my $genome_version (@g){
	print OUT "genome $genome_version\n";
	print OUT "trackDb $genome_version/trackDb.txt\n";
	print OUT "\n";
	`mkdir $conf{'hub'}/$genome_version`;
	`touch $conf{'hub'}/$genome_version/trackDb.txt`;
}
close OUT;


# data
`mkdir $conf{'hub'}/data`;

# finished.

#########################

sub load_conf
{
    my $conf_file=shift;
    my $conf_hash=shift; #hash ref
    warn "#configure information:\n";
    open CONF, $conf_file || die "$!";
    while(<CONF>)
    {
        chomp;
        next unless $_ =~ /\S+/;
        next if $_ =~ /^#/;
        warn "$_\n";
        my @F = split"\t", $_;  #key->value
        $conf_hash->{$F[0]} = $F[1];
    }
    close CONF;
}
