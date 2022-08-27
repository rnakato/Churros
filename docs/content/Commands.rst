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


build-index.sh
-----------------------------------------------------

``build-index.sh`` builds index files of the tools specified. ``<odir>`` should be the same with ``<outputdir>`` directory 
provided in ``download_genomedata.sh``. If ``-a`` option is specified, all scaffolds are also indexed in addition to chromosomes. 
The ``<odir>`` is used in the **Churros** commands below.


.. code-block:: bash

    build-index.sh [-p ncore] -a <program> <odir>
        program: bowtie, bowtie-cs, bowtie2, bwa, chromap
        Example:
            build-index.sh bowtie2 Ensembl-GRCh38

churros
--------------------------------------------

``churros`` command internally implements ``churros_mapping``, ``churros_callpeak``, ``churros_visualize``, ``churros_compare`` and ``churros_genPvalwig``.

``churros`` also check the quality of FASTQ files using fastqc and fastp in addition to the quality check of map files by ``churros_mapping``. The result is summarized in the stats file in text format (``Churros_result/churros.QCstats.tsv``) and HTML format by MULTIQC (``multiqc_report.html``).

.. code-block:: bash

    churros [-h] [--cram] [-b BINSIZE] [--mpbl] [--nofastqc] [-q QVAL]
               [--macsdir MACSDIR] [-f FORMAT] [--mapparam MAPPARAM]
               [-p THREADS] [--outputpvalue] [-D OUTPUTDIR] [--preset PRESET]
               samplelist samplepairlist build Ddir

    positional arguments:
      samplelist            sample list
      samplepairlist        ChIP/Input pair list
      build                 genome build (e.g., hg38)
      Ddir                  directory of reference data
    
    optional arguments:
      -h, --help            show this help message and exit
      --cram                output as CRAM format (default: BAM)
      -b BINSIZE, --binsize BINSIZE
                            binsize of parse2wig+ (default: 100)
      --mpbl                consider genome mappability in drompa+
      --nofastqc            omit FASTQC
      -q QVAL, --qval QVAL  threshould of MACS2 (default: 0.05)
      --macsdir MACSDIR     output direcoty of macs2 (default: 'macs2')
      -f FORMAT, --format FORMAT
                            output format of parse2wig+ 0: compressed wig
                            (.wig.gz) 1: uncompressed wig (.wig) 2: bedGraph
                            (.bedGraph) 3 (default): bigWig (.bw)
      --mapparam MAPPARAM   parameter of bowtie|bowtie2 (shouled be quated)
      -p THREADS, --threads THREADS
                            number of CPUs (default: 12)
      --outputpvalue        output ChIP/Input -log(p) distribution as a begraph
                            format
      -D OUTPUTDIR, --outputdir OUTPUTDIR
                            output directory (default: 'Churros_result')
      --preset PRESET       Preset parameters for mapping reads ([scer])

- Key points:
   - We recommend considering genome mappability by supplying ``--mpbl`` option as long as mappability files are available. 

       - ``download_genomedata.sh`` generates mappability files for the read lengths 28, 36, and 50. Specify the read length closest to your data.
       - If the data is unavailable, consider generating the mappability files (see :doc:`Appendix`).
   - ``--outputpvalue`` option generates the bedGraph of -log10(p) by ``churros_genPvalwig``. By specifying ChIP files in two conditions (e.g., before and after stimulation) in ``samplepairlist``, you can generate and analyze the p-value distribution itself.
   - The appropriate parameter setting depends on the species to be investigated. ``churros`` has ``--preset`` option to tune the parameter set for each species. 

       - In version 0.2.0, there is ``--preset scer`` option only (for `S. cerevisiae`). When applying ``chuross`` to `S. serevisiae`, try ``--preset scer`` option.

churros_mapping
--------------------------------------------

``churros_mapping`` maps FASTQ reads to the genome specified by Bowtie2 in default.
The mapped reads are then quality-checked and converted to BigWig files.

``churros_mapping`` has 5 commands: ``exec``, ``map``, ``postprocess``, ``stats`` and ``header``.

- The main command is ``exec`` that maps reads and generates bigWig files (identical to both ``map`` and ``postprocess`` command execution). 
- ``map`` executes mapping. 
- ``postprocess`` generates bigWig files from the map files generated by ``map`` commands.
- ``stats`` command outputs the quality values in one line (used in ``churros.QCstats.tsv``). 
- Because ``stats`` command does not show the header of columns, use ``header`` command to show the header.

