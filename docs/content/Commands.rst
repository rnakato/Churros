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

``bowtie.sh`` is a script to use Bowtie. Because bowtie2 does not allow SOLiD colorspace data, use this script for it.

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


bowtie2.sh
------------------------------------------------

``bowtie2.sh`` is a script to use Bowtie2.

.. code-block:: bash

    bowtie2.sh [Options] <fastq> <prefix> <build> <Ddir>
       <fastq>: fastq file
       <prefix>: output prefix
       <build>: genome build (e.g., hg38)
       <Ddir>: directory of bowtie2 index
       Options:
          -c: output as CRAM format (defalt: BAM)
          -p: number of CPUs (default: 12)
          -P "bowtie2 param": parameter of bowtie2 (shouled be quated)
          -D: output dir (defalt: ./)
       Example:
          For single-end: bowtie2.sh -p "--very-sensitive" chip.fastq.gz chip hg38
          For paired-end: bowtie2.sh "\-1 chip_1.fastq.gz \-2 chip_2.fastq.gz" chip hg38

macs.sh
------------------------------------------------

``macs.sh`` is a script to use MACS2.

.. code-block:: bash

    macs.sh [Options] <IP bam> <Input bam> <prefix> <build> <mode>
       <IP bam>: BAM for for ChIP (treat) sample
       <Input bam>: BAM for for Input (control) sample: specify "none" if unavailable
       <prefix>: prefix of output file
       <build>: genome build (e.g., hg38)
       <mode>: peak mode ([sharp|broad|sharp-nomodel|broad-nomodel])
       Options:
          -f <int>: predefined fragment length (defalt: estimated in MACS2)
          -d <str>: output directory (defalt: "macs")
          -B: save extended fragment pileup, and local lambda tracks (two files) at every bp into a bedGraph file
          -F: overwrite files if exist (defalt: skip)


parse2wig+.sh
------------------------------------------------

``parse2wig+.sh`` executes parse2wig+ to generate wig|bedGraph|bigWig files from map files with the read normalization.
When ``-m`` option is supplied, ``parse2wig+.sh`` also normalizes the read based on the genome mappability (the read length can be specified using ``-k`` option). 

.. code-block:: bash

    parse2wig+.sh [options] <mapfile> <prefix> <build> <Ddir>
       <mapfile>: mapfile (SAM|BAM|CRAM|TAGALIGN format)
       <prefix>: output prefix
       <build>: genome build (e.g., hg38)
       <Ddir>: directory of bowtie2 index
       Options:
          -a: also outout raw read distribution
          -b: binsize of parse2wig+ (defalt: 100)
          -z: peak file for FRiP calculation (BED format)
          -l: predefined fragment length (default: estimated by trand-shift profile)
          -m: consider genome mappability
          -k: read length (36 or 50) for mappability calculation (default: 50)
          -p: for paired-end file
          -t: number of CPUs (default: 4)
          -o: output directory (default: parse2wigdir+)
          -f: output format of parse2wig+ (default: 3)
                   0: compressed wig (.wig.gz)
                   1: uncompressed wig (.wig)
                   2: bedGraph (.bedGraph)
                   3: bigWig (.bw)
          -D outputdir: output dir (defalt: ./)
          -F: overwrite files if exist (defalt: skip)
       Example:
          For single-end: parse2wig+.sh chip.sort.bam chip hg38 Ensembl-GRCh38
          For paired-end: parse2wig+.sh -p chip.sort.bam chip hg38 Ensembl-GRCh38

simpson_peak.sh
-------------------------------------

``simpson_peak.sh`` takes multiple peak lists (BED format) and output the correlation heatmap (.pdf) and scores (Simpson index).
The one-by-one comparison results (overlapped peak list and Venn diagram) are also generated.

.. note::

   If the number of peaks largely varies among samples, the results may become unfair. In such a case, use ``-n`` option to extract the same number of top-ranked peaks from the samples.

.. code-block:: bash

    simpson_peak.sh [Options] <peakfile> <peakfile> ...
       <peakfile>: peak file (bed format)
       Options:
          -n <int>: extract top-<int> peaks for comparison (default: all peaks)
          -d <str>: output directory (default: "simpson_peak_results/")
          -p <int>: number of CPUs (default: 4)

chromHMM.sh:
------------------------------------------------

You can use chromHMM using ``chromHMM.sh <command>``, e.g., ``chromHMM.sh LearnModel``.
See the `ChromHMM website <http://compbio.mit.edu/ChromHMM/>`_ for the detail.

chromImpute.sh:
------------------------------------------------

You can use chromImpute using ``chromImpute.sh <command>``, e.g., ``chromImpute.sh Convert``.
See the `ChromHMM website <https://ernstlab.biolchem.ucla.edu/ChromImpute/>`_ for the detail.

