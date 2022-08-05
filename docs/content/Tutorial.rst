Tutorial
=====================

This tutorial assumes using singularity image.
Please add ``singularity exec churros.sif`` before the commands.

The sample scripts are also available at `Chrros GitHub <https://github.com/rnakato/Churros/tree/main/tutorial>`_.

Get data
------------------------

Here we use five histone modification data of HepG2 cells (from `ENCODE Project <https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE29611>`_):

.. code-block:: bash

    mkdir -p fastq
    for id in SRR227447 SRR227448 SRR227552 SRR227553 SRR227563 SRR227564 SRR227575 SRR227576 SRR227598 SRR227599 SRR227639 SRR227640
    do
        fastq-dump --gzip $id -O fastq
    done

Then download and generate the reference dataset including genome, gene annotation and index files.
**Chuross** contains several scripts to do that:

.. code-block:: bash

    mkdir -p log
    build=GRCh38
    ncore=24
    # download the genome
    download_genomedata.sh $build Ensembl-$build/ 2>&1 | tee log/Ensembl-$build
    # make Bowtie2 index
    build-index.sh -p $ncore bowtie2 Ensembl-$build


In addition, download mappability files from our `GoogleDrive <https://drive.google.com/file/d/1VuxMv25AomaYvVnn7X7KfaW4LRDsdaVk/view?usp=sharing>`_ and put the data in ``Ensembl-$build``.

Prepare sample list
-------------------------------------

Churros takes two input files, ``samplelist.txt`` and ``samplepairlist.txt``

samplelist.txt
++++++++++++++++++++++++++

``samplelist.txt`` is a tab-delimited file (TSV) that describes the sample labels and the fastq files. 
Multiple fastq files can be used by separateing by ``,``. 

.. code-block:: bash

    HepG2_H2A.Z     fastq/SRR227639.fastq.gz,fastq/SRR227640.fastq.gz
    HepG2_H3K4me3   fastq/SRR227563.fastq.gz,fastq/SRR227564.fastq.gz
    HepG2_H3K27ac   fastq/SRR227575.fastq.gz,fastq/SRR227576.fastq.gz
    HepG2_H3K27me3  fastq/SRR227598.fastq.gz,fastq/SRR227599.fastq.gz
    HepG2_H3K36me3  fastq/SRR227447.fastq.gz,fastq/SRR227448.fastq.gz
    HepG2_Control   fastq/SRR227552.fastq.gz,fastq/SRR227553.fastq.gz


samplepairlist.txt
++++++++++++++++++++++++++

``samplelist.txt`` is a comma-delimited file (CSV) that describes the ChIP/Input pairs as follows:

- ChIP-sample label
- Input-sample label
- prefix
- peak mode

ChIP and input sample labels should be identical to those in ``samplelist.txt``.
Input samples can be omitted if unavailable.
``prefix`` is used for the output files.
``peak mode`` is either ``[sharp|broad|sharp-nomodel|broad-nomodel]``. This parameter is used for `MACS2 <https://github.com/macs3-project/MACS>`_.

.. code-block:: bash

    HepG2_H2A.Z,HepG2_Control,HepG2_H2A.Z,sharp
    HepG2_H3K4me3,HepG2_Control,HepG2_H3K4me3,sharp
    HepG2_H3K27ac,HepG2_Control,HepG2_H3K27ac,sharp
    HepG2_H3K27me3,HepG2_Control,HepG2_H3K27me3,broad
    HepG2_H3K36me3,HepG2_Control,HepG2_H3K36me3,broad

Full analysis by Churros
------------------------------------------------

``churros`` command executes all steps from mapping to visualization.

.. code-block:: bash

    Ddir=Ensembl-GRCh38/
    churros -w samplelist.txt samplepairlist.txt hg38 $Ddir


Output
++++++++++++++++++++++

QC
pdf
peaks
bam/cram
wig


Mapping reads by Bowtie2
--------------------------------------------------

``churros_mapping`` uses Bowtie2 for mapping in default.
The mapped reads are then quality-checked and converted to BigWig files.

.. code-block:: bash

    build=hg38
    Ddir=Ensembl-GRCh38
    churros_mapping exec fastq/SRR227447.fastq.gz,fastq/SRR227448.fastq.gz HepG2_H3K36me3 $build $Ddir
    churros_mapping exec fastq/SRR227552.fastq.gz,fastq/SRR227553.fastq.gz HepG2_Control  $build $Ddir
    churros_mapping exec fastq/SRR227563.fastq.gz,fastq/SRR227564.fastq.gz HepG2_H3K4me3  $build $Ddir
    churros_mapping exec fastq/SRR227575.fastq.gz,fastq/SRR227576.fastq.gz HepG2_H3K27ac  $build $Ddir
    churros_mapping exec fastq/SRR227598.fastq.gz,fastq/SRR227599.fastq.gz HepG2_H3K27me3 $build $Ddir
    churros_mapping exec fastq/SRR227639.fastq.gz,fastq/SRR227640.fastq.gz HepG2_H2A.Z    $build $Ddir

Of course you can also use a shell loop:

.. code-block:: bash

    FASTQ=(
        "fastq/SRR227447.fastq.gz,fastq/SRR227448.fastq.gz"
        "fastq/SRR227552.fastq.gz,fastq/SRR227553.fastq.gz"
        "fastq/SRR227563.fastq.gz,fastq/SRR227564.fastq.gz"
        "fastq/SRR227575.fastq.gz,fastq/SRR227576.fastq.gz"
        "fastq/SRR227598.fastq.gz,fastq/SRR227599.fastq.gz"
        "fastq/SRR227639.fastq.gz,fastq/SRR227640.fastq.gz"
    )

    NAME=(
        "HepG2_H3K36me3"
        "HepG2_Control"
        "HepG2_H3K4me3"
        "HepG2_H3K27ac"
        "HepG2_H3K27me3"
        "HepG2_H2A.Z"
    )
    build=hg38
    Ddir=Ensembl-GRCh38
    for ((i=0; i<${#FASTQ[@]}; i++))
    do
        echo ${NAME[$i]}
        $sing churros_mapping exec "${FASTQ[$i]}" ${NAME[$i]} $build $Ddir
    done




Call peaks by MACS2
--------------------------------------------------

``churros_callpeak.sh`` calls peaks of the samples specified in ``samplepairlist.txt``.
Input samples can be omitted.

.. code-block:: bash

    build=hg38
    churros_callpeak samplepairlist.txt $build

    
Visualize read distributions by DROMPA+
--------------------------------------------------

``churros_callpeak.sh`` calls peaks of the samples specified in ``samplepairlist.txt``.
Input samples can be omitted.

.. code-block:: bash

    build=hg38
    Ddir=Ensembl-GRCh38
    
    mkdir -p pdf
    churros_visualize samplepairlist.txt pdf/drompa+ $build $Ddir
    churros_visualize macs/samplepairlist.txt pdf/drompa+.macspeak $build $Ddir
    churros_visualize -b 5000 -l 8000 -P "--scale_tag 100" samplepairlist.txt pdf/drompa+.bin5M $build $Ddir
    churros_visualize -p -b 5000 -l 8000 samplepairlist.txt pdf/drompa+.pval.bin5M $build $Ddir
    churros_visualize -G macs/samplepairlist.txt pdf/drompa+ $build $Ddir