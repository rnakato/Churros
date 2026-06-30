ATAC-seq analysis
===========================================

This page describes how to analyze ATAC-seq data for open chromatin analysis with **Churros**.
Churros includes `HMMRATAC <https://github.com/LiuLabUB/HMMRATAC>`_ bundled in MACS3 and `TOBIAS <https://github.com/loosolab/TOBIAS>`_.
The sample scripts are also available at `Churros GitHub site <https://github.com/rnakato/Churros/tree/main/tutorial/07.ATAC-seq>`_.

.. note::

   | This tutorial assumes using the **Churros** singularity image (``churros.sif``). Please add ``apptainer exec churros.sif`` before each command below.
   | Example: ``apptainer exec churros.sif download_genomedata.sh``


Get data
------------------------

Here we use three ATAC-seq samples, which are paired-end.

.. code-block:: bash

    mkdir -p fastq
    for id in SRR2453157 SRR2453159 SRR2453158
    do
        $sing pfastq-dump -t 4 -s $id -O fastq/ --gzip --split-files
    done

| Then download and generate the reference dataset including genome, gene annotation and index files. **Chuross** contains scripts for that: ``download_genomedata.sh`` and ``build-index.sh``.
| Here we specify ``hg38`` for genome build. See :doc:`Appendix` for the detail of genome build.

.. code-block:: bash

    mkdir -p log
    build=hg38      # genome build
    Ddir=Referencedata_$build   # output directory
    ncore=12    # number of CPUs
    # download the genome
    download_genomedata.sh -s $build $Ddir
    # make Bismark index
    build-index.sh -p $ncore bowtie2 $Ddir


Running Churros
------------------------------------------------

``churros`` has the ``--atac``` option for ATAC-seq analysis, where MACS3 uses ``hmmratac``` command in addition to ``callpeak``.

.. code-block:: bash

    build=hg38
    Ddir=/work/Database/Database_fromDocker/Referencedata_$build
    ncore=24

    churros --atac -p $ncore samplelist.txt samplepairlist.txt $build $Ddir


The results of HMMRATAC are output in ``Churros_result/hg38/hmmratac/``. 



Running TOBIAS
------------------------------------------------

After running ``churros``, you can use ``churros_tobias.sh`` to apply TOBIAS for ATAC-seq footprinting analysis.

``churros_tobias.sh`` requires BAM and peak files for input.

.. code-block:: bash

    churros_tobias.sh [Options] <bam> <refpeak> <genome> <label>
        <bam>: BAM of the ATAC-seq sample
        <refpeak>: Reference peak file (BED format)
        <genome>: Genome fasta file
        <label>: Label of the sample
        Options:
            -o <str>: Output directory (default: "tobias")
            -p <int>: Number of cores to use (default: 4)

``churros_tobias.sh`` executes ``TOBIAS ATACorrect``, ``TOBIAS ScoreBigwig``, and ``TOBIAS BINDetect``.
It also uses ``TOBIAS PlotAggregate`` to plot top three target motifs from `JASPAR2026 database <https://jaspar.elixir.no/>_`.

This is a example script to execute TOBIAS to all samples included in ``samplelist.txt``.

.. code-block:: bash

    build=hg38
    Ddir=Referencedata_$build
    genome=$Ddir/genome.fa

    samplelist=samplelist.txt
    chdir=Churros_result/$build/
    odir=$chdir/tobias

    while read -r LINE || [ -n "$LINE" ]; do
        LINE=($LINE)
        label=${LINE[0]}

        bam=$chdir/bam/$label.sort.bam
        peak=$chdir/macs/${label}_peaks.narrowPeak
        echo -e "\nTOBIAS: $bam and $peak.."
        $sing churros_tobias.sh -o $odir $bam $peak $genome $label
    done < $samplelist

    
The results are output in ``Churros_result/hg38/tobias/``. 
See `TOBIAS User Guide <https://github.com/loosolab/TOBIAS>`_ for more detail.
