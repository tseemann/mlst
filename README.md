# mlst

Scan contig files against PubMLST typing schemes

## Quick Start

    % mlst contigs.fa
    contigs.fa  neisseria  11149  abcZ(672)  adk(3)  aroE(4) fumC(3) gdh(8) pdhC(4) pgm(6)

## Installation

### Brew
If you are using the [OSX Brew](http://brew.sh/) or [LinuxBrew](http://brew.sh/linuxbrew/) packaging system:

    brew tap homebrew/science
    brew update
    brew install mlst

Or if you already have the old version installed:

    brew update
    brew upgrade mlst

### Source

    % cd $HOME
    % git clone https://github.com/tseemann/mlst.git
    
### Dependencies

* [NCBI BLAST+ blastn](https://www.ncbi.nlm.nih.gov/books/NBK279671/) 
  * You probably have `blastn` already installed already.
  * If you use Brew, this will install the `blast` package for you.
* Perl modules *Moo* and *List::MoreUtils*
  * Debian: `sudo apt-get install libmoo-perl liblist-moreutils-perl`
  * Redhat: `sudo apt-get install perl-Moo perl-List-MoreUtils`
  * Most Unix: `sudo cpan Moo List::MoreUtils`

## Usage

Simply just give it a genome file in FASTA or GenBank file!

    % mlst contigs.fa
    contigs.fa  neisseria  11149  abcZ(672)  adk(3)  aroE(4) fumC(3) gdh(8) pdhC(4) pgm(6)

It returns a tab-separated line containing
* the filename
* the closest PubMLST scheme name
* the ST (sequence type)
* the allele IDs

You can give it multiple files at once, and they can be in FASTA or GenBank format, and even compressed with gzip!

    % mlst genomes/*
    genomes/6008.fna        saureus         239  arcc(2)   aroe(3)   glpf(1)   gmk_(1)   pta_(4)   tpi_(4)   yqil(3)
    genomes/strep.fasta.gz  ssuis             1  aroA(1)   cpn60(1)  dpr(1)    gki(1)    mutS(1)   recA(1)   thrA(1)
    genomes/NC_002973.gbk   lmonocytogenes    1  abcZ(3)   bglA(1)   cat(1)    dapE(1)   dat(3)    ldh(1)    lhkA(3)
    genomes/L550.gbk.gz     leptospira      152  glmU(26)  pntA(30)  sucA(28)  tpiA(35)  pfkB(39)  mreA(29)  caiB(29)

## Without auto-detection

You can make `mlst 2.0` behave like previous versions by simply providing the `--scheme XXXX` parameter. In that case
it will print a fixed tabular output with a heading containing allele names specific to that scheme:

    % mlst --scheme neisseria *.fa
    FILE      SCHEME     ST    abcZ  adk  aroE  fumC  gdh  pdhC  pgm
    NM003.fa  neisseria  11    2     3    4     3       8     4    6
    NM009.fa  neisseria  11149 672   3    4     3       8     4    6
    MN043.fa  neisseria  11    2     3    4     3       8     4    6
    NM051.fa  neisseria  11    2     3    4     3       8     4    6
    NM099.fa  neisseria  1287  2     3    4    17       8     4    6
    NM110.fa  neisseria  11    2     3    4     3       8     4    6

## Available schemes

To see which PubMLST schemes are supported:

    % mlst --list
    
    abaumannii achromobacter aeromonas afumigatus cdifficile efaecium
    hcinaedi hparasuis hpylori kpneumoniae leptospira
    saureus xfastidiosa	yersinia ypseudotuberculosis yruckeri

The above list is shortened. You can get more details using `mlst --longlist`.

## Missing data

MLST 2.0 does not just look for exact matches to full length alleles. 
It attempts to tell you as much as possible about what it found using the
notation below:

Symbol | Meaning | Length | Identity
--- | --- | --- | ---
n   | exact intact allele                   | `100%`          | `100%`
~n  | novel full length allele similar to n | `100%`          | &ge; `--minid`
n?  | partial match to known allele         | &ge; `--mincov` | &ge; `--minid`
 -  | allele missing                        | &lt; `--mincov` | &lt; `--minid`
n,m | multiple alleles                      |                 |

### Tweaking the output

The output is TSV (tab-separated values). This makes it easy to parse 
and manipulate with Unix utilities like cut and sort etc. For example, 
if you only want the filename and ST you can do the following:

    % mlst --scheme abaumanii AB*.fasta | cut -f1,3 > ST.tsv
    
If you prefer CSV because it loads more smoothly into MS Excel, use the `--csv` option:

    % mlst --csv Peptobismol.fna.gz > mlst.csv

## Bugs

Please submit via the [Github Issues page](https://github.com/tseemann/mlst/issues)

## Licence

[GPL v2](https://raw.githubusercontent.com/tseemann/mlst/master/LICENSE)

## Author

* Torsten Seemann
* Web: https://tseemann.github.io/
* Twitter: [@torstenseemann](https://twitter.com/torstenseemann)
* Blog: [The Genome Factory](https://thegenomefactory.blogspot.com/)

