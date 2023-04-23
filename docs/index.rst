================================================================
Churros
================================================================

**Churros** is a Epigenome analysis pipeline with Docker.
While **Chross** mainly focuses on the ChIP-seq analysis, it can also handle CUT&TAG, ATAC-seq and DNA methylation data.

The latest version of **Churros** (``v0.9.0``) internally uses the tools including:

- Mapping
   - Bowtie v1.1.2
   - Bowtie2 v2.4.5
   - BWA v0.7.17
   - chromap v0.2.4

- ChIP-seq analysis
   - MACS2 v2.2.6
   - DROMPA+ v1.17.0
   - SSP v1.2.5
   - ROSE v0.1
   - ChromHMM v1.23
   - ChromImpute v1.0.3
   - epilogos v0.1.1
   - [STITCHIT](https://github.com/SchulzLab/STITCHIT): link regulatory elements to genes

- Bisulfite sequencing (DNA methylation)
   - [Bismark](https://github.com/FelixKrueger/Bismark) v0.22.3

- Quality assessment
   - FastQC v0.11.9
   - fastp v0.23.2
   - MultiQC v1.12

- File processing
   - SAMtools v1.17
   - BEDtools v2.30.0
   - [deepTools](https://deeptools.readthedocs.io/) v3.5.1

- Adapter trimming
   - [Cutadapt](https://cutadapt.readthedocs.io/en/stable/index.html) v4.2
   - [TrimGalore](https://github.com/FelixKrueger/TrimGalore) v0.6.7

- Mappability culculation
   - Mosaics
   - [GenMap](https://github.com/cpockrandt/genmap) v1.2.0

- Utility tools
   - SRAtoolkit v3.0.2


Contents:
---------------

.. toctree::
   :numbered:
   :glob:
   :maxdepth: 1

   content/Install
   content/Tutorial
   content/Tutorial.scer
   content/Tutorial.Bisulfite
   content/Commands
   content/Appendix


Contact:
--------------

:Mail: rnakato AT iqb.u-tokyo.ac.jp
