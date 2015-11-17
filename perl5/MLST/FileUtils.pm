package MLST::FileUtils;

use base Exporter;
@EXPORT_OK = qw(is_genbank genbank_to_fasta is_gzipped gunzip_file);

#----------------------------------------------------------------------

sub is_gzipped {
  my($infile) = @_;
  my($magic) = qx(file \Q$infile\E);
  return $magic =~ m/gzip/ ? 1 : 0;
#  open my $in, '<', $infile;
#  my $magic;
#  read $in, $buffer, 2;  
}

#----------------------------------------------------------------------

sub is_genbank {
  my($infile) = @_;
  open my $in, '<', $infile;
  my $line = <$in>;
  return $line =~ m/^LOCUS/ ? 1 : 0;
}

#----------------------------------------------------------------------

sub gunzip_file {
  my($infile, $outfile) = @_;
  return system("gzip -f -d -c \Q$infile\E > \Q$outfile\E");
}

#----------------------------------------------------------------------

sub genbank_to_fasta {
  my($infile, $outfile) = @_;
  open my $in, '<', $infile;
  open my $out, '>', $outfile;
  my $gi = '';
  my $acc = '';
  my $org = '';
  my $def = '';
  my $in_seq = 0;
  my $dna = '';
  while (<$in>) {
    chomp;
    if (m{^//}) {
      print $out ">gi|$gi|gb|$acc| $def [$org]\n$dna";
      $in_seq = 0;
      $dna = $gi = $acc = $org = $def = '';
      next;
    }
    elsif (m/^ORIGIN/) {
      $in_seq = 1;
      next;
    }
    
    if ($in_seq) {
      my $s = substr $_, 10;
      $s =~ s/\s//g;
      $dna .= uc($s);
      $dna .= "\n";
    }
    else {
      if (m/^VERSION.*?GI:(\d+)/) {
        $gi = $1;
      }
      elsif (m/^SOURCE\s+(.*)$/) {
        $org = $1;
      }
      elsif (m/^LOCUS\s+(\S+)/) {
        $acc = $1;
      }
      elsif (m/^DEFINITION\s+(.*)$/) {
        $def = $1;
      }
    }
  }
}

#----------------------------------------------------------------------
# Option setting routines

sub setOptions {
  use Getopt::Long;

  @Options = (
    {OPT=>"help",    VAR=>\&usage,             DESC=>"This help"},
    {OPT=>"debug!",  VAR=>\$debug, DEFAULT=>0, DESC=>"Debug info"},
  );

  (!@ARGV) && (usage());

  &GetOptions(map {$_->{OPT}, $_->{VAR}} @Options) || usage();

  # Now setup default values.
  foreach (@Options) {
    if (defined($_->{DEFAULT}) && !defined(${$_->{VAR}})) {
      ${$_->{VAR}} = $_->{DEFAULT};
    }
  }
}

sub usage {
  print "Usage: $0 [options] < file.gbk > file.fna\n";
  foreach (@Options) {
    printf "  --%-13s %s%s.\n",$_->{OPT},$_->{DESC},
           defined($_->{DEFAULT}) ? " (default '$_->{DEFAULT}')" : "";
  }
  exit(1);
}
 
#----------------------------------------------------------------------
