Commands in Churros
============================

.. contents:: 
   :depth: 3

Reference Data Preparation
++++++++++++++++++++++++++++++++++++++++++

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
         Hydra vulgaris AEP (HVAEP)
      Example:
         download_genomedata.sh hg38 Referencedata_hg38


build-index.sh
-----------------------------------------------------

``build-index.sh`` builds index files of the tools specified. ``<odir>`` should be the same with ``<outputdir>`` directory 
provided in ``download_genomedata.sh``. If ``-a`` option is specified, all scaffolds are also indexed in addition to chromosomes. 
The ``<odir>`` is used in the **Churros** commands below.


.. code-block:: bash

    build-index.sh [-p ncore] -a <program> <odir>
        program: bowtie, bowtie-cs, bowtie2, bwa, chromap, bismark
        Example:
            build-index.sh bowtie2 Referencedata_hg38


Commands internally used in churros
++++++++++++++++++++++++++++++++++++++++++

churros
--------------------------------------------

``churros`` command internally implements ``churros_mapping``, ``churros_callpeak``, ``churros_visualize``, ``churros_compare`` and ``churros_genPvalwig``.

``churros`` also check the quality of FASTQ files using fastqc and fastp in addition to the quality check of map files by ``churros_mapping``. The result is summarized in the stats file in text format (``churros.QCstats.tsv``) and HTML format by MULTIQC (``multiqc_report.html``) in the output directory.

.. code-block:: bash

   usage: churros [-h] [--cram] [-f] [-b BINSIZE] [-k K] [--nompbl] [--nofilter] [--noqc] [--fastqtrimming] [-q QVAL] [--macsdir MACSDIR]
                  [--mapparam MAPPARAM] [--parse2wigparam PARSE2WIGPARAM] [-p THREADS] [--threads_comparative THREADS_COMPARATIVE]
                  [--outputpvalue] [--comparative] [-D OUTPUTDIR] [--preset PRESET] [-v]
                  samplelist samplepairlist build Ddir

   positional arguments:
      samplelist            sample list
      samplepairlist        ChIP/Input pair list
      build                 genome build (e.g., hg38)
      Ddir                  directory of reference data

   options:
      -h, --help            show this help message and exit
      --cram                output as CRAM format (default: BAM)
      -f, --force           overwrite if the output directory already exists
      -b BINSIZE, --binsize BINSIZE
                              binsize of parse2wig+ (default: 100)
      -k K                  read length for mappability file ([28|36|50], default:50)
      --nompbl              do not consider genome mappability in drompa+
      --nofilter            do not filter PCR duplicate
      --noqc                omit FASTQC and fastp
      --fastqtrimming       Apply adapter trimming with fastp before mapping (omitted if '--noqc' is specified)
      -q QVAL, --qval QVAL  threshould of MACS2 (default: 0.05)
      --macsdir MACSDIR     output direcoty of macs2 (default: 'macs2')
      --mapparam MAPPARAM   additional parameter for bowtie|bowtie2 (shouled be quated)
      --parse2wigparam PARSE2WIGPARAM
                              additional parameter for parse2wig+ (shouled be quated)
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


churros (spike-in mode)
--------------------------------------------

From version ``v1.0.0``, ``churros`` has an option to apply spike-in normalization. The command is as follows:

.. code-block:: bash

   build=hg38
   build_spikein=mm39
   Ddir_ref=Referencedata_$build
   Ddir_spikein=Referencedata_$build_spikein
   ncore=48

   churros -p $ncore --spikein samplelist.txt samplepairlist.txt \
         $build $Ddir_ref --build_spikein $build_spikein --Ddir_spikein $Ddir_spikein

The required options are ``--spikein``, ``build_spikein`` and ``--Ddir_spikein``. This command uses hg38 for the reference genome and mm39 for the spike-in genome.

Churros will then create the ``bigWig/Spikein/``, ``pdf_spikein/``, and ``spikein_scalingfactor`` directories, which contain the results of the spike-in analysis.