.. code-block:: bash

    churros_mapping [options] <command> <fastq> <prefix> <build> <Ddir>
       <command>:
          exec: map + postprocess
          map: mapping reads
          postprocess: QC and generate wig files by ssp and parse2wig;
          stats: show mapping/QC stats;
          header: print header line of the stats
       <fastq>: fastq file
       <prefix>: output prefix
       <build>: genome build (e.g., hg38)
       <Ddir>: directory of bowtie|bowtie2 index
       Options:
          -c: output as CRAM format (defalt: BAM)
          -b: binsize of parse2wig+ (defalt: 100)
          -z: peak file for FRiP calculation (BED format, default: default MACS2 without control)
          -m: consider genome mappability in parse2wig+
          -k [36|50]: read length of mappability file (default:50)
          -n: omit ssp
          -C: for SOLiD data (csfastq, defalt: fastq)
          -f: output format of parse2wig+ (default: 3)
                   0: compressed wig (.wig.gz)
                   1: uncompressed wig (.wig)
                   2: bedGraph (.bedGraph)
                   3: bigWig (.bw)
          -P "param": parameter of bowtie|bowtie2 (shouled be quated)
          -p : number of CPUs (default: 12)
          -D : directory for execution (defalt: "Churros_result")
       Example:
         For single-end: churros_mapping exec chip.fastq.gz chip hg38 Database/Ensembl-GRCh38
          For paired-end: churros_mapping exec "-1 chip_1.fastq.gz -2 chip_2.fastq.gz" chip hg38 Database/Ensembl-GRCh38

churros_callpeak
-------------------------------------

``churros_callpeak`` executes MACS2 to call peaks for all samples specified in ``samplepairlist``.
The results are output in ``macs`` directory by default. 
``churros_callpeak`` also compares the obtained peaks among samples and outputs the heatmap in ``comparison`` and ``simpson_peak_results`` directories.

.. code-block:: bash

   churros_callpeak [Options] <samplepairlist> <build>
      <samplepairlist>: text file of ChIP/Input sample pairs
      <build>: genome build (e.g., hg38)
      Options:
         -D : directory for execution (defalt: "Churros_result")
         -q : threshould of MACS2 (defalt: 0.05)
         -b : bam direcoty (defalt: "bam")
         -d : output direcoty (defalt: "macs")
         -F : overwrite MACS2 resilts if exist (defalt: skip)
         -p : number of CPUs (defalt: 4)

.. note::

   While the Jaccard index stored in ``comparison`` results evaluates the basepair-level overlap using ``bedtools jaccard`` command, the Simpson index stored in ``simpson_peak_results`` evaluates the peak-number-level overlap. If all samples are sharp peaks (e.g., transcription factors), the Simpson index may be reasonable. If the samples contain broad peaks (e.g., histone modification such as H3K27me3), the Jaccard index may provide more reasonable results because multiple sharp peaks can be overlapped with one broad peak.

churros_visualize
-------------------------------------

``churros_visualize`` executes DROMPA+ to make pdf files that visualize read/enrichment/p-value distributions.
The results are output in ``pdf`` directory by default.

.. note::

   If you supply ``-m`` option in ``churros_mapping`` (consider genome mappability), supply ``--mpbl`` optoon in ``churros_visualize`` to use the generated mappability-normalized bigWig files.

