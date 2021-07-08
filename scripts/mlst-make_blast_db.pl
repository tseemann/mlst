#!/usr/bin/env perl

use strict;
use warnings;
use File::Basename qw/fileparse basename dirname/;
use Getopt::Long qw/GetOptions/;
use Bio::SeqIO;
use File::Find qw/find/;
use FindBin qw/$RealBin/;

local $0=$0;

exit main();

sub main{
  my $settings={};
  GetOptions($settings, qw(help filter! scheme=s)) or die $!;
  $$settings{filter}//=1;
  $$settings{scheme}//="";

  # Make our directory structure
  my $mlstDir="$RealBin/../db/pubmlst";
  my $blastDir="$RealBin/../db/blast";
  mkdir dirname($blastDir);
  mkdir dirname($mlstDir);
  mkdir $mlstDir;
  mkdir $blastDir;
  my $blastFile="$RealBin/mlst.fa";

  die usage() if($$settings{help});

  downloadPubMLST($mlstDir,$$settings{scheme});
  combineBlastDb($blastFile,$mlstDir);

  return 0;
}

sub downloadPubMLST{
  my($mlstDir,$scheme)=@_;

  mkdir $mlstDir;
  system("wget --no-clobber -P '$mlstDir' http://pubmlst.org/data/dbases.xml");
  die "ERROR downloading dbases.xml" if $?;

  my $profile="";
  my $profileDir="";
  open(my $dbasesFh, "$mlstDir/dbases.xml") or die "ERROR could not read $mlstDir/dbases.xml: $!";
  while(my $url=<$dbasesFh>){
    # Remove the URL tags
    $url=~s/<url>//;
    $url=~s/<\/url>//;
    chomp $url;

    next if($url=~/^</); # <?xml version="1.0" ...

    # Either get the profiles txt or the
    # alleles tfa files.
    my $ext=substr($url,-4,4); # last four characters
    if($ext=~/\.txt/){
      $profile=basename($url,$ext,".tfa",".txt");

      # Don't download this profile if the user specified
      # a specific one and this isn't it.
      if($scheme && $profile ne $scheme){
        # Nullify the profile variable so that the loci are
        # skipped when it comes to the tfa files.
        $profile="";
        next;
      }

      $profileDir="$mlstDir/$profile";
      print "$0: DOWNLOAD: $profile => $profileDir/\n";
      mkdir $profileDir;

      system("cd '$profileDir' && wget '$url' 2> /dev/null");
      die if $?;
    } elsif($ext=~/\.tfa/){
      # Don't download the tfa files unless the profile
      # is defined
      if(!$profile){
        print "WARNING: skipping $url\n";
        next;
      }
      print "  $url => $profileDir/\n";
      system("cd '$profileDir' && wget '$url' 2> /dev/null");
      die if $?;
    }
  }
  close $dbasesFh;
}

sub combineBlastDb{
  my($blastFile,$mlstDir)=@_;

  # Start fresh with a new combined file
  unlink($blastFile);

  # Use File::Find::find to locate all schemes and add them.
  # To avoid using globals, use the sub{...} syntax.
  find({no_chdir=>1, wanted=>sub{
                       addScheme($blastFile);
                     }
  }, $mlstDir);
    

  system("makeblastdb -hash_index -in \"$blastFile\" -dbtype nucl -title \"PubMLST\" -parse_seqids");
  die "ERROR with makeblastdb" if $?;
}

# This function is called by File::Find::find.
#   $File::Find::dir is the current directory name
#   $_ is the current filename within that directory
#   $File::Find::name is the complete pathname to the file.
sub addScheme{
  my($blastFile)=@_;

  my $schemePath=$File::Find::name;

  # Only accept directory names
  return if(!-d $schemePath);
  #my $depth = tr|/||; # count slashes to get depth
  #next if($depth > 1); # -maxdepth 1

  # Append
  my $seqout=Bio::SeqIO->new(-file=>">>$blastFile");

  my $scheme=basename($schemePath);
  print "$0: ADDING: $schemePath\n";
  
  for my $tfa(glob("$schemePath/*.tfa")){
    my $seqin=Bio::SeqIO->new(-file=>$tfa, -format=>"fasta");
    while(my $seq=$seqin->next_seq){
      # Reformat the allele identifier so that it also has the scheme
      my $id=$seq->id;
      $id=~s/^/$scheme./;
      $seq->id($id);

      # Place all filtering into this if block
      #if($$settings{filter}){
      #  # Do not accept ridiculous alleles
      #  next if($seq->seq=~/^(A+|C+|G+|T+)$/);
      #}
      $seqout->write_seq($seq);
    }
    $seqin->close;
  }

  # Flush the output so that makeblastdb is working on
  # the total contents.
  $seqout->close;
}

sub usage{
  local $0=basename $0;
  "$0: downloads the latest pubmlst databases.
  To run, execute this file with no options.

  --scheme  ''   Which schemes to download?
                 Default: all databases
                 For a listing, run `mlst --longlist | cut -f 1`
  "
}
