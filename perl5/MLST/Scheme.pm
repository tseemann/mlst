package MLST::Scheme;

use Moo;

#.................................................................................

has dir => (
  is => 'ro',
  required => 1,
);

has name => (
  is => 'ro',
  required => 1,
);

sub _tab_file {
  my($self) = @_;
  sprintf "%s/%s/%s.txt", $self->dir, $self->name, $self->name;
}

has genes => (
  is => 'lazy',
);

has num_genes => (
  is => 'lazy'
);

sub _build_num_genes {
  my($self) = @_;
  return scalar( @{ $self->genes } )
}

sub _build_genes {
  my($self) = @_;
  open my $fh, '<', $self->_tab_file();
  my $header = <$fh>;
  chomp $header;
  my @row = split m/\t/, $header;
  return [ grep { ! m/^(ST|clonal_complex|species|CC|Lineage)$/ } @row ];
}

has genotypes => (
  is => 'lazy'
);

sub _build_genotypes {
  my($self) = @_;
  my $res;
  my @gene = @{ $self->genes };
  open my $fh, '<', $self->_tab_file();
  while (<$fh>) {
    chomp;
    my @col = split m/\t/;
    next unless $col[0] =~ m/^\d+$/;
    my $sig = join "/", map { $col[$_] || '-' } (1 .. @gene);
    $res->{ $sig } = $col[0];
  }  
  return $res;
}

sub sequence_type {
  my($self, $sig) = @_;
  return $self->genotypes->{ $sig } || '-';
}

sub signature_of {
  my($self, $hash) = @_;
  my @sig;
  for my $gene ( @{ $self->genes } ) {
    push @sig, $hash->{$gene} || '-';
  }
  return join("/", @sig);
}

#.................................................................................

1;