.. code-block:: bash

   churros_visualize [-h] [-f WIGFORMAT] [-b BINSIZE] [-l LINESIZE]
                         [--mpbl] [-d D] [--postfix POSTFIX] [--pvalue]
                         [-P DROMPAPARAM] [-G] [--enrich] [--logratio]
                         [--preset PRESET] [-D OUTPUTDIR]
                         samplepairlist prefix build Ddir
   
   positional arguments:
     samplepairlist        ChIP/Input pair list
     prefix                output prefix (directory will be omitted)
     build                 genome build (e.g., hg38)
     Ddir                  directory of reference data
   
   optional arguments:
     -h, --help            show this help message and exit
     -f WIGFORMAT, --wigformat WIGFORMAT
                           input file format 0: compressed wig (.wig.gz) 1:
                           uncompressed wig (.wig) 2: bedGraph (.bedGraph) 3
                           (default): bigWig (.bw)
     -b BINSIZE, --binsize BINSIZE
                           binsize of parse2wig+ (default: 100)
     -l LINESIZE, --linesize LINESIZE
                           line size for each page (kbp, defalt: 1000)
     --mpbl                consider genome mappability in drompa+
     -d D                  directory of parse2wig+ (default: parse2wigdir+)
     --postfix POSTFIX     param string of parse2wig+ files to be used (default:
                           '-bowtie2-<build>-raw-GR')
     --pvalue              show p-value distribution instead of read distribution
     -P DROMPAPARAM, --drompaparam DROMPAPARAM
                           additional parameters for DROMPA+ (shouled be quated)
     -G                    genome-wide view (100kbp)
     --enrich              PC_ENRICH: show ChIP/Input ratio (preferred for yeast)
     --logratio            (for PC_ENRICH) show log-scaled ChIP/Input ratio
     --preset PRESET       Preset parameters for mapping reads ([scer])
     -D OUTPUTDIR, --outputdir OUTPUTDIR
                           output directory (default: 'Churros_result')

- Key points:
   - The default setting (100-bp bin and 1-Mbp page width) is adjusted to typical transcription factor analysis for human/mouse.
   - For the broad mark analysis (e.g., H3K27me3 and H3K9me3, which are distributed more than 100 kbp), macro-scale visualization is useful. For example, ``-b 5000 -l 8000`` option generates 5-kbp bin, 8-Mbp page width. The scale of the y-axis can be changed by ``-P`` option, for example, ``-P "--scale_tag 100"``.
   - By ``-G`` option, ``churros_visualize`` visualizes ChIP/Input enrichment in genome-wide view (whole chromosome on one page).
   - It is also possible to visualize -log10(p) of ChIP/Input enrichment instead of read distribution, by supplying ``--pvalue`` option.
   - ``churros_visualize`` can highlight the peak regions called by MACS2 by supplying the ``macs/samplepairlist.txt`` generated by ``churros_callpeak`` for ``samplepairlist``.


churros_compare
-------------------------------------

``churros_compare`` executes ``deepTools plotCorrelation`` to calculate Spearman correlation coefficient using bigWig files (100-bp and 100-kbp bins) generated by ``churros_mapping`` and make heatmaps and scatter plots.

.. code-block:: bash

   churros_compare [Options] <samplelist> <build>
      <samplelist>: text file of samples
      <build>: genome build (e.g., hg38)
      Options:
         -d : output directory (defalt: "compare")
         -m: consider genome mappability in parse2wig+
         -D : directory for execution (defalt: "Churros_result")
         -y <str>: param string of parse2wig+ files to be used (default: "-bowtie2-<build>-raw-GR")

.. note::

   Unlike the peak comparison implemented in ``churros_callpeak``, ``churros_compare`` evaluates the similarity of whole genome including non-peak regions. Therefore the results may reflect the genome-wide features (e.g., GC bias and copy number variations) rather than peak overlap.

churros_genPvalwig
----------------------------------------

As ``churros_visualize`` can visualize -log10(p) of ChIP/Input enrichment distribution, ``churros_genPvalwig`` can be used the p-value distribution in bedGraph.

.. note::

   If you supply ``-m`` option in ``churros_mapping`` (consider genome mappability), supply ``-m`` option also here to use the generated mappability-normalized bigWig files.

.. code-block:: bash

   churros_genPvalwig [Options] <samplepairlist> <odir> <build> <gt>
      <samplepairlist>: text file of ChIP/Input sample pairs
      <odir>: output directory
      <build>: genome build (e.g., hg38)
      <gt>: genome_table file
      Options:
         -b <int>: binsize (defalt: 100)
         -d <str>: directory of parse2wig+ (default: parse2wigdir+)
         -m: consider genome mappability in parse2wig+
         -y <str>: postfix of .bw files to be used (default: "-bowtie2-<build>-raw-GR")
        -D : directory for execution (defalt: "Churros_result")
      Example:
         churros_genPvalwig samplelist.txt chip-seq hg38 Ensembl-GRCh38

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
See the `chromImpute website <https://ernstlab.biolchem.ucla.edu/ChromImpute/>`_ for the detail.