See also: `churros-mapping-spikein <https://churros.readthedocs.io/en/latest/content/Commands.html#id1>`_

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

   churros_mapping [options] <command> <samplelist> <build> <Ddir>
      <command>:
         exec: map & postprocess
         map: mapping reads
         postprocess: QC and generate wig files by ssp and parse2wig;
         stats: show mapping/QC stats;
         header: print header line of the stats
      <samplelist>: Samplelist file
      <build>: Genome build (e.g., hg38)
      <Ddir>: Directory of bowtie|bowtie2 index
      Options:
         -c: Output as CRAM format (defalt: BAM)
         -b: Binsize of parse2wig+ (defalt: 100)
         -z: Peak file for FRiP calculation (BED format, default: default MACS2 without control)
         -k [28|36|50]: Read length for mappability file (default:50)
         -n: Do not consider genome mappability
         -N: Do not filter PCR duplication
         -C: For SOLiD data (csfastq, defalt: fastq)
         -f: Output format of parse2wig+ (default: 3)
                  0: compressed wig (.wig.gz)
                  1: uncompressed wig (.wig)
                  2: bedGraph (.bedGraph)
                  3: bigWig (.bw)
         -P "param": Additional parameter for bowtie|bowtie2 (shouled be quated)
         -Q "param": Additional parameter for parse2wig+ (shouled be quated)
         -p: Number of CPUs (default: 12)
         -D: directory for execution (defalt: "Churros_result")
      Example:
         For single-end: churros_mapping exec chip.fastq.gz chip hg38 Referencedata_hg38
         For paired-end: churros_mapping exec "-1 chip_1.fastq.gz -2 chip_2.fastq.gz" chip hg38 Referencedata_hg38

- Key points:
   - There are two directories in ``bigWig`` directory, ``RawCount`` and ``TotalReadNormalized``. The former is a raw count of nonredundant mapped reads, while the latter stores the read number after total read normalization to 20 M. 
   - **Churros** uses ``TotalReadNormalized`` in the downstream analysis, while MACS2 (peak calling) uses the former.


churros_mapping_spikein
--------------------------------------------

``churros_mapping_spikein`` is similar to ``churros_mapping`` and applies spike-in normalization.

``churros_mapping_spikein`` has 3 commands: ``exec``, ``stats`` and ``header``.

By default, ``churros_mapping_spikein`` uses the Calibrating ChIP-seq normalization proposed by `Hu et al., NAR 2015 <https://academic.oup.com/nar/article/43/20/e132/1398246>`_, which requires the input sample obtained from WCE. If this is not available, use the ``--spikein_simple`` option, which applies a simpler normalization using only the ChIP samples proposed by `Orlando et al., Cell Rep, 2014 <https://www.cell.com/cell-reports/fulltext/S2211-1247(14)00872-9>`_. 

This is an example command. The reference genome is human and the spike-in genome is mouse.

.. code-block:: bash

   build=hg38
   build_spikein=mm39
   Ddir_ref=Referencedata_$build
   Ddir_spikein=Referencedata_$build_spikein
   ncore=48

   churros_mapping_spikein exec samplelist.txt samplepairlist.txt $build $build_spikein \
         $Ddir_ref $Ddir_spikein -p $ncore

