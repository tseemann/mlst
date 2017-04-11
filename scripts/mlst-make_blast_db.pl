#!/usr/bin/env perl

use strict;
use warnings;
use File::Basename qw/fileparse basename/;
use Getopt::Long qw/GetOptions/;
use Bio::SeqIO;

my($thisScript, $thisDir, $thisExt)=fileparse($0);

my $mlstDir="$thisDir/../db/pubmlst";
my $blastDir="$thisDir/../db/blast";
my $blastFile="$blastDir/mlst.fa";

exit main();

sub main{
  my $settings={};
  GetOptions($settings, qw(help filter!)) or die $!;
  $$settings{filter}//=1;

  die usage() if($$settings{help});

  downloadPubMLST();
  combineBlastDb();

  return 0;
}

sub downloadPubMLST{
  mkdir $mlstDir;
  system("wget --no-clobber -P '$mlstDir' http://pubmlst.org/data/dbases.xml");
  die "ERROR downloading dbases.xml" if $?;

  my $profile="MISSING";
  my $profileDir="MISSING";
  open(my $dbasesFh, "$mlstDir/dbases.xml") or die "ERROR could not read $mlstDir/dbases.xml: $!";
  while(my $url=<$dbasesFh>){
    # Remove the URL tags
    $url=~s/<url>//;
    $url=~s/<\/url>//;
    chomp $url;

    # Either get the profiles txt or the
    # alleles tfa files.
    my $ext=substr($url,-4,4); # last four characters
    if($ext=~/\.txt/){
      $profile=basename($url);
      print "# $profile \n";
      $profileDir="$mlstDir/$profile";
      mkdir $profileDir;

      system("cd '$profileDir' && wget '$url'");
      die if $?;
    } elsif($ext=~/\.tfa/){
      system("cd '$profileDir' && wget '$url'");
      die if $?;
    }
  }
  close $dbasesFh;
}

sub combineBlastDb{
  unlink($blastFile);

  my $seqout=Bio::SeqIO->new(-file=>">$blastFile");
  for my $schemePath(glob("$mlstDir/*")){
    next if(!-d $schemePath);
    my $scheme=basename($schemePath);
    print "$thisScript: ADDING: $scheme\n";
    
    for my $tfa(glob("$schemePath/*.tfa")){
      my $seqin=Bio::SeqIO->new(-file=>$tfa, -format=>"fasta");
      while(my $seq=$seqin->next_seq){
        # Reformat the allele identifier so that it also has the scheme
        my $id=$seq->id;
        $id=~s/^/$scheme./;
        $seq->id($id);

        # Place all filtering into this if block
        if($$settings{filter}){
          # Do not accept ridiculous alleles
          next if($seq->seq=~/^(A+|C+|G+|T+)$/);
        }
        $seqout->write_seq($seq);
      }
      $seqin->close;
    }
  }
  $seqout->close;

  system("makeblastdb -hash_index -in \"$blastFile\" -dbtype nucl -title \"PubMLST\" -parse_seqids");
  die "ERROR with makeblastdb" if $?;
}

sub usage{
  local $0=basename $0;
  "$0: downloads the latest pubmlst databases.
  To run, execute this file with no options.

  --filter      Do not filter fake sequences
  "
}
