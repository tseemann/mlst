[![Build Status](https://travis-ci.org/tseemann/mlst.svg?branch=master)](https://travis-ci.org/tseemann/mlst)
[![License: GPL v2](https://img.shields.io/badge/License-GPL%20v2-blue.svg)](https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html)
![Don't judge me](https://img.shields.io/badge/Language-Perl_5-steelblue.svg)

# mlst

Scan contig files against traditional PubMLST typing schemes

## Quick Start

```
% mlst contigs.fa
contigs.fa  neisseria  11149  abcZ(672) adk(3) aroE(4) fumC(3) gdh(8) pdhC(4) pgm(6)

% mlst genome.gbk.gz
genome.gbk.gz  sepidermidis  184  arcC(16) aroE(1) gtr(2) mutS(1) pyrR(2) tpiA(1) yqiL(1)

% mlst --label Anthrax GCF_001941925.1_ASM194192v1_genomic.fna.bz2
Anthrax  bcereus  -  glp(24) gmk(1) ilv(~83) pta(1) pur(~71) pyc(37) tpi(41)

% mlst --nopath /opt/data/refseq/S_pyogenes/*.fna
NC_018936.fna  spyogenes  28   gki(4)   gtr(3)   murI(4)   mutS(4)  recP(4)    xpt(2)   yqiL(4)
NC_017596.fna  spyogenes  11   gki(2)   gtr(6)   murI(1)   mutS(2)  recP(2)    xpt(2)   yqiL(2)
NC_008022.fna  spyogenes  55   gki(11)  gtr(9)   murI(1)   mutS(9)  recP(2)    xpt(3)   yqiL(4)
NC_006086.fna  spyogenes  382  gki(5)   gtr(52)  murI(5)   mutS(5)  recP(5)    xpt(4)   yqiL(3)
NC_008024.fna  spyogenes  -    gki(5)   gtr(11)  murI(8)   mutS(5)  recP(15?)  xpt(2)   yqiL(1)
NC_017040.fna  spyogenes  172  gki(56)  gtr(24)  murI(39)  mutS(7)  recP(30)   xpt(2)   yqiL(33)
```

## Installation

### Conda
If you are using [Conda](https://bioconda.github.io/user/install.html)
```
% conda install -c conda-forge -c bioconda -c defaults mlst
```

### Brew
If you are using the [MacOS Homebrew](http://brew.sh/)
or [LinuxBrew](http://brew.sh/linuxbrew/) packaging system:

```
% brew install brewsci/bio/mlst
```

### Source

```
% cd $HOME
% git clone https://github.com/tseemann/mlst.git
% $HOME/mlst/bin/mlst --help
```   
 
### Dependencies

* [Perl](https://www.perl.org/) >= 5.26
* [NCBI BLAST+ blastn](https://www.ncbi.nlm.nih.gov/books/NBK279671/) >= 2.9.0
  * You probably have `blastn` already installed already.
  * If you use Brew or Conda, this will install the `blast` package for you.
* Perl modules: `Moo`,`List::MoreUtils`,`JSON`
  * Debian: `sudo apt-get install libmoo-perl liblist-moreutils-perl libjson-perl`
  * Redhat: `sudo apt-get install perl-Moo perl-List-MoreUtils perl-JSON`
  * Most Unix: `sudo cpan Moo List::MoreUtils JSON`
* [any2fasta](https://github.com/tseemann/any2fasta)
  * Converts sequence files to FASTA, even compressed ones

## Usage

Simply just give it a genome file in FASTA/GenBank/EMBL format,
optionally compressed with gzip, zip or bzip2.

```
% mlst contigs.fa
contigs.fa  neisseria  11149  abcZ(672) adk(3) aroE(4) fumC(3) gdh(8) pdhC(4) pgm(6)
```

It returns a tab-separated line containing
* the filename
* the matching PubMLST scheme name
* the ST (sequence type)
* the allele IDs

You can give it multiple files at once, and they can be in
FASTA/GenBank/EMBL format, and even compressed with gzip, bzip2 or zip.

```
% mlst genomes/*
genomes/6008.fna        saureus         239  arcc(2)   aroe(3)   glpf(1)   gmk_(1)   pta_(4)   tpi_(4)   yqil(3)
genomes/strep.fasta.gz  ssuis             1  aroA(1)   cpn60(1)  dpr(1)    gki(1)    mutS(1)   recA(1)   thrA(1)
genomes/NC_002973.gbk   lmonocytogenes    1  abcZ(3)   bglA(1)   cat(1)    dapE(1)   dat(3)    ldh(1)    lhkA(3)
genomes/L550.gbk.bz2    leptospira      152  glmU(26)  pntA(30)  sucA(28)  tpiA(35)  pfkB(39)  mreA(29)  caiB(29)
```

### Without auto-detection

You can force a particular scheme (useful for reporting systems):

```
% mlst --scheme neisseria NM*
NM003.fa   neisseria  4821  abcZ(222)  adk(3)  aroE(58)  fumC(275)  gdh(30)  pdhC(5)  pgm(255)
NM005.gbk  neisseria  177   abcZ(7)    adk(8)  aroE(10)  fumC(38)   gdh(10)  pdhC(1)  pgm(20)
NM011.fa   neisseria  11    abcZ(2)    adk(3)  aroE(4)   fumC(3)    gdh(8)   pdhC(4)  pgm(6)
NMC.gbk.gz neisseria  8     abcZ(2)    adk(3)  aroE(7)   fumC(2)    gdh(8)   pdhC(5)  pgm(2)
```

You can make `mlst` behave like older version before auto-detection existed
by  providing the `--legacy` parameter with the  `--scheme` parameter. In that case
it will print a fixed tabular output with a heading containing allele names specific to that scheme:

```
% mlst --legacy --scheme neisseria *.fa
FILE      SCHEME     ST    abcZ  adk  aroE  fumC  gdh  pdhC  pgm
NM003.fa  neisseria  11    2     3    4     3       8     4    6
NM009.fa  neisseria  11149 672   3    4     3       8     4    6
MN043.fa  neisseria  11    2     3    4     3       8     4    6
NM051.fa  neisseria  11    2     3    4     3       8     4    6
NM099.fa  neisseria  1287  2     3    4    17       8     4    6
NM110.fa  neisseria  11    2     3    4     3       8     4    6
```

### Available schemes

To see which PubMLST schemes are supported:

```
% mlst --list

abaumannii achromobacter aeromonas afumigatus cdifficile efaecium
hcinaedi hparasuis hpylori kpneumoniae leptospira
saureus xfastidiosa yersinia ypseudotuberculosis yruckeri
```

The above list is shortened. You can get more details using `mlst --longlist`.

```
achromobacter     nusA       rpoB      eno       gltB      lepA       nuoL      nrdA
abaumannii        Oxf_gltA   Oxf_gyrB  Oxf_gdhB  Oxf_recA  Oxf_cpn60  Oxf_gpi   Oxf_rpoD
abaumannii_2      Pas_cpn60  Pas_fusA  Pas_gltA  Pas_pyrG  Pas_recA   Pas_rplB  Pas_rpoB
aeromonas         gyrB       groL      gltA      metG      ppsA       recA
aphagocytophilum  pheS       glyA      fumC      mdh       sucA       dnaN      atpA
arcobacter        aspA       atpA      glnA      gltA      glyA       pgm       tkt
afumigatus        ANX4       BGT1      CAT1      LIP       MAT1_2     SODB      ZRF2
bcereus           glp        gmk       ilv       pta       pur        pyc       tpi
<snip>
```

### Missing data

Version 2.x does not just look for exact matches to full length alleles. 
It attempts to tell you as much as possible about what it found using the
notation below:

Symbol | Meaning | Length | Identity
---   | --- | --- | ---
`n`   | exact intact allele                   | 100%            | 100%
`~n`  | novel full length allele similar to n | 100%            | &ge; `--minid`
`n?`  | partial match to known allele         | &ge; `--mincov` | &ge; `--minid`
`-`   | allele missing                        | &lt; `--mincov` | &lt; `--minid`
`n,m` | multiple alleles                      | &nbsp;          | &nbsp;

### Scoring system

Each MLST prediction gets a score out of 100.
The score for a scheme with N alleles is as follows:

* +90/N points for an exact allele match _e.g._ `42`
* +63/N points for a novel allele match (50% of an exact allele) _e.g._ `~42`
* +18/N points for a partial allele match (20% of an exact alelle) _e.g._ `42?`
* 0 points for a missing allele _e.g._ `-`
* +10 points if there is a matching ST type for the allele combination

It is possible to filter results using the `--minscore` option which takes a
value between 1 and 100. If you only want to report known ST types, then use
`--minscore 100`. To also include novel combinations of existing alleles with
no ST type, use `--minscore 90`. The default is `--minscore 50` which is an
_ad hoc_ value I have found allows for genuine partial ST matches
but eliminates false positives.

## Tweaking the output

The output is TSV (tab-separated values). This makes it easy to parse 
and manipulate with Unix utilities like cut and sort etc. For example, 
if you only want the filename and ST you can do the following:
```
% mlst --scheme abaumanii AB*.fasta | cut -f1,3 > ST.tsv
```    
If you prefer CSV because it loads more smoothly into MS Excel, use the `--csv` option:
```
% mlst --csv Peptobismol.fna.gz > mlst.csv
```
JSON output is available too; it returns an array of dictionaries, one per
input file. The `id` will be the same as `filename` unless `--label` is
used, but that only works when scanning a single file.
```
% mlst -q --json out.json test/example.gbk.gz test/novel.fasta.bz2
% cat out.json
[
   {
      "scheme" : "sepidermidis",
      "alleles" : {
         "mutS" : "1",
         "yqiL" : "1",
         "tpiA" : "1",
         "pyrR" : "2",
         "gtr" : "2",
         "aroE" : "1",
         "arcC" : "16"
      },
      "sequence_type" : "184",
      "filename" : "test/example.gbk.gz",
      "id" : "test/example.gbk.gz"
   },
   {
      "sequence_type" : "-",
      "filename" : "test/novel.fasta.bz2",
      "scheme" : "spneumoniae",
      "alleles" : {
         "gki" : "2",
         "aroE" : "7",
         "ddl" : "22",
         "gdh" : "15",
         "xpt" : "1",
         "recP" : "~10",
         "spi" : "6"
      },
      "id" : "test/novel.fasta.bz2"
   }
]
```
You can also save the "novel" alleles for submission to PubMLST::
```
% mlst -q --novel nouveau.fa s_myces.fasta

% cat nouveau.fa

>streptomyces.recA-e562a2cd93e701e3b58ba0670bcbba0c s_myces.fasta
GACGTGGCCCTCGGCGTCGGCGGTCTGCCGCGCGGCCGCGTCGTCGAGATCTACGGACCGGAGTCCTCC...
```
The format of the sequence IDs is `scheme.allele-hash filename` where
`hash` is the hexadecimal MD5 digest of the allele DNA sequence.

## Mapping to genus/species

Included is a file called `db/scheme_species_map.tab` which has 3
tab-separated columns as follows:

```
#SCHEME GENUS   SPECIES
abaumannii      Acinetobacter   baumannii
abaumannii_2    Acinetobacter   baumannii
achromobacter   Achromobacter
aeromonas       Aeromonas
afumigatus      Aspergillus     afumigatus
arcobacter      Arcobacter
bburgdorferi    Borrelia        burgdorferi
bhampsonii      Brachyspira     hampsonii
bhenselae       Bartonella      henselae
borrelia        Borrelia
bpilosicoli     Brachyspira     pilosicoli
<snip>
```

Note that that some schemes are species specific, and others are genus
specific, so the `SPECIES` column is empty.  Note that the same
species/genus can apply to multiple schemes, see `abaumanii` above.

## Updating the database

The `mlst` software comes bundled with the traditional MLST databases;
namely those schemes with less than 10 genes. I strive to make regular
releases with updated databases, but if this is not frequent enough you
can update the databases yourself using some tools included in the `scripts`
folder as follows:

```
# Figure out where mlst is installed
% which mlst
/home/user/sw/mlst

# Go into the scripts folder (you need to have write access!)
% cd /home/user/sw/mlst/scripts

# Run the downloader script (you need 'wget' installed)
% ./mlst-download_pub_mlst | bash

# Check it downloaded everything ok
% find pubmlst | less

# Save the old database folder
% mv ../db/pubmlst ../db/pubmlst.old

# Put the new folder there
% mv ./pubmlst ../db/

# Regenerate the BLAST database
% ./mlst-make_blast_db

# Check schemes are installed
% ../bin/mlst --list
```

## Adding a new scheme 

If you are unable or unwilling to add your scheme to PubMLST via 
[BIGSdb](https://pubmlst.org/software/database/bigsdb/) you can
insert a new scheme into your local `mlst` database.

### The directory structure

Each MLST scheme exists in a folder withing the `mlst/db/pubmlst` folder.
The name of the folder is the scheme name, say `saureus` for 
*Staphylococcus aureus*. It contains files like this:
```
% cd mlst/db/pubmlst/sareus
% ls -1
saureus.txt
arcC.tfa
aroE.tfa
glpF.tfa
gmk.tfa
pta.tfa
tpi.tfa
yqiL.tfa
```
The folder name (ie. `saureus`) **must** be the same name
as the scheme file (ie. `saureus.txt`) or it will not work.

### The scheme file

The `saureus.txt` is a tab-separated file containing one ST definition
per row. The header line must be present.  Extra columns with names
`mlst_clade,clonal_complex,species,CC,Lineage` are ignored.

```
% head -n 5 saureus.txt
ST      arcC    aroE    glpF    gmk     pta     tpi     yqiL    clonal_complex
1       1       1       1       1       1       1       1
2       2       2       2       2       2       2       26
3       1       1       1       9       1       1       12
4       10      10      8       6       10      3       2
```

### The allele sequence files

Each of the `.tfa` files are nucleotide FASTA files with the allele
sequences for each locus. There must be a `.tfa` file for each and every
allele locus in the TSV scheme `.txt` file. Here is what the `arcC.tfa`
file looks like:
```
% head -n 20 arcC.tfa
>arcC_1
TTATTAATCCAACAAGCTAAATCGAACAGTGACACAACGCCGGCAATGCCATTGGATACT
TGTGGTGCAATGTCACAGGGTATGATAGGCTATTGGTTGGAAACTGAAATCAATCGCATT
TTAACTGAAATGAATAGTGATAGAACTGTAGGCACAATCGTTACACGTGTGGAAGTAGAT
AAAGATGATCCACGATTCAATAACCCAACCAAACCAATTGGTCCTTTTTATACGAAAGAA
GAAGTTGAAGAATTACAAAAAGAACAGCCAGACTCAGTCTTTAAAGAAGATGCAGGACGT
GGTTATAGAAAAGTAGTTGCGTCACCACTACCTCAATCTATACTAGAACACCAGTTAATT
CGAACTTTAGCAGACGGTAAAAATATTGTCATTGCATGCGGTGGTGGCGGTATTCCAGTT
ATAAAAAAAGAAAATACCTATGAAGGTGTTGAAGCG
>arcC_2
TTATTAATCCAACAAGCTAAATCGAACAGTGACACAACGCCGGCAATGCCATTGGATACT
TGTGGTGCAATGTCACAAGGTATGATAGGCTATTGGTTGGAAACTGAAATCAATCGCATT
TTAACTGAAATGAATAGTGATAGAACTGTAGGCACAATCGTAACACGTGTGGAAGTAGAT
AAAGATGATCCACGATTTGATAACCCAACTAAACCAATTGGTCCTTTTTATACGAAAGAA
GAAGTTGAAGAATTACAAAAAGAACAGCCAGGCTCAGTCTTTAAAGAAGATGCAGGACGT
GGTTATAGAAAAGTAGTTGCGTCACCACTACCTCAATCTATACTAGAACACCAGTTAATT
CGAACTTTAGCAGACGGTAAAAATATTGTCATTGCATGCGGTGGTGGCGGTATTCCAGTT
ATAAAAAAAGAAAATACCTATGAAGGTGTTGAAGCG
```

The FASTA sequence IDs must be named as `>allele_number` or
`>allele-number`. Ideally the sequences will not contain any
ambiguous IUPAC symbols. *i.e.* just `A,T,C,G`.

### Adding a new scheme

1. Make a new folder in `mlst/db/pubmlst/SCHEME`
2. Put your `SCHEME.txt` file in there
3. Put your `ALLELE.tfa` files in there
4. Run `mlst/scripts/mlst-make_blast_db` to update the BLAST indices
5. Run `mlst --longlist | grep SCHEME` to see if it exists
6. Run `mlst --scheme SCHEME file.fasta` to see if it works

If it doesn't - go back and check you really did do Step 4 above.

## Citations

The `mlst` software incorporates components of the 
[PubMLST database](https://pubmlst.org/policy.shtml)
which must be cited in any publications that use `mlst`:

*"This publication made use of the PubMLST website (https://pubmlst.org/)
developed by Keith Jolley 
[(Jolley & Maiden 2010, BMC Bioinformatics, 11:595)](https://doi.org/10.1186/1471-2105-11-595)
and sited at the University of Oxford.  The development of that website was
funded by the Wellcome Trust".*

You should also cite this software (currently unpublished) as:

* Seemann T, `mlst` **Github** https://github.com/tseemann/mlst

## Bugs

Please submit via the [Github Issues page](https://github.com/tseemann/mlst/issues)

## Licence

[GPL v2](https://raw.githubusercontent.com/tseemann/mlst/master/LICENSE)

## Author

* Torsten Seemann
* Web: https://tseemann.github.io/
* Twitter: [@torstenseemann](https://twitter.com/torstenseemann)
* Blog: [The Genome Factory](https://thegenomefactory.blogspot.com/)
