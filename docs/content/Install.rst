Installation
================

Docker image is available at `DockerHub <https://hub.docker.com/r/rnakato/churros>`_.

Docker
++++++++++++++

To use the docker command, type:

.. code-block:: bash

   # Pull docker image
   docker pull rnakato/churros

   # Container login
   docker run --rm -it rnakato/churros /bin/bash
   # Execute a command
   docker run -it --rm rnakato/churros <command>


Singularity
+++++++++++++++++++++++

Singularity is the alternative way to use the docker image.
With this command you can build the singularity file (.sif) of Churros:

.. code-block:: bash

   singularity build churros.sif docker://rnakato/churros

Instead, you can download the Churros singularity image from our `Dropbox <https://www.dropbox.com/scl/fo/lptb68dirr9wcncy77wsv/h?rlkey=whhcaxuvxd1cz4fqoeyzy63bf&dl=0>`_ (We use singularity version 3.8.5).

Then you can run Churros with the command:

.. code-block:: bash

   singularity exec churros.sif <command>

Singularity will automatically mount the current directory. If you want to access the files in the other directory, use the ``--bind`` option, for instance:

.. code-block:: bash

   singularity exec --bind /work churros.sif <command>

This command mounts the ``/work`` directory.

Tools installed in Churros
++++++++++++++++++++++++++++++++++++++++++++++

The latest version of **Churros** uses the following tools internally.

- Mapping
   - `Bowtie <https://bowtie-bio.sourceforge.net/manual.shtml>`_ v1.3.1
   - `Bowtie2 <https://bowtie-bio.sourceforge.net/bowtie2/index.shtml>`_ v2.5.3
   - `BWA <https://bio-bwa.sourceforge.net/>`_ v0.7.17
   - `chromap <https://github.com/haowenz/chromap>`_ v0.2.5

- ChIP-seq analysis
   - `MACS2 <https://github.com/macs3-project/MACS>`_ v2.2.9.1
   - `DROMPA+ <https://drompaplus.readthedocs.io/en/latest/>`_ v1.20.0
   - `ROSE <http://younglab.wi.mit.edu/super_enhancer_code.html>`_ v0.1
   - `STARE <https://stare.readthedocs.io/en/latest/index.html>`_ v1.0.4
   - `ChromImpute <https://ernstlab.biolchem.ucla.edu/ChromImpute/>`_ v1.0.5

- ATAC-seq analysis
   - `ATACseqQC <https://bioconductor.org/packages/release/bioc/html/ATACseqQC.html>`_ v1.26.0
   - `TOBIAS <https://github.com/loosolab/TOBIAS>`_ v0.16.1
   
- Peak analysis
   - `ChIPseeker <https://bioconductor.org/packages/release/bioc/html/ChIPseeker.html>`_ v1.36.0
   - `intervene <https://intervene.readthedocs.io/en/latest/install.html>`_ v0.6.5

- DNA methylation analysis
   - `Bismark <https://github.com/FelixKrueger/Bismark>`_  v0.22.3
   - `methylKit <https://www.bioconductor.org/packages/release/bioc/html/methylKit.html>`_  v1.28.0
   - `MEDIPS <https://www.bioconductor.org/packages/release/bioc/html/MEDIPS.html>`_ v1.54.0
   - `abismal <https://github.com/smithlabcode/abismal>`_  v3.2.3
   - `MethPipe <https://smithlabresearch.org/software/methpipe/>`_ v5.0.0

- Differential analysis
   - `edgeR <https://bioconductor.org/packages/release/bioc/html/edgeR.html>`_ v3.42.4
   - `DESeq2 <https://bioconductor.org/packages/release/bioc/html/DESeq2.html>`_ v1.40.2

- Functional analysis
   - `STITCHIT <https://github.com/SchulzLab/STITCHIT>`_: link regulatory elements to genes
   - `clusterProfiler <https://bioconductor.org/packages/release/bioc/html/clusterProfiler.html>`_ v4.8.2
   - `rGREAT <https://bioconductor.org/packages/release/bioc/html/rGREAT.html>`_ v2.2.0

- Motif analysis
   - `HOMER <http://homer.ucsd.edu/homer/>`_ v4.11
   - `TFBSTools <https://bioconductor.org/packages/release/bioc/html/TFBSTools.html>`_ v1.40.0
   - `motifbreakR <https://bioconductor.org/packages/release/bioc/html/motifbreakR.html>`_ v2.14.2

- Chromatin state analysis
   - `ChromHMM <https://compbio.mit.edu/ChromHMM/>`_ v1.25
   - `epilogos <https://epilogos.altius.org/>`_ v0.1.2

- Quality assessment
   - `FastQC <https://www.bioinformatics.babraham.ac.uk/projects/fastqc/>`_ v0.11.9
   - `fastp <https://github.com/OpenGene/fastp>`_ v0.23.2
   - `MultiQC <https://multiqc.info/>`_ v1.21
   - `SSP <https://github.com/rnakato/SSP>`_ v1.4.0

- File processing
   - `SAMtools <http://www.htslib.org/>`_ v1.19.2
   - `sambamba <https://github.com/biod/sambamba>`_ v0.6.6
   - `BEDtools <https://bedtools.readthedocs.io/en/latest/>`_ v2.31.0
   - `deepTools <https://deeptools.readthedocs.io/>`_  v3.5.5

- Adapter trimming
   - `Cutadapt <https://cutadapt.readthedocs.io/en/stable/index.html>`_ v4.7
   - `TrimGalore <https://github.com/FelixKrueger/TrimGalore>`_ v0.6.7

- Mappability calculation
   - `MOSAiCS <https://pages.stat.wisc.edu/~keles/Software/mosaics/>`_
   - `GenMap <https://github.com/cpockrandt/genmap>`_ v1.2.0

- Utility tools
   - `SRAtoolkit <https://github.com/ncbi/sra-tools>`_ v3.0.10
