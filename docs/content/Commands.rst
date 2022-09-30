Commands in Churros
============================

download_genomedata.sh
------------------------------------

``download_genomedata.sh`` downloads the genome and gene annotation files of the genome build specified.
**Churros** assumes the reference data is downloaded by this command.

.. code-block:: bash

   download_genomedata.sh <build> <outputdir>
      build (Ensembl|UCSC, you can specify either):
         human (GRCh38|hg38, GRCh37|hg19, T2T)
         mouse (GRCm39|mm39, GRCm38|mm10)
         rat (mRatBN7.2|rn7)
         fly (BDGP6|dm6)
         zebrafish (GRCz11|danRer11)
         chicken (GRCg6a|galGal6)
         African clawed frog (Xenopus_tropicalis|xenLae2)
         C. elegans (WBcel235|ce11)
         S. cerevisiae (R64-1-1|sacCer3)
         S. pombe (SPombe)
      Example:
         download_genomedata.sh hg38 Referencedata_hg38


build-index.sh
-----------------------------------------------------

``build-index.sh`` builds index files of the tools specified. ``<odir>`` should be the same with ``<outputdir>`` directory 
provided in ``download_genomedata.sh``. If ``-a`` option is specified, all scaffolds are also indexed in addition to chromosomes. 
The ``<odir>`` is used in the **Churros** commands below.


.. code-block:: bash

    build-index.sh [-p ncore] -a <program> <odir>
        program: bowtie, bowtie-cs, bowtie2, bwa, chromap
        Example:
            build-index.sh bowtie2 Referencedata_hg38

churros
--------------------------------------------

``churros`` command internally implements ``churros_mapping``, ``churros_callpeak``, ``churros_visualize``, ``churros_compare`` and ``churros_genPvalwig``.

``churros`` also check the quality of FASTQ files using fastqc and fastp in addition to the quality check of map files by ``churros_mapping``. The result is summarized in the stats file in text format (``churros.QCstats.tsv``) and HTML format by MULTIQC (``multiqc_report.html``) in the output directory.

.. code-block:: bash

   usage: churros [-h] [--cram] [-f] [-b BINSIZE] [--nompbl] [--nofastqc] [-q QVAL] [--macsdir MACSDIR] [--mapparam MAPPARAM] [-p THREADS]
               [--threads_comparative THREADS_COMPARATIVE] [--outputpvalue] [--comparative] [-D OUTPUTDIR] [--preset PRESET] [-v]
               samplelist samplepairlist build Ddir

   positional arguments:
     samplelist            sample list
     samplepairlist        ChIP/Input pair list
     build                 genome build (e.g., hg38)
     Ddir                  directory of reference data

   optional arguments:
     -h, --help            show this help message and exit
     --cram                output as CRAM format (default: BAM)
     -f, --force           overwrite if the output directory already exists
     -b BINSIZE, --binsize BINSIZE
                           binsize of parse2wig+ (default: 100)
     -k K                  read length for mappability file ([28|36|50], default:50)
     --nompbl              do not consider genome mappability in drompa+
     --nofastqc            omit FASTQC
     -q QVAL, --qval QVAL  threshould of MACS2 (default: 0.05)
     --macsdir MACSDIR     output direcoty of macs2 (default: 'macs2')
     --mapparam MAPPARAM   parameter of bowtie|bowtie2 (shouled be quated)
     -p THREADS, --threads THREADS
                           number of CPUs (default: 12)
     --threads_comparative THREADS_COMPARATIVE
                           number of CPUs for --comparative option (default: 8)
     --outputpvalue        output ChIP/Input -log(p) distribution as a begraph format
     --comparative         compare bigWigs and peaks among samples by churros_compare
     -D OUTPUTDIR, --outputdir OUTPUTDIR
                           output directory (default: 'Churros_result')
     --preset PRESET       Preset parameters for mapping reads ([scer|T2T])
     -v, --version         print version information and quit

