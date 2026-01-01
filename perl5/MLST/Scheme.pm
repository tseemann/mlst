package MLST::Scheme;

use Moo;
use Path::Tiny;
use Data::Dumper;

#.................................................................................

has dir => (is=>'ro', required=>1);
has name => (is=>'ro', required=>1);
has genes => (is=>'lazy');
has num_genes => (is=>'lazy');
has genotypes => (is=>'lazy');
has num_genotypes => (is=>'lazy');
has num_alleles => (is=>'lazy');
has last_updated => (is=>'lazy');

sub _tab_file {
  my($self) = @_;
  sprintf "%s/%s/%s.txt", $self->dir, $self->name, $self->name;
}

sub _build_last_updated {
  my($self) = @_;
  my $NONE = "Unknown";
  my $df = path($self->dir, $self->name, 'database_version.txt');
  #print Dumper($df);
  return $NONE unless $df->is_file;
  my($date) = $df->lines({count=>1,chomp=>1});
  return $NONE if $date =~ m/[^\d-]/;
  return $date;
}

sub _build_num_genes {
  my($self) = @_;
  return scalar( @{ $self->genes } )
}

sub _build_genes {
  my($self) = @_;
  open my $fh, '<', $self->_tab_file()
    or die "Could not open scheme file: $!";
  my $header = <$fh>;
  chomp $header;
  my @row = split m/\t/, $header;
  return [ grep { ! m/^(ST|mlst_clade|clonal_complex|species|CC|Lineage)$/ } @row ];
}

sub _build_genotypes {
  my($self) = @_;
  my $res = {};
  my @gene = @{ $self->genes };
  open my $fh, '<', $self->_tab_file()
    or die "Could not open scheme file: $!";
  while (<$fh>) {
    next if m/^ST/;
    chomp;
    my @col = split m/\t/;
    #allow
    #next unless $col[0] =~ m/^\d+$/;
    my $sig = join "/", map { $col[$_] || '-' } (1 .. @gene);
    $res->{ $sig } = $col[0];
  }  
  return $res;
}

sub _build_num_genotypes {
  my($self) = @_;
  my $g = $self->genotypes;
  #print Dumper($g);
  return scalar values %$g;
}

sub _build_num_alleles {
  my($self) = @_;
  my %count;
  my @g = $self->genes->@*;
  for my $sig (keys $self->genotypes->%*) {
    my @n = split m'/', $sig;
    @n = map { $g[$_].'_'.$n[$_] } 0 .. $#n;
    map { $count{$_}++ } @n;
    #print Dumper($sig, \@n);
  }
  #print Dumper($self->name, $self->num_genes, \%count);
  return scalar keys %count;
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