.. code-block:: bash

   usage: churros_mapping_spikein [-h] [--spikein_simple] [--spikein_constant SPIKEIN_CONSTANT] [--cram] [-p THREADS] [-D OUTPUTDIR]
                               [--bowtieparam BOWTIEPARAM] [-b BINSIZE] [--peak PEAK] [--param_parse2wig PARAM_PARSE2WIG]
                               [--output_format OUTPUT_FORMAT] [--nompbl] [--nofilter] [-k KMER]
                               command samplelist samplepairlist build build_spikein Ddir_ref Ddir_spikein

   positional arguments:
   command               [exec|stats|header]
                              exec: mapping and postprocess
                              stats: show mapping/QC stats
                              header: print header line of the stats
   samplelist            Sample list
   samplepairlist        ChIP/Input pair list
   build                 genome build (e.g., hg38)
   build_spikein         genome build (e.g., mm39)
   Ddir_ref              Directory of genome index for reference
   Ddir_spikein          Directory of genome index for spike-in

   options:
   -h, --help            show this help message and exit
   --spikein_simple      Spikein: Use ChIP samples only
   --spikein_constant SPIKEIN_CONSTANT
                           Scaling Constant for the number of reads after normalization (default: 100)
   --cram                Output as CRAM format (defalt: BAM)
   -p THREADS, --threads THREADS
                           Number of CPUs (default: 12)
   -D OUTPUTDIR, --outputdir OUTPUTDIR
                           Output directory (default: 'Churros_result')
   --bowtieparam BOWTIEPARAM
                           Additional parameter for bowtie|bowtie2 (shouled be quated)
   -b BINSIZE, --binsize BINSIZE
                           Binsize of parse2wig+ (default: 100)
   --peak PEAK           Peak file for FRiP calculation (BED format, default: MACS2 without control)
   --param_parse2wig PARAM_PARSE2WIG
                           Additional parameter for parse2wig+ (shouled be quated)
   --output_format OUTPUT_FORMAT
                           Output format of parse2wig+ (default: 3)
                              0: compressed wig (.wig.gz)
                              1: uncompressed wig (.wig)
                              2: bedGraph (.bedGraph)
                              3: bigWig (.bw)
   --nompbl              Do not consider genome mappability
   --nofilter            Use data where PCR duplication is not filtered
   -k KMER, --kmer KMER  Read length for mappability file ([28|36|50], default:50)


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
         -d : directory for peaks (defalt: "macs")
         -q : threshould of MACS2 (defalt: 0.05)
         -b : bam direcoty (defalt: "bam")
         -F : overwrite MACS2 resilts if exist (defalt: skip)
         -p : number of CPUs (defalt: 4)
         -s : postfix of the mapfile ($prefix$post.sort.bam, default: "")


churros_visualize
-------------------------------------

``churros_visualize`` executes DROMPA+ to make pdf files that visualize read/enrichment/p-value distributions.
The results are output in ``pdf`` directory by default.

.. code-block:: bash

   usage: churros_visualize [-h] [-b BINSIZE] [-l LINESIZE] [--nompbl] [--nofilter] [-d D] [--postfix POSTFIX] [--pvalue] [--bowtie1]
                           [-P DROMPAPARAM] [-G] [--enrich] [--logratio] [--preset PRESET] [-D OUTPUTDIR]
                           samplepairlist prefix build Ddir

   positional arguments:
   samplepairlist        ChIP/Input pair list
   prefix                Output prefix (directory will be omitted)
   build                 Genome build (e.g., hg38)
   Ddir                  Directory of reference data

   options:
   -h, --help            show this help message and exit
   -b BINSIZE, --binsize BINSIZE
                           Binsize of parse2wig+ (default: 100)
   -l LINESIZE, --linesize LINESIZE
                           Line size for each page (kbp, defalt: 1000)
   --nompbl              Do not consider genome mappability
   --nofilter            Use data where PCR duplication is not filtered
   -d D                  Directory of bigWig files (default: 'TotalReadNormalized/')
   --postfix POSTFIX     Parameter string of parse2wig+ files to be used (default: '.mpbl')
   --pvalue              Show p-value distribution instead of read distribution
   --bowtie1             Specified bowtie1
   -P DROMPAPARAM, --drompaparam DROMPAPARAM
                           Additional parameters for DROMPA+ (shouled be quated)
   -G                    Genome-wide view (100kbp)
   --enrich              PC_ENRICH: show ChIP/Input ratio (preferred for yeast)
   --logratio            (for PC_ENRICH) Show log-scaled ChIP/Input ratio
   --preset PRESET       Preset parameters for mapping reads ([scer|T2T])
   -D OUTPUTDIR, --outputdir OUTPUTDIR
                           Output directory (default: 'Churros_result')

