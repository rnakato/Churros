# Churros: Docker image for ChIP-seq/ATAC-seq analysis

## 1. Installation

Docker image is available at [DockerHub](https://hub.docker.com/r/rnakato/churros).

### 1.1 Docker 
To use docker command, type:

    docker pull rnakato/churros
    docker run -it --rm rnakato/churros <command>

### 1.2 Singularity

Singularity can also be used to execute the docker image:

    singularity build churros.sif docker://rnakato/churros
    singularity exec churros.sif <command>

Singularity mounts the current directory automatically. If you access the files in the other directory, mount it by `--bind` option:

    singularity exec --bind /work churros.sif <command>
    
This command mounts `/work` directory.

## 2. Quickstart

``churros`` command executes all steps from mapping to visualization.

    # download Churros/tutorial directory
    git clone https://github.com/rnakato/Churros.git
    cd Churros/tutorial/
    
    # download fastq and genome data and make index
    bash 00_getdata.sh
    
    # Execute Churros pipeline
    bash Quickstart.sh

Then the results are output in `Churros_result` directory.

## 3. Usage

See https://churros.readthedocs.io for the detailed Manual.


## 4. Build Docker image from Dockerfile

First clone and move to the repository

    git clone https://github.com/rnakato/Churros.git
    cd Churros

Then type:

    docker build -t <account>/churros

## 6. Contact

Ryuichiro Nakato: rnakato AT iqb.u-tokyo.ac.jp
