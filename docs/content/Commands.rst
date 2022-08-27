Commands in Churros
============================

download_genomedata.sh
------------------------------------

``download_genomedata.sh`` downloads the genome and gene annotation files of the genome build specified.
**Churros** assumes the reference data is downloaded by this command.


.. code-block:: bash

    download_genomedata.sh <build> <outputdir>
      build:
             human (GRCh38, GRCh37, T2T)
             mouse (GRCm39, GRCm38)
             rat (mRatBN7.2)
             fly (BDGP6)
             zebrafish (GRCz11)
             chicken (GRCg6a)
             African clawed frog (xenLae2)
             C. elegans (WBcel235)
             S. serevisiae (R64-1-1)
             S. pombe (SPombe)
      Example:
             download_genomedata.sh GRCh38 Ensembl-GRCh38


build-index.sh: build index for ChIP-seq
-----------------------------------------------------

``build-index.sh`` builds index files of the tools specified. ``<odir>`` should be the same with ``<outputdir>`` directory 
provided in ``download_genomedata.sh``. If ``-a`` option is specified, all scaffolds are also indexed in addition to chromosomes. 
The ``<odir>`` is used in the **Churros** commands below.


.. code-block:: bash

    build-index.sh [-p ncore] -a <program> <odir>
        program: bowtie, bowtie-cs, bowtie2, bwa, chromap
        Example:
            build-index.sh bowtie2 Ensembl-GRCh38


bowtie.sh
------------------------------------------------

``bowtie.sh`` is a script to use Bowtie.


.. code-block:: bash

    bowtie.sh [Options] <fastq> <prefix> <build> <Ddir>
       <fastq>: fastq file
       <prefix>: output prefix
       <build>: genome build (e.g., hg38)
       <Ddir>: directory of bowtie index
       Options:
          -t STR: for SOLiD data ([fastq|csfata|csfastq], defalt: fastq)
          -c: output as CRAM format (defalt: BAM)
          -p INT: number of CPUs (default: 12)
          -P "STR": parameter of bowtie (shouled be quated, default: "-n2 -m1")
          -D: output dir (defalt: ./)
       Example:
          For single-end: bowtie.sh -P "-n2 -m1" chip.fastq.gz chip hg38 Ensembl-GRCh38
          For paired-end: bowtie.sh "\-1 chip_1.fastq.gz \-2 chip_2.fastq.gz" chip hg38 Ensembl-GRCh38
          For SOLiD data: bowtie.sh -t csfastq -P "-n2 -m1" chip.csfastq.gz chip hg38 Ensembl-GRCh38


chromHMM.sh:
------------------------------------------------

You can use chromHMM using ``chromHMM.sh <command>``, e.g., ``chromHMM.sh LearnModel``.
See the `ChromHMM website <http://compbio.mit.edu/ChromHMM/>`_ for the detail.


chromImpute.sh:
------------------------------------------------

You can use chromImpute using ``chromImpute.sh <command>``, e.g., ``chromImpute.sh Convert``.
See the `ChromHMM website <https://ernstlab.biolchem.ucla.edu/ChromImpute/>`_ for the detail.