.. note::

   If you supply ``-n`` option in ``churros_mapping`` (do not consider genome mappability), supply ``--nompbl`` option in ``churros_visualize`` to use the generated mappability-normalized bigWig files.

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
         -d <str>: directory of bigWig files (default: TotalReadNormalized/)
         -e <int>: Output value
            0: ChIP/Input enrichment
            1: -log10(P) (ChIP internal)
            2 (default): -log10(P) (ChIP/Input enrichment)
         -n: do not filter PCR duplicate
         -m: do not consider genome mappability
         -y <str>: postfix of .bw files to be used (default: "-raw-GR")
         -D <str>: directory for execution (defalt: "Churros_result")
         -x: Output as bigWig (defalt: bedGraph)
      Example:
         churros_genPvalwig samplelist.txt chip-seq hg38 genometable.hg38.txt


churros_classheat
-------------------------------------------------------

**Churros** provides a ``classheat`` function for clustering and visualizing large-scale epigenomic profiles.
This function takes regions of interest (e.g., specific protein binding sites) as input 1 and a folder of epigenomic signal files (either binary or continuous) as input 2.

    - In the binary mode, ``classheat`` outputs a binary matrix (output 1) representing the overlap of epigenomic markers at given genomic regions. The binary matrix is then formatted and sorted by the user-defined column (i.e., the filename of the selected marker) to generate the processed matrix (output 2) and plot the sorted heatmap (output 3). Subsequently, ``classheat`` utilizes PCA followed by k-means clustering  (or other clustering methods) to produce the clustered matrix (output 4) and the clustered heatmap (output 5).
    - In the continuous mode, ``classheat`` calculates the averaged read density of each epigenomic marker at given genomic regions (output 1). After logarithmic transformation, z-score normalization (optional method is 0-to-1 scaling), and sorting, ``classheat`` generates the remaining outputs in the same manner as in binary mode.

.. code-block:: bash

   churros_classheat mode region directory [-k kcluster] [-s sortname] [-l samplelabel] [-n normalize type] [-m cluster method]

Example usage of binary mode:

.. code-block:: bash

   churros_classheat -l samplelabel.tsv binary Rad21_ENCSR000BTQ_rep1_peaks.narrowPeak ./peakdir/

This command takes as input a file representing regions of interest (``Rad21_ENCSR000BTQ_rep1_peaks.narrowPeak``) and a directory  (``./peakdir/``) containing multiple epigenomic signals.
We also assigned labels to the files in the ``./peakdir/`` directory.
Five output files are generated:

.. code-block:: bash

   Output1_raw_matrix.tsv
   Output2_sorted_matrix.tsv
   Output3_sorted_heatmap.png
   Output4_kmeans_matrix.tsv
   Output5_kmeans_heatmap.png

Example usage of continuous mode:

.. code-block:: bash

   churros_classheat -l samplelabel.tsv -s GATA3_ENCSR000EWV_rep1.bw -k 3 -n zscore continuous Rad21_ENCSR000BTQ_rep1_peaks.narrowPeak ./bwdir/



Commands internally used in churros_mapping
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  
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
         -n: do not filter PCR duplication
         -o: output directory (default: parse2wigdir+)
         -s: stats directory (default: log/parse2wig+)
         -f: output format of parse2wig+ (default: 3)
                  0: compressed wig (.wig.gz)
                  1: uncompressed wig (.wig)
                  2: bedGraph (.bedGraph)
                  3: bigWig (.bw)
         -D outputdir: output dir (defalt: ./)
         -F: overwrite files if exist (defalt: skip)
         -P: other options (should be quoted, see the help of parse2wig+ for the detail)
      Example:
         For single-end: parse2wig+.sh chip.sort.bam chip hg38 Referencedata_hg38
         For paired-end: parse2wig+.sh -p chip.sort.bam chip hg38 Referencedata_hg38


Commands internally used in churros_callpeak
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

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


Commands internally used in churros_compare
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

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


Tools for Advanced Usage
+++++++++++++++++++++++++++++++++++++++++++++++++

FRiR: Repeat Analysis
---------------------------------

Similar to the FRiP (fraction of reads in peaks) score of `Landt et al. (2012) <https://genome.cshlp.org/content/22/9/1813.abstract>`_,
which calculates the fraction of mapped reads that fall within ChIP-seq peak regions,
**Churros** calculates the FRiR (fraction of reads in repeats) score as the fraction of mapped reads that fall within repeat regions annotated by `RemeatMasker <https://www.repeatmasker.org/>`_.


