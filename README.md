#mlst

Scan contig files against PubMLST typing schemes.

##Installation

The main Perl script and the included databases:

    % cd $HOME
    % git clone https://github.com/Victorian-Bioinformatics-Consortium/mlst.git
    
The only external dependency is the BLAT tools written by Jim Kent: http://genome.ucsc.edu/FAQ/FAQblat.html#blat3
    
    % cd $HOME/mlst/bin
    
    # Linux:
    % wget http://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/blat/blat
    # MacOSX:
    % wget http://hgdownload.cse.ucsc.edu/admin/exe/macOSX.x86_64/blat
    
    % chmod +x blat

Add it to your PATH:

    % echo "export PATH=$PATH:$HOME/mlst/bin" >> $HOME/.bashrc

Now log out, and log back in, and test that it works:

    % mlst -h
    % blat

Success!
    
##Usage

###Available schemes

To see which PubMLST schemes are supported:

    % mlst --list
    
    abaumannii achromobacter aeromonas afumigatus	cdifficile efaecium
    haemophilus	hcinaedi hparasuis hpylori kpneumoniae leptospira
    saureus xfastidiosa	yersinia ypseudotuberculosis yruckeri

The above list is shortened. The full included database includes 106 schemes.

###Genotyping one genome

To genotype a FASTA file of contigs:

    % mlst --scheme saureus USA300.fasta
    
    FILE	      SCHEME	ST	arcc aroe glpf gmk_	pta_ tpi_ yqil
    USA300.fasta  saureus	8	3	 3	  1    1	4	 4	  3

This produces a tab-separated values file, with a header line and a line 
for the FASTA file. The "ST" column is the MLST type, and the subsequent
columns are the allele variants for each of the locii within the scheme.
In this case, the USA300 genome is *Staphylococcus aureus* ST8.

Only full-length, 100% identity matches to an allelle are considered matches. 
If any allelles are not found, a "-" will be present in the allele column, 
as well as in the ST column.

###Genotyping many genomes

The software supports multiple genome FASTA files, even compressed ones. 

    % mlst --scheme efaecium VAN*.fna.gz

    FILE	SCHEME	    ST	 AtpA Ddl Gdh PurK Gyd	PstS Adk
    VAN_219	efaecium	784  2    3	   1  67	1	30	 25
    VAN_222	efaecium	784  2    3	   1  67	1	30	 25
    VAN_327	efaecium	417  5    7	   5  7  	2	1	 1
    VAN_332	efaecium	38	 2    5	   3  5	    4	4	 1
    VAN_335	efaecium	417	 5    7	   5  7	    2	1	 1
    VAN_342	efaecium	22	 2    3	   1  2	    1	1	 1
    VAN_345	efaecium	38	 2    5	   3  5	    4	4	 1
    VAN_476	efaecium	785	 2	  3	   1  67	1	86	 1
    
###Tweaking the output

The output is TSV (tab-separated values). This makes it easy to parse 
and manipulate with Unix utilities like cut and sort etc. For example, 
if you only want the filename and ST you can do the following:

    % mlst --scheme abaumanii AB*.fasta | cut -f1,3 > ST.tsv

If you don't want the header line use the `--noheader` option:

    % mlst --scheme leptospira --noheader L550.fa
    
If you prefer CSV because it loads more smoothly into MS Excel, use the `--csv` option:

    % mlst --scheme hpylori --csv Peptobismol.fna.gz > mlst.csv

##Bugs

Please submit via the Github Issues page: 
https://github.com/Victorian-Bioinformatics-Consortium/mlst/issues

##Licence

GPLv2

##Author

Torsten Seemann - http://vicbioinformatics.com/









