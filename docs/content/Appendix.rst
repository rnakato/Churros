Appendix
=====================

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

    calculate_mappability_mosaics.sh -r "75 100" Ensembl-GRCh38

Then the data is created in ``Ensembl-GRCm38/mappability_Mosaics_75mer`` and ``Ensembl-GRCm38/mappability_Mosaics_100mer``.

Note: this command takes long time for computation. Set large number for ``-p`` (e.g., 64).