.. code-block:: bash

   Usage: FRiR [option] -r <repeatfile> -i <inputfile> -o <output> --gt <genome_table>

   Example:
      FRiR -r Referencedata_hg38/RepeatMasker.txt.gz -o FRiRresult --gt Referencedata_hg38/genometable.txt -i Churros_result/hg38/bam/Sample.sort.bam --repeattype class

<repeatfile> is the RepeatMasker file downloaded with `download_genomefa.sh`. FRiR can allow a gzipped repeat file. The `--repeattype` option specifies the type of repeat classification of the output. The default is "class" (e.g., SINE, LINE, LTR, DNA, and others). The output is a text file with the FRiR score for each repeat type.

.. note::

   Selecting ``--repeattype name`` results in a long computation time due to an extremely large number of classes.


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


Tools for DNA methylation analysis
+++++++++++++++++++++++++++++++++++++++++++++++++

Bismark.sh: Bisulfite sequencing analysis
--------------------------------------------------

**Bismark.sh** executes `Bismark <https://www.bioinformatics.babraham.ac.uk/projects/bismark/>`_ to handle Bisulfite sequencing data.

**Bismark.sh** command executes all steps of Bismark as follows:

    - ``bismark (mapping)``
    - ``deduplicate_bismark``
    - ``bismark_methylation_extractor``
    - ``bismark2report``
    - ``bismark2summary``

.. code-block:: bash

   Bismark.sh [Options] <index> <fastq>
      <index>: Bismark index directory
      <fastq>: Input fastq file
      Options:
         -d <str>: output directory (defalt: "Bismarkdir")
         -m <mode>: Bismark mode ([directional|non_directional|pbat|rrbs], default: directional)
         -p : number of CPUs (default: 4)

The results are output in ``Bismarkdir/``. If you want to specify the name of output directory, use ``-d`` option.

Utility tools
+++++++++++++++++++++++++++++++++++++++++++++++++

gen_samplelist.sh: create samplelist.txt
--------------------------------------------------

   SRR227447.fastq.gz  SRR227552.fastq.gz  SRR227563.fastq.gz  SRR227575.fastq.gz  SRR227598.fastq.gz  SRR227639.fastq.gz
   SRR227448.fastq.gz  SRR227553.fastq.gz  SRR227564.fastq.gz  SRR227576.fastq.gz  SRR227599.fastq.gz  SRR227640.fastq.gz
   $ gen_samplelist.sh fastq > samplelist.txt
   $ cat samplelist.txt
   SRR227447      fastq/SRR227447.fastq.gz
   SRR227448      fastq/SRR227448.fastq.gz
   SRR227552      fastq/SRR227552.fastq.gz
   SRR227553      fastq/SRR227553.fastq.gz
   SRR227563      fastq/SRR227563.fastq.gz
   SRR227564      fastq/SRR227564.fastq.gz
   SRR227575      fastq/SRR227575.fastq.gz
   SRR227576      fastq/SRR227576.fastq.gz
   SRR227598      fastq/SRR227598.fastq.gz
   SRR227599      fastq/SRR227599.fastq.gz
   SRR227639      fastq/SRR227639.fastq.gz
   SRR227640      fastq/SRR227640.fastq.gz

Supply ``-p`` option when using paired-end fastqs.

.. code-block:: bash

   $ gen_samplelist.sh -p fastq > samplelist.txt

By default, ``gen_samplelist.sh`` assumes that the postfix of paired fastq files is "_1" and "_2". If it is "_R1" and "_R2", specify ``-r`` option.

.. code-block:: bash

   $ gen_samplelist.sh -p -r fastq > samplelist.txt


generate_samplelist_from_SRA
--------------------------------------------------

``generate_samplelist_from_SRA`` is a script that get the labels of each SRA ids from ``SraExperimentPackage.xml`` and ``SraRunTable.txt`` to make the sample list.

.. code-block:: bash

   generate_samplelist_from_SRA SraExperimentPackage.xml SraRunTable.txt samplelist.txt

gen_samplepairlist.sh: create samplepairlist.txt
--------------------------------------------------