- Key points:
   - We recommend considering genome mappability as long as mappability files are available. 

      - ``download_genomedata.sh`` generates mappability files for the read lengths 28, 36, and 50. Specify the read length closest to your data by ``-k`` option.
      - If the mappability file is unavailable, consider generating it by yourself (see :doc:`Appendix`).
   - The appropriate parameter setting depends on the species to be investigated. ``churros`` has ``--preset`` option to tune the parameter set for each species. 

      - In version ``0.4.0``, ``scer`` (for `S. cerevisiae`) and ``T2T`` (for `T2T-CHM13`) are available. When applying ``chuross`` to `S. cerevisiae`, try ``--preset scer`` option.


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
          -k [28|36|50]: read length for mappability file (default:50)
          -n: do not consider genome mappability
          -C: for SOLiD data (csfastq, defalt: fastq)
          -f: output format of parse2wig+ (default: 3)
                   0: compressed wig (.wig.gz)
                   1: uncompressed wig (.wig)
                   2: bedGraph (.bedGraph)
                   3: bigWig (.bw)
          -P "param": parameter of bowtie|bowtie2 (shouled be quated)
          -p: number of CPUs (default: 12)
          -D: directory for execution (defalt: "Churros_result")
       Example:
          For single-end: churros_mapping exec chip.fastq.gz chip hg38 Referencedata_hg38
          For paired-end: churros_mapping exec "-1 chip_1.fastq.gz -2 chip_2.fastq.gz" chip hg38 Referencedata_hg38

- Key points:
   - There are two directories in ``bigWig`` directory, ``RawCount`` and ``TotalReadNormalized``. The former is a raw count of nonredundant mapped reads, while the latter stores the read number after total read normalization to 20 M. 
   - **Churros** uses ``TotalReadNormalized`` in the downstream analysis, while MACS2 (peak calling) uses the former.

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


churros_visualize
-------------------------------------

``churros_visualize`` executes DROMPA+ to make pdf files that visualize read/enrichment/p-value distributions.
The results are output in ``pdf`` directory by default.

.. code-block:: bash

   usage: churros_visualize [-h] [-b BINSIZE] [-l LINESIZE] [--nompbl] [-d D] [--postfix POSTFIX] [--pvalue] [--bowtie1] [-P DROMPAPARAM] [-G] [--enrich]
                         [--logratio] [--preset PRESET] [-D OUTPUTDIR]
                         samplepairlist prefix build Ddir

   positional arguments:
     samplepairlist        ChIP/Input pair list
     prefix                output prefix (directory will be omitted)
     build                 genome build (e.g., hg38)
     Ddir                  directory of reference data

   optional arguments:
     -h, --help            show this help message and exit
     -b BINSIZE, --binsize BINSIZE
                           binsize of parse2wig+ (default: 100)
     -l LINESIZE, --linesize LINESIZE
                           line size for each page (kbp, defalt: 1000)
     --nompbl              do not consider genome mappability
     -d D                  directory of bigWig files (default: 'TotalReadNormalized/')
     --postfix POSTFIX     param string of parse2wig+ files to be used (default: '.mpbl')
     --pvalue              show p-value distribution instead of read distribution
     --bowtie1             specified bowtie1
     -P DROMPAPARAM, --drompaparam DROMPAPARAM
                           additional parameters for DROMPA+ (shouled be quated)
     -G                    genome-wide view (100kbp)
     --enrich              PC_ENRICH: show ChIP/Input ratio (preferred for yeast)
     --logratio            (for PC_ENRICH) show log-scaled ChIP/Input ratio
     --preset PRESET       Preset parameters for mapping reads ([scer|T2T])
     -D OUTPUTDIR, --outputdir OUTPUTDIR
                           output directory (default: 'Churros_result')


.. note::

   If you supply ``-n`` option in ``churros_mapping`` (do not consider genome mappability), supply ``--nompbl`` optoon in ``churros_visualize`` to use the generated mappability-normalized bigWig files.

- Key points:
   - The default setting (100-bp bin and 1-Mbp page width) is adjusted to typical transcription factor analysis for human/mouse.
   - For the broad mark analysis (e.g., H3K27me3 and H3K9me3, which are distributed more than 100 kbp), macro-scale visualization is useful. For example, ``-b 5000 -l 8000`` option generates 5-kbp bin, 8-Mbp page width. The scale of the y-axis can be changed by ``-P`` option, for example, ``-P "--scale_tag 100"``.
   - By ``-G`` option, ``churros_visualize`` visualizes ChIP/Input enrichment in genome-wide view (whole chromosome on one page).
   - It is also possible to visualize -log10(p) of ChIP/Input enrichment instead of read distribution, by supplying ``--pvalue`` option.
   - ``churros_visualize`` can highlight the peak regions called by MACS2 by supplying the ``macs/samplepairlist.txt`` generated by ``churros_callpeak`` for ``samplepairlist`` (see :doc:`Tutorial`).


churros_compare
-------------------------------------

``churros_compare`` estimates the correlation among samples described in ``<samplepairlist>`` and draw heatmaps and scatter plots using three types of comparative analysis:

- Spearman correlation of read distribution by applying bigWig files (100-bp and 100-kbp bins) to `deepTools plotCorrelation <https://deeptools.readthedocs.io/en/develop/content/tools/plotCorrelation.html>`_. 

   - This score evaluates the similarity of the whole genome including non-peak regions. Therefore the results may reflect the genome-wide features (e.g., GC bias and copy number variations) rather than peak overlap.
   - The results are stored in ``bigwigCorrelation/``.
- Jaccard index of base-pair level overlap of peaks by `BEDtools jaccard <https://bedtools.readthedocs.io/en/latest/content/tools/jaccard.html>`_.

   - This score is good for broad peaks such as some histone modifications (H3K27me3 and H3K36me3).
   - The results are stored in ``Peak_BPlevel_overlap/``.
- Simpson index of peak-number level comparison.

   - This score is good for the comparison of sharp peaks such as transcription factors.
   - The results are stored in ``Peak_Number_overlap/``. ``PairwiseComparison/`` contains the results of all pairs (overlapped peak list and Venn diagram) and the ``Peaks`` contains top-ranked peaks of samples.

.. code-block:: bash

   churros_compare [Options] <samplelist> <samplepairlist> <build>
      <samplelist>: text file of samples
      <build>: genome build (e.g., hg38)
      Options:
         -o: output directory (defalt: "comparison")
         -d: peak direcoty (defalt: "macs")
         -n: do not consider genome mappability
         -D: directory for execution (defalt: "Churros_result")
         -p : number of CPUs (default: 8)
         -y <str>: param string of parse2wig+ files to be used (default: ".mpbl")

.. note::

   If all samples are sharp peaks (e.g., transcription factors), the Simpson index may be reasonable. If the samples contain broad peaks (e.g., histone modification such as H3K27me3), the Jaccard index may provide more reasonable results because multiple sharp peaks can be overlapped with one broad peak.

.. note::

   If the number of samples is large (50~) and/or the number of peaks of each sample is large (100k~), the comparison will require a long time. In such a case, consider supplying a large number for ``-p``, though that will require a large memory size.

churros_genPvalwig
----------------------------------------

As ``churros_visualize`` can visualize -log10(p) of ChIP/Input enrichment distribution, ``churros_genPvalwig`` can be used the p-value distribution in bedGraph.

The good usage of ``churros_genPvalwig`` is specifying ChIP files in two conditions (e.g., before and after stimulation) in ``samplepairlist`` and analyzing the p-value distribution to investigate significantly increased/descreased regions.

