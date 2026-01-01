#!/usr/bin/env bats

setup() {
  name="mlst"
  bats_require_minimum_version 1.5.0
  dir=$(dirname "$BATS_TEST_FILENAME")
  cd "$dir"
  bin="$dir/../bin/$name"
  exe="$bin --quiet --skipcheck"
  tab=$'\t'
  SEPI="${tab}sepidermidis${tab}184${tab}"
}

@test "Script syntax check" {
  run -0 perl -c "$dir/../bin/$name"
}
@test "Version" {
  run -0 $exe --version
  [[ "$output" =~ "$name" ]]
}
@test "Help" {
  run -0 $exe --help
  [[ "$output" =~ "threads" ]]
}
@test "Try --check" {
  run -0 $bin --check
  [[ "$output" =~ "OK" ]]
}
@test "No parameters" {
  run $exe
}
@test "Bad option" {
  run ! $exe --doesnotexist
  [[ "$output" =~ "Unknown option" ]]
  [[ ! "$output" =~ "USAGE" ]]
}
@test "List schemes (short)" {
  run -0 $exe --list
  [[ "$output" =~ "saureus" ]]
}
@test "List schemes (long)" {
  run -0 $exe --longlist
  [[ "$output" =~ "saureus" ]]
}
@test "Passing a folder" {
  run ! $exe $dir
  [[ "$output" =~ "directory" ]]
}
@test "Null input" {
  run ! $exe null.fa
  [[ "$output" =~ "ERROR" ]]
}
@test "Empry input" {
  run ! $exe --no-quiet empty.fa
  [[ "$output" =~ "Sequence contains no data" ]]
}
@test "Plain FASTA" {
  run -0 $exe example.fna
  [[ "$output" =~ "$SEPI" ]]  
}
@test "Gzipped FASTA" {
  run -0 $exe example.fna.gz
  [[ "$output" =~ "$SEPI" ]]  
}
@test "Gzipped Genbank" {
  run -0 $exe example.fna.gz
  [[ "$output" =~ "$SEPI" ]]  
}
@test "Bzipped FASTA" {
  run -0 $exe novel.fasta.bz2
  [[ "$output" =~ "leptospira_2" ]]  
}
@test "Zipped FASTA" {
  run -0 $exe mixed.fa.zip
  [[ "$output" =~ "mgen" ]]
}
@test "FOFN input" {
  run -0 $exe --quiet --fofn fofn.txt
  [[ "${lines[0]}" =~ $SEPI ]]  
  [[ "${lines[1]}" =~ $SEPI ]]  
  [[ "${lines[2]}" =~ $SEPI ]]  
}
@test "Bad FOFN input" {
  run ! $exe --fofn /dev/null
}
@test "Try --skipcheck" {
  run -0 $exe --no-quiet --skipcheck example.fna.gz
  [[ ! "$output" =~ "Checking mlst dependencie" ]]
}
@test "Accept STDIN" {
  run bats_pipe gzip -d -c example.fna.gz \| $exe /dev/stdin
  [[ "$output" =~ $SEPI ]]  
}
@test "Two files in legacy mode " {
  run -0 $exe example.fna.gz example.gbk.gz
  [[ "$output" =~ $SEPI ]]  
}
@test "Finds duplicate alleles" {
  run -0 $bin mixed.fa.zip
  [[ "$output" =~ "pgm(3,3)"  ]]
  [[ "$output" =~ "atpA(1,1)" ]]
  [[ "$output" =~ "WARNING"  ]]
}
@test "CSV output" {
  run -0 $exe --csv example.fna.gz
  [[ "$output" =~ ",184," ]]  
}
@test "Detect GOOD" {
  run -0 $exe --full --csv example.fna
  [[ "${lines[1]}" =~ ",GOOD," ]]
}
@test "Detect MIXED" {
  run -0 $exe --full --csv mixed.fa.zip
  [[ "${lines[1]}" =~ ",MIXED," ]]
}
@test "Detect NOVEL" {
  run -0 $exe --full --csv novel.fa
  [[ "${lines[1]}" =~ ",NOVEL," ]]
}
@test "Detect BAD" {
  run -0 $exe --full --csv messy.fa
  [[ "${lines[1]}" =~ ",BAD," ]]
}

@test "JSON output" {
  local outfile="${BATS_TMPDIR}/$name.json"
  run -0 $exe --json "$outfile" example.fna.gz
  [[ -r "$outfile" ]]
  run -0 grep 'sequence_type' "$outfile"
}
@test "Custom label" {
  run -0 $exe --label GDAYMATE example.fna.gz
  [[ "$output" =~ "GDAYMATE" ]]
}
@test "Duplicate label" {
  run ! $exe --label double_trouble example.gbk.gz example.fna.gz
}
@test "Save novel allele " {
  local outfile="${BATS_TMPDIR}/$name.novel.fa"
  run -0 $exe --novel "$outfile" novel.fasta.bz2
  [[ -r "$outfile" ]]
  run -0 grep 'mreA' "$outfile"
}
@test "Test issue 146" {
  run -0 $exe issue146.fa
  [[ "$output" =~ "purE(25)" ]]  
}
@test "Script: show_seqs" {
  run -0 "$dir/../scripts/mlst-show_seqs" -s efaecium -t 111
  [[ "$output" =~ ">atpA_2" ]]  
}