``gen_samplepairlist.sh`` takes ``samplelist.txt`` as input and "roughly" outputs ``samplepairlist.txt``.

.. code-block:: bash

   $ cat samplelist.txt
   HepG2_H2A.Z     fastq/SRR227639.fastq.gz,fastq/SRR227640.fastq.gz
   HepG2_H3K4me3   fastq/SRR227563.fastq.gz,fastq/SRR227564.fastq.gz
   HepG2_H3K27ac   fastq/SRR227575.fastq.gz,fastq/SRR227576.fastq.gz
   HepG2_H3K27me3  fastq/SRR227598.fastq.gz,fastq/SRR227599.fastq.gz
   HepG2_H3K36me3  fastq/SRR227447.fastq.gz,fastq/SRR227448.fastq.gz
   HepG2_Control   fastq/SRR227552.fastq.gz,fastq/SRR227553.fastq.gz

   $ gen_samplepairlist.sh samplelist.txt
   HepG2_H2A.Z,,HepG2_H2A.Z,sharp
   HepG2_H3K4me3,,HepG2_H3K4me3,sharp
   HepG2_H3K27ac,,HepG2_H3K27ac,sharp
   HepG2_H3K27me3,,HepG2_H3K27me3,sharp
   HepG2_H3K36me3,,HepG2_H3K36me3,sharp
   HepG2_Control,,HepG2_Control,sharp

Please fill the label of Input samples.

- Specify ``-n`` option when omitting input samples (outputs "none").
- Specify ``-b`` option when the peak mode is "broad".


checkQC.py: check the quality of the input ChIP-seq samples
-----------------------------------------------------------------------------

``checkQC.py`` takes ``churros.QCstats.tsv`` and ``samplepairlist.txt`` and prints warnings if the samples do not meet the quality criteria.

.. code-block:: bash

    checkQC.py churros.QCstats.tsv samplepairlist.txt
    Example:
       checkQC.py Churros_result/hg38/churros.QCstats.tsv samplepairlist.txt

- **Unique mapping rate > 60%**: If this rate is low, the reads in FASTQ files may be derived from repetitive regions, contamination with adapter sequences, or low-quality reads. Check the FASTQC result.

- **Nonredundant reads > 10,000,000**: This number indicates the read depth. If the number is low, the number of detected peaks will be small, and the total read normalization for sample comparison will produce noisy results.

- **Read complexity > 0.8**: This value reflects the amount of nonredundant reads in the sample. The low value indicates that the sample is overamplified by the PCR from a small amount of initial DNA, resulting in many false positive peaks.

- **Genome coverage > 0.6**: The fraction of the reference genome covered by at least one mapped read. The low value indicates that the whole genome is not well sequenced and observed. Possible reasons are insufficient read depth and insufficient DNA fragmentation.

   - The exception is RNA polII, which often causes low genome coverage due to its extremely high signal-to-noise ratio.

- **GC content < 60%**: The GC content of the mapped reads. This value is typically ranges from 40% to 60%. The higher value indicates that the reads are derived from the GC-rich regions (i.e., open chromatin), possibly due to the bias of sonication and/or PCR amplification.

   - However, it is noted that the appropriate value depends on the species and the target of the analysis. For example, RNA polII and H3K4me3 are enriched in the GC-rich regions and show high GC levels, but this is normal.

- **SSP-NSC > 3.0 (sharp), and > 1.5 (broad)**: SSP-NSC indicates the signal-to-noise ratio of the sample. The low value indicates that the sample is not enriched in the target regions, resulting in small number of peaks.

- **Background complexity > 0.8**: This value reflects the uniformity of mapped reads in the background regions. The low value indicates that the whole genome is not well fragmented, resulting in many false positive peaks.

   - This value decreases when the sample has high copy number regions in the genome, such as MCF-7 cells. In such cases, a value > 0.6 is considered acceptable.

See `Nakato et al., Brief Bioinform. 2017 <https://academic.oup.com/bib/article/18/2/279/2453282>`_ and `Nakato et al., Bioinformatics 2018 <https://academic.oup.com/bioinformatics/article/34/14/2356/4924717>`_ for the detailed criteria.
