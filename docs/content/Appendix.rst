Appendix
=====================

Correspondence table for the genome build
---------------------------------------------------

While ``download_genomedata.sh`` uses the `Ensembl <https://asia.ensembl.org/index.html>`_ genome build, **Churros** uses `UCSC <https://genome.ucsc.edu/>`_ genome build in the command. Here we summarize the correspondence.

.. csv-table::
   :class: align-center

   "**Species**", "**Ensembl**", "**UCSC**"
   "human", "GRCh38", "hg38"
   "human", "GRCh37", "hg19"
   "human", "T2T",    "T2T"
   "mouse", "GRCm39", "mm39"
   "mouse", "GRCm38", "mm10"
   "rat",   "mRatBN7.2", "rn7"
   "fly",   "BDGP6",  "dm6"
   "zebrafish", "GRCz11", "danRer11"
   "chicken", "GRCg6a", "galGal6"
   "C. elegans", "WBcel235", "ce11"
   "S. serevisiae", "R64-1-1", "sacCer3"

For example, to use human genome build GRCh38/hg38, specify GRCh38 or hg38 for ``download_genomedata.sh`` and hg38 for ``churros``.

.. code-block:: bash

   download_genomedata.sh hg38 UCSC-hg38/ 2>&1 | tee log/UCSC-hg38
   churros -p 24 --mpbl samplelist.txt samplepairlist.txt hg38 UCSC-hg38
   # or
   download_genomedata.sh GRCh38 Ensembl-GRCh38/ 2>&1 | tee log/Ensembl-GRCh38
   churros -p 24 --mpbl samplelist.txt samplepairlist.txt hg38 Ensembl-GRCh38/


.. _label_samplelist_pairedend:
Make samplelist for paired-end fastq
------------------------------------------------

This is an example of a samplelist.txt for single-end fastqs.

.. code-block:: bash

    HepG2_H2A.Z     fastq/SRR227639.fastq.gz
    HepG2_H3K4me3   fastq/SRR227563.fastq.gz
    HepG2_H3K27ac   fastq/SRR227575.fastq.gz
    HepG2_H3K27me3  fastq/SRR227598.fastq.gz
    HepG2_H3K36me3  fastq/SRR227447.fastq.gz
    HepG2_Control   fastq/SRR227552.fastq.gz

When using paired-end fastqs, use the second and the third columns to specify the R1 and R2 fastqs like this: 

.. code-block:: bash

    HepG2_H2A.Z     fastq/SRR227639_1.fastq.gz  fastq/SRR227639_2.fastq.gz
    HepG2_H3K4me3   fastq/SRR227563_1.fastq.gz  fastq/SRR227563_2.fastq.gz
    HepG2_H3K27ac   fastq/SRR227575_1.fastq.gz  fastq/SRR227575_2.fastq.gz
    HepG2_H3K27me3  fastq/SRR227598_1.fastq.gz  fastq/SRR227598_2.fastq.gz
    HepG2_H3K36me3  fastq/SRR227447_1.fastq.gz  fastq/SRR227447_2.fastq.gz
    HepG2_Control   fastq/SRR227552_1.fastq.gz  fastq/SRR227552_2.fastq.gz

You can use 'gen_samplelist.sh -p <https://churros.readthedocs.io/en/latest/content/Commands.html#utility-tools>'_ to make the samplelist.txt for paired-end samples.


Make mappability files
--------------------------------------------------

If you want to make the mappability files by yourself, you can use ``calculate_mappability_mosaics.sh``.

.. code-block:: bash

    calculate_mappability_mosaics.sh [Options] <Ddir>
       <Ddir>: directory of the genome
       Options:
          -f <int>: fragment length (default: 150)
          -b <array <int>>: binsizes (default: "10000 25000 50000 500000 1000000")
          -r <array <int>>: read length (default: "36 50")
          -p <int>: number of CPUs (default: 12)
       Example:
          calculate_mappability_mosaics.sh Ensembl-GRCh38

For example, if you want to make the mappability files for genome build hg38 with the read length 75 and 100, type:  

.. code-block:: bash

    calculate_mappability_mosaics.sh -r "75 100" UCSC-hg38

Then the data is created in ``UCSC-hg38/mappability_Mosaics_75mer`` and ``UCSC-hg38/mappability_Mosaics_100mer``.

.. note::

   This command takes long time for computation. Set large number for ``-p`` (e.g., 64).