.. code-block:: bash

   churros_genPvalwig [Options] <samplepairlist> <odir> <build> <gt>
      <samplepairlist>: text file of ChIP/Input sample pairs
      <odir>: output directory
      <build>: genome build (e.g., hg38)
      <gt>: genome_table file
      Options:
         -b <int>: binsize (defalt: 100)
         -d <str>: directory of bigWig files (default: 'TotalReadNormalized/'')
         -n: do not consider genome mappability
         -y <str>: postfix of .bw files to be used (default: '.mpbl')
         -D <str>: directory for execution (defalt: "Churros_result")
      Example:
         churros_genPvalwig samplelist.txt chip-seq hg38 genometable.hg38.txt

.. note::

   If you supply ``-n`` option in ``churros_mapping`` (do not consider genome mappability), supply ``--nompbl`` optoon in ``churros_visualize`` to use the generated mappability-normalized bigWig files.

  
bowtie.sh
------------------------------------------------

``bowtie.sh`` is a script to use Bowtie. Because bowtie2 does not allow SOLiD colorspace data, use this script for it.

.. code-block:: bash

    bowtie.sh [Options] <fastq> <prefix> <Ddir>
       <fastq>: fastq file
       <prefix>: output prefix
       <Ddir>: directory of bowtie index
       Options:
          -t STR: for SOLiD data ([fastq|csfata|csfastq], defalt: fastq)
          -c: output as CRAM format (defalt: BAM)
          -p INT: number of CPUs (default: 12)
          -P "STR": parameter of bowtie (shouled be quated, default: "-n2 -m1")
          -D: output dir (defalt: ./)
       Example:
          For single-end: bowtie.sh -P "-n2 -m1" chip.fastq.gz chip Referencedata_hg38
          For paired-end: bowtie.sh "\-1 chip_1.fastq.gz \-2 chip_2.fastq.gz" chip Referencedata_hg38
          For SOLiD data: bowtie.sh -t csfastq -P "-n2 -m1" chip.csfastq.gz chip Referencedata_hg38


bowtie2.sh
------------------------------------------------

``bowtie2.sh`` is a script to use Bowtie2.

.. code-block:: bash

    bowtie2.sh [Options] <fastq> <prefix> <Ddir>
       <fastq>: fastq file
       <prefix>: output prefix
       <Ddir>: directory of bowtie2 index
       Options:
          -c: output as CRAM format (defalt: BAM)
          -p: number of CPUs (default: 12)
          -P "bowtie2 param": parameter of bowtie2 (shouled be quated)
          -D: output dir (defalt: ./)
       Example:
          For single-end: bowtie2.sh -p "--very-sensitive" chip.fastq.gz chip Referencedata_hg38
          For paired-end: bowtie2.sh "\-1 chip_1.fastq.gz \-2 chip_2.fastq.gz" chip Referencedata_hg38

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
         -k: read length for mappability calculation ([28|36|50], default: 50)
         -p: for paired-end file
         -t: number of CPUs (default: 4)
         -o: output directory (default: parse2wigdir+)
         -s: stats directory (default: log/parse2wig+)
         -f: output format of parse2wig+ (default: 3)
               0: compressed wig (.wig.gz)
               1: uncompressed wig (.wig)
               2: bedGraph (.bedGraph)
               3: bigWig (.bw)
         -D outputdir: output dir (defalt: ./)
         -F: overwrite files if exist (defalt: skip)
      Example:
         For single-end: parse2wig+.sh chip.sort.bam chip hg38 Referencedata_hg38
         For paired-end: parse2wig+.sh -p chip.sort.bam chip hg38 Referencedata_hg38

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
         -v: Draw Venn diagrams for all pairs
         -p <int>: number of CPUs (default: 8)


rose: Super-enhancer analysis
------------------------------------

``rose`` executes `ROSE <http://younglab.wi.mit.edu/super_enhancer_code.html>`_ to identify super-enhancer sites from a BED file.

Input bam file is optional.

.. code-block:: bash

   rose [Options] <IPbam> <Inputbam> <bed> <build>
      <IPbam>: BAM file for ChIP sample
      <Inputbam>: BAM file for Input sample (specify "none" when input is absent)
      <bed>: enhancer regions (BED format)
      <build>: genome build (hg18|hg19|hg38|mm8|mm9|mm10)
      Options:
         -d : maximum distance between two regions that will be stitched together (default: 12500)
         -e : exclude regions contained within +/- this distance from TSS in order to account for promoter biases (default: 0, recommended if used: 2500)

chromHMM.sh
------------------------------------------------

You can use chromHMM using ``chromHMM.sh <command>``, e.g., ``chromHMM.sh LearnModel``.
See the `ChromHMM website <http://compbio.mit.edu/ChromHMM/>`_ for the detail.

chromImpute.sh
------------------------------------------------

You can use chromImpute using ``chromImpute.sh <command>``, e.g., ``chromImpute.sh Convert``.
See the `chromImpute website <https://ernstlab.biolchem.ucla.edu/ChromImpute/>`_ for the detail.

