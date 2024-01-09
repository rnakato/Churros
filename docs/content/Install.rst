Installation
================

Docker image is available at `DockerHub <https://hub.docker.com/r/rnakato/churros>`_.

Docker
++++++++++++++

To use docker command, type:

.. code-block:: bash

   # pull docker image
   docker pull rnakato/churros
   # execute a command
   docker run -it --rm rnakato/churros <command>

Singularity
+++++++++++++++++++++++

Singularity can also be used to execute the docker image:

.. code-block:: bash

   # build image
   singularity build churros.sif docker://rnakato/churros
   # execute a command
   singularity exec churros.sif <command>

Singularity mounts the current directory automatically. If you access the files in the other directory,
mount it by ``--bind`` option:

.. code-block:: bash

   singularity exec --bind /work churros.sif <command>

This command mounts ``/work`` directory.

Tools installed in Churros
++++++++++++++++++++++++++++++++++++++++++++++

The latest version of **Churros** uses the following tools internally.

- Mapping
   - Bowtie v1.3.1
   - Bowtie2 v2.4.5
   - BWA v0.7.17
   - chromap v0.2.4

- ChIP-seq analysis
   - MACS2 v2.2.9.1
   - DROMPA+ v1.18.1
   - SSP v1.3.1
   - ROSE v0.1
   - ChromHMM v1.24
   - ChromImpute v1.0.3
   - epilogos v0.1.2

- ATAC-seq analysis
   - TOBIAS
   - HINT-ATAC

- Bisulfite sequencing (DNA methylation)
   - `Bismark <https://github.com/FelixKrueger/Bismark>`_  v0.22.3

- Differential analysis
   - `edgeR <https://bioconductor.org/packages/release/bioc/html/edgeR.html>`_ v3.42.4
   - `DESeq2 <https://bioconductor.org/packages/release/bioc/html/DESeq2.html>`_ v1.40.2

- Functional analysis
   - `ChIPseeker <https://bioconductor.org/packages/release/bioc/html/ChIPseeker.html>`_ v1.36.0
   - `HOMER <http://homer.ucsd.edu/homer/>`_ v4.11
   - `STITCHIT <https://github.com/SchulzLab/STITCHIT>`_: link regulatory elements to genes
   - `clusterProfiler <https://bioconductor.org/packages/release/bioc/html/clusterProfiler.html>`_ v4.8.2
   - `rGREAT <https://bioconductor.org/packages/release/bioc/html/rGREAT.html>`_ v2.2.0
   - `motifbreakR <https://bioconductor.org/packages/release/bioc/html/motifbreakR.html>`_ v2.14.2

- Quality assessment
   - FastQC v0.11.9
   - fastp v0.23.2
   - MultiQC v1.12

- File processing
   - `SAMtools <http://www.htslib.org/>`_ v1.17
   - `sambamba <https://github.com/biod/sambamba>`_ v0.6.6
   - `bedtools <https://bedtools.readthedocs.io/en/latest/>`_ v2.30.0
   - `deepTools <https://deeptools.readthedocs.io/>`_  v3.5.2

- Adapter trimming
   - `Cutadapt <https://cutadapt.readthedocs.io/en/stable/index.html>`_ v4.4
   - `TrimGalore <https://github.com/FelixKrueger/TrimGalore>`_ v0.6.7

- Mappability calculation
   - `MOSAiCS <https://pages.stat.wisc.edu/~keles/Software/mosaics/>`_
   - `GenMap <https://github.com/cpockrandt/genmap>`_ v1.2.0

- Utility tools
   - `SRAtoolkit <https://github.com/ncbi/sra-tools>`_ v3.0.2