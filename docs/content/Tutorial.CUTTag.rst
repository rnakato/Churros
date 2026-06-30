CUT&Tag/CUT&Run analysis
===========================================

This page describes how to analyze CUT&Tag/CUT&Run data with **Churros**.
Churros includes `SEACR <https://github.com/FredHutch/SEACR>`_ .
The sample scripts are also available at `Churros GitHub site <https://github.com/rnakato/Churros/tree/main/tutorial/08.CUTandTAG>`_.

.. note::

   | This tutorial assumes using the **Churros** singularity image (``churros.sif``). Please add ``apptainer exec churros.sif`` before each command below.
   | Example: ``apptainer exec churros.sif download_genomedata.sh``

.. contents:: 
   :depth: 3


Get data
------------------------

Here we use CUT&Tag data from `Kaya-Okur et al, Nat Protoc. 2020 <https://www.nature.com/articles/s41596-020-0373-x>`_, which are paired-end.

.. code-block:: bash

    mkdir -p fastq
    for id in SRR12246717 SRR11074240 SRR11074254 SRR11074258 SRR11923224 SRR8754611
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

Several specific parameters must be specified for CUT&Tag analysis.

- First, adapter trimming is highly recommended in CUT&Tag and can be enabled with the ``--fastqtrimming`` option.
- Second, reads that are typically marked as PCR duplicates should not be filtered out because, in CUT&Tag, they may reflect high target specificity rather than PCR amplification artifacts. The ``--keepdup`` option opts out of the duplicate filtering step.
- Third, here we use the parameter set for mapping recommended by `Kaya-Okur et al, Nat Protoc. 2020 <https://www.nature.com/articles/s41596-020-0373-x>`_.

The resulting command is as follows.


.. code-block:: bash

    build=hg38
    Ddir=Referencedata_$build
    ncore=12

    # Use the following parameters for Bowtie2 mapping
    btparam="--end-to-end --very-sensitive --no-mixed --no-discordant --phred33 -I 10 -X 700"
    churros -p $ncore --keepdup --fastqtrimming --mapparam "$btparam" \
            samplelist.txt samplepairlist.txt $build $Ddir



Running SEACR
------------------------------------------------

SEACR is a peak-calling tool designed for CUT&Tag and CUT&RUN data.
**Churros** has ``churros_SEACR`` command for it.

.. code-block:: bash

    churros_SEACR [Options] <samplelist> <samplepairlist> <Churrosdir> <genometable>
        <samplelist>: List of samples
        <samplepairlist>: List of sample pairs
        <Churrosdir>: Churros output directory
        <genometable>: Path to genome table file
        Options:
            -p <int>: Number of threads (default: 4)

This command executes the steps below for all samples included in ``samplepairlist``:

    - Sort BAM files by read names (\*.qname.bam).
    - Generates bedGraph files to be used as input for SEACR.
    - Plots the fragment length distribution.
    - If control samples are available, such as IgG, runs SEACR in both stringent and relaxed modes.
    - If control samples are not available, runs SEACR in non-control mode with q < 0.01.


After running ``churros`` above, you can run ``churros_SEACR`` as follows.

.. code-block:: bash

    build=hg38
    Ddir=Referencedata_$build
    gt=$Ddir/genometable.txt

    Churrosdir=Churros_result/$build
    ncore=8

    $sing churros_SEACR -p $ncore samplelist.txt samplepairlist.txt $Churrosdir $gt

    
The results are output in ``Churros_result/hg38/SEACR/``. 
