package MLST::Logger;

use base Exporter;
@EXPORT_OK = qw(msg err);

use Time::Piece;

our $quiet = 0;

#----------------------------------------------------------------------

sub quiet {
  my($self, $value) = @_;
  $quiet = $value if defined $value;
  return $quiet;
}

#----------------------------------------------------------------------

sub msg {
  return if $quiet;
  my $t = localtime;
  print STDERR "[".$t->hms."] @_\n";
}
      
#----------------------------------------------------------------------

sub err {
  $quiet=0;  # disable on errors!
  msg(@_);
  exit(1);
}

#----------------------------------------------------------------------

1;

