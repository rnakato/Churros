# Churros: Docker image for ChIP-seq/ATAC-seq analysis

<img src = "image/Churros.jpg" width = 700ptx>

## 0. Changelog

See [Changelog](https://github.com/rnakato/Churros/blob/main/ChangeLog.md)

## 1. Installation

Docker image is available at [DockerHub](https://hub.docker.com/r/rnakato/churros).

### 1.1 Docker

To use the docker command, type:

    # Pull docker image
    docker pull rnakato/churros

    # Container login
    docker run --rm -it rnakato/churros /bin/bash
    # Execute a command
    docker run -it --rm rnakato/churros <command>


### 1.2 Singularity

Singularity is the alternative way to use the docker image.
With this command you can build the singularity file (.sif) of Churros:

    singularity build churros.sif docker://rnakato/churros

Instead, you can download the Churros singularity image from our [Dropbox](https://www.dropbox.com/scl/fo/lptb68dirr9wcncy77wsv/h?rlkey=whhcaxuvxd1cz4fqoeyzy63bf&dl=0) (We use singularity version 3.8.5).

Then you can run RumBall with the command:

    singularity exec churros.sif <command>

Singularity will automatically mount the current directory. If you want to access the files in the other directory, use the `--bind` option, for instance:

    singularity exec --bind /work churros.sif <command>

This command mounts the `/work` directory.

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
    cd Churros/Dockerfiles/

Then type:

    docker build -f Dokerfile.<version> -t <account>/churros

## 5. Reference

- Wang J, Nakato R, Churros: a Docker-based pipeline for large-scale epigenomic analysis, *DNA Research*, 2023. doi: [10.1093/dnares/dsad026](https://academic.oup.com/dnaresearch/article/31/1/dsad026/7475777)
