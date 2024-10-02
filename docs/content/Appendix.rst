Appendix
=====================

.. contents:: 
   :depth: 2

Correspondence table for the genome build
---------------------------------------------------

While ``download_genomedata.sh`` uses the `Ensembl <https://asia.ensembl.org/index.html>`_ genome build, **Churros** uses `UCSC <https://genome.ucsc.edu/>`_ genome build in the command. Here we summarize the correspondence.

.. csv-table::
   :class: align-center

   "**Species**", "**Ensembl**", "**UCSC**"
   "human", "GRCh38", "hg38"
   "human", "GRCh37", "hg19"
   "mouse", "GRCm39", "mm39"
   "mouse", "GRCm38", "mm10"
   "rat",   "mRatBN7.2", "rn7"
   "fly",   "BDGP6",  "dm6"
   "zebrafish", "GRCz11", "danRer11"
   "chicken", "GRCg6a", "galGal6"
   "C.elegans", "WBcel235", "ce11"
   "S.serevisiae", "R64-1-1", "sacCer3"
   "African clawed frog", "Xenopus_tropicalis", "xenLae2"

For example, to use human genome build GRCh38/hg38, specify GRCh38 or hg38 for ``download_genomedata.sh`` and hg38 for ``churros``.

.. code-block:: bash

   download_genomedata.sh hg38 UCSC-hg38/ 2>&1 | tee log/UCSC-hg38
   churros -p 24 --mpbl samplelist.txt samplepairlist.txt hg38 UCSC-hg38
   # or
   download_genomedata.sh GRCh38 Ensembl-GRCh38/ 2>&1 | tee log/Ensembl-GRCh38
   churros -p 24 --mpbl samplelist.txt samplepairlist.txt hg38 Ensembl-GRCh38/

Other species: 

.. csv-table::
   :class: align-center
   
   "**Species**", "**ID**"
   "human", "T2T"
   "S.pombe", "SPombe"
   "A.thaliana", "TAIR10"
   "Oryzias latipes", "Medaka"
   "Hydra vulgaris AEP", "HVAEP"


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