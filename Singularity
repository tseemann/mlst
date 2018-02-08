Bootstrap: docker
From: ubuntu:trusty-20170817

%help
A Singularity image for MLST v2.10

%labels
Maintainer Anders Goncalves da Silva
Build 1.0
MLST_version 2.10
BLAST_version 2.7.1+

%environment
MLST_VERSION=2.10
export MLST_VERSION

%post
 # set versions of software to install
  MLST_VERSION=2.10
  BLAST_VERSION=2.7.1

  sudo locale-gen en_US.UTF-8
  sudo update-locale

  sudo apt-get --yes update
  sudo apt-get --yes install make wget

  echo "Installing PERL dependencies"
  sudo cpan install Moo List::MoreUtils JSON File::Slurp

  echo "Installing BLAST"

  BLAST_DL="ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/${BLAST_VERSION}/ncbi-blast-${BLAST_VERSION}+-x64-linux.tar.gz"
  BLAST_TAR=blast.tar.gz
  wget -O ${BLAST_TAR} "${BLAST_DL}"
  tar xzf ${BLAST_TAR}
  BLAST_DIR="ncbi-blast-${BLAST_VERSION}+"
  sudo cp -R ${BLAST_DIR}/bin/* /usr/local/bin
  rm -r ${BLAST_DIR} ${BLAST_TAR}


  echo "Installing MLST"

  # There are two patterns for MLST releases: v2.10.tar.gz or 2.8.tar.gz
  MLST_DL1="https://github.com/tseemann/mlst/archive/${MLST_VERSION}.tar.gz"
  MLST_DL2="https://github.com/tseemann/mlst/archive/v${MLST_VERSION}.tar.gz"
  MLST_TAR=mlst.tar.gz
  if [[ `wget -S --spider ${MLST_DL1}  2>&1 | grep 'HTTP/1.1 200 OK'` ]];
  then
    wget -O ${MLST_TAR} "${MLST_DL1}"
  else
    wget -O ${MLST_TAR} "${MLST_DL2}"
  fi
  tar zxf ${MLST_TAR}
  MLST_DIR="mlst-${MLST_VERSION}"
  sudo cp ${MLST_DIR}/bin/* /usr/local/bin
  sudo mkdir -p /usr/local/db
  sudo cp -R ${MLST_DIR}/db/* /usr/local/db
  sudo mkdir -p /usr/local/perl5
  sudo cp -R ${MLST_DIR}/perl5/* /usr/local/perl5
  rm -r ${MLST_DIR} ${MLST_TAR}

  echo "Sorting some env variables..."
  sudo echo 'LANGUAGE="en_US:en"' >> $SINGULARITY_ENVIRONMENT
  sudo echo 'LC_ALL="en_US.UTF-8"' >> $SINGULARITY_ENVIRONMENT
  sudo echo 'LC_CTYPE="UTF-8"' >> $SINGULARITY_ENVIRONMENT
  sudo echo 'LANG="en_US.UTF-8"' >>  $SINGULARITY_ENVIRONMENT

  echo "Done"

%runscript
  echo "Welcome to MLST ${MLST_VERSION}" >&2
  exec mlst "$@"

%test
  echo "Testing MLST"
  echo "Test Genome is a Neisseria meningitidis ST74!"
  GENOME="ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/008/805/GCF_000008805.1_ASM880v1/GCF_000008805.1_ASM880v1_genomic.gbff.gz"
  wget -O /tmp/test.gbk.gz ${GENOME}
  mlst /tmp/test.gbk.gz > /tmp/res 2> /dev/null
  cat /tmp/res
  res=$(grep neisseria /tmp/res)
  if [ -n "${res}" ];
    then
      echo "MLST installed successfully!";
    else
      echo "Something went wrong!";
    fi;
  rm /tmp/test.gbk.gz /tmp/res
