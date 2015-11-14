package MLST::PubMLST;

use Moo;
use MLST::Scheme;

#.................................................................................

has dir => (
  is => 'ro',
  required => 1,
  isa => sub { 
    die "$_[0] is not a directory" unless -d $_[0] 
  },
);

has schemes => (
  is => 'lazy',
);

sub _build_schemes {
  my($self) = @_;
  opendir(my $dh, $self->dir);
  my @name = grep { substr($_,0,1) ne '.' and -d $self->dir."/$_" } readdir($dh);
  closedir $dh;
  return [ map { MLST::Scheme->new(dir=>$self->dir, name=>$_) } @name ];
}

sub names {
  my($self) = @_;
  return map { $_->name } @{ $self->schemes };
} 

#.................................................................................

1;

