package MLST::Logger;

use base Exporter;
@EXPORT_OK = qw(msg err wrn dbg) ;

#----------------------------------------------------------------------
our $quiet = 0;
our $debug = 0;
#----------------------------------------------------------------------
sub quiet {
  my($self, $value) = @_;
  $quiet = $value if defined $value;
  return $quiet;
}
#----------------------------------------------------------------------
sub debug {
  my($self, $value) = @_;
  $debug = $value if defined $value;
  return $debug;
}
#----------------------------------------------------------------------
sub dbg {
  return unless $debug;
  my $bar = '='x10;
  print STDERR 
    $bar," DEBUG START ", $bar, "\n",
    @_, "\n",
    $bar," DEBUG END ", $bar, "\n";
  return;  
}
#----------------------------------------------------------------------
sub msg {
  print STDERR "@_\n" unless $quiet;
}
#----------------------------------------------------------------------
sub wrn {
  print STDERR "WARNING: @_\n";
}
#----------------------------------------------------------------------
sub err {
  print STDERR "ERRPR: @_\n";
  exit(1);
}
#----------------------------------------------------------------------

1;

