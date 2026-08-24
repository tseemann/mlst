FROM quay.io/condaforge/miniforge3:latest

ARG MLST_VERSION=v2.35.0

LABEL description="Docker container for Torsten Seemann's mlst tool"
LABEL version="${MLST_VERSION}"

ENV DEBIAN_FRONTEND=non-interactive

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    wget \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Add Bioconda channel
RUN conda config --add channels bioconda

# Install blast, Perl modules, and any2fasta
RUN mamba install -y \
    blast \
    perl \
    perl-bioperl \
    perl-moo \
    perl-json \
    perl-list-moreutils \
    any2fasta \
    && mamba clean -a -y

# Clone the specified release tag
RUN git clone --depth 1 --branch ${MLST_VERSION} https://github.com/tseemann/mlst.git /opt/mlst

ENV PATH="/opt/mlst/bin:$PATH"
WORKDIR /data

ENTRYPOINT ["mlst"]
CMD ["--help"]
