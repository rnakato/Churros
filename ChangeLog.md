# Changelog

## 1.3.0 (2024-10-29)
- Starting with this version, **Churros** can accept BAM files as input in samplelist.txt instead of FASTQ files.
- Modified ``churros`` to abort when an error occurs in ``fastqc`` to detect cases where there are problems with the FASTQ file.

## 1.2.2 (2024-10-02)
- Updated SAMtools from 1.19.2 to 1.21
- Updated SRA Toolkit from 3.0.10 to v3.1.1
- Added [parallel-fastq-dump](https://github.com/rvalieris/parallel-fastq-dump)
- Added `Arabidopsis thaliana` genome (TAIR10) in `download_genomedata.sh`.

## 1.2.1 (2024-9-25)
- Fixed a bug in `churros` where the last line of the samplelist was not read correctly if there was no newline character at the end.
- Modified `churros` to allow space-separated samplelist.txt.
- Fixed an issue where several R tools were unusable since `v1.2.0`.
- Added scripts for DNA methylation analysis in the `tutorial` directory.

## 1.2.0 (2024-8-25)
- Fixed a bug in `SSP` and `DROMPAplus` that causes a memory error when the input file has long reads (>200 bp).

## 1.1.2 (2024-8-10)
- Fixed a bug in `churros_compare` that caused the sample labels in `drompa+.macspeak.PCSHARP.100.pdf` to be displayed incorrectly if the input samples were not specified in samplepairlist.txt.

## 1.1.1 (2024-7-18)
- Fixed a bug in `churros_compare` that had an error when comparing bigWig files.

## 1.1.0 (2024-7-02)
- Fixed a bug in `build-index.sh` that did not accept indexing for bismark.
- Added [methylKit](https://www.bioconductor.org/packages/release/bioc/html/methylKit.html) for RRBS analysis.
- Added [MEDIPS](https://www.bioconductor.org/packages/release/bioc/html/MEDIPS.html) for MeDIP-seq analysis.
- Added [abismal](https://github.com/smithlabcode/abismal) for WGBS analysis.
- Added [MethPipe](https://smithlabresearch.org/software/methpipe/) for WGBS analysis.

## 1.0.0 (2024-5-19)
- Added `churros_mapping_spikein` for spike-in normalization.
- Changed Python environment from conda to micromamba (`/opt/micromamba`)

## 0.13.2 (2024-4-6)
- Big fix when no input samples are specified in samplepairlist.txt.

## 0.13.1 (2024-3-29)
- Added to `churros` the function that checks if the samples shown in samplepairlist.txt are in samplelist.txt.
- Fixed a bug in `churros` when applying single-end reads with the `--fastqtrimming` option.

## 0.13.0 (2024-3-18)
- Modified fastp execution to handle paired-end FASTQ files at a same time
- Added `--nofilter`, `--fastqtrimming` and `--parse2wigparam` options to `churros`
- Added `-N: do not filter PCR duplication` and `-Q: additional parameter for parse2wig+` options to `churros_mapping`
- Added `-e` and `-x` options to `churros_genPvalwig` to generate different wig files for visualization.
- Added `n: do not filter PCR duplication` and `-P: other options` options to `parse2wig+.sh`.
- Added `mptable.UCSC.T2T.28mer.flen150.txt` and `mptable.UCSC.T2T.36mer.flen150.txt` in `SSP/data/mptable`.
- Added the ideogram file for the T2T genome in `DROMPAplus/data/ideogram`.
- Fixed a bug in `churros_mapping` and `churros_callpeak` that did not handle the name of the mapfiles correctly when passing additional parameters to `bowtie2.sh`.
- Fixed a bug in `churros_peakcall` that did not create `macs/samplepairlist.txt` correctly when input samples were not specified.
- Updated `churros_mapping` to show header correctly for paired-end FASTQ files.
- Modified `download_genomedata.sh` to download the reference file of the T2T genome.
- Added [ATACseqQC](https://bioconductor.org/packages/release/bioc/html/ATACseqQC.html) for quality check of ATAC-seq data
- Added [TFBSTools](https://bioconductor.org/packages/release/bioc/html/TFBSTools.html) for motif search
- Updated chromap from v0.2.5 to v0.2.6
- Updated SSP and DROMPAplus to modify `parsestats4DROMPAplus.pl`
- Fixed the warning of xargs in `churros_callpeak`
- `download_genomedata.sh`:
    - Updated the version of Ensemble data from 106 to 111.
    - Added `Medaka` genome.
- Changed `churros_visualize` to allow ChIP samples even without the input sample when the `-G` option is specified.
- Added the `-n: do not filter PCR duplicate` option to `churros_genPvalwig`.

## 0.12.2 (2024-3-5)
- Fixed a bug in `churros` that did not output the mapping statistics file correctly.
- Fixed a bug in `churros` that caused the header line in the stats file to be incorrect for paired-end files.
- `churros_genPvalwig`: Added the `-e` and `-x` options to output different distribution files as well.
- Added `csv2xlsx.pl` to convert `churros.QCstats.tsv` to `churros.QCstats.xlsx`.

## 0.12.1 (2024-3-3)
- Fixed a bug in `download_genomedata.sh` that did not download the genome data correctly.
- Install MS core fonts (ttf-mscorefonts-installer)

## 0.12.0 (2024-2-25)
- Added [Cobind](https://cobind.readthedocs.io/en/latest/index.html) for evaluating overlap of peaks
- Fixed a bug in `churros_mapping` where the `-n` option was not recognized.

## 0.11.1 (2024-2-21)
- Install MS core fonts (ttf-mscorefonts-installer)

## 0.11.0 (2024-2-3)
- Added `checkQC.py` for checking the quality of the input ChIP-seq samples
    - `checkQC.py` outputs the warnings in `Churros_result/<build>/QCcheck.log` if the samples do not meet the quality criteria.
- Installed `sudo`
- Updated Miniconda from Python 3.9 to Python 3.10
- Updated Bowtie2 from v2.4.5 to v2.5.3
- Updated chromap from v0.2.4 to v0.2.5
- Updated ChromHMM from v1.24 to v1.25
- Updated ChromImpute from v1.0.3 to v1.0.5

## 0.10.9 (2024-1-30)
- Added [STARE](https://stare.readthedocs.io/en/latest/index.html) for enhancer-promoter analysis
- Updated SAMtools from 1.17 to 1.19.2
- Updated SRAtoolkit from 3.0.2 to 3.0.10

## 0.10.8 (2024-1-12)
- Added a script `generate_samplelist_from_SRA.py` that generates the sample list from SraExperimentPackage.xml and SraRunTable.txt.

## 0.10.7 (2023-12-31)
- Updated SSP (v1.3.0 -> v1.3.1) and DROMPA+ (v1.18.0 -> v1.18.1).
- Update Manual

## 0.10.6 (2023-12-26)
- Added warning messages in `churros` when there are the same raws in `samplelist.txt`.

## 0.10.5 (2023-12-21)
- Bug fix in `gen_samplelist.sh`

## 0.10.4 (2023-12-12)
- Changed the directory of the fastqc and fastp output files from `Churros_result/$build` to `Churros_result/` because they are independent of the genome build.

## 0.10.3 (2023-11-06)
- Added `convert_SraRunTable_to_samplelist.py` that makes samplelist.txt from SraRunTable.txt

## 0.10.2 (2023-10-07)
- Omited the creation of PDF files for WG and p-value distributions when no input sample is provided

## 0.10.1 (2023-10-01)
- Fixed bug occurring when no input sample is provided

## 0.10.0 (2023-08-04)
- Added `churros_classheat` function
- Added [HOMER](http://homer.ucsd.edu/homer/) for Motif analysis

## 0.9.3 (2023-07-06)
- Added Genometable file for S.pombe
- Modified `ssp.sh` to accept mptable as an argument
- Modified `churros_mapping` to use mptable in `Ddir/mappability_Mosaics_kmer`
- Fixed bug in `calculate_mappability_mosaics.sh`
- Fixed bug in `chrros_mapping stats` command for paired-end ChIP-seq data

## 0.9.2 (2023-06-23)
- Updated ChromHMM from v1.23 to v1.24

## 0.9.1 (2023-05-11)
- Removed /root/.cpanm/work directory to avoid the user id error

## 0.9.0 (2023-04-25)
- Changed base image from `rnakato/database` to `rnakato/mapping` for simplified installation
- Added [GenMap](https://github.com/cpockrandt/genmap) for fast genome mappability computation
- Added utility scripts `gen_samplelist.sh` and `gen_samplepairlist.sh` for creating sample lists

## 0.8.0 (2023-02-19)
- Updated gene annotation for T2T genome
- Updated DROMPAplus to v1.17.1
- Fixed bug in `calculate_mappability_mosaics.sh`

## 0.7.1 (2023-02-10)
- Fixed bug in `macs2.sh`

## 0.7.0 (2023-02-08)
- Changed default value for peak-calling in MACS2 from `--nomodel` to default settings

## 0.6.0 (2023-01-30)
- Added [TOBIAS](https://github.com/loosolab/TOBIAS) for differential ATAC-seq analysis
- Added [STITCHIT](https://github.com/SchulzLab/STITCHIT) for link regulatory elements to genes

## 0.5.0 (2023-01-07)
- Added [Bismark](https://github.com/FelixKrueger/Bismark) and the custom script `Bismark.sh` for bisulfite sequencing analysis
- Added [TrimGalore](https://github.com/FelixKrueger/TrimGalore) for adapter and quality trimming of FastQ files
- Added [Cutadapt](https://cutadapt.readthedocs.io/en/stable/index.html) for adapter trimming of FastQ files

## 0.4.1 (2022-11-24)
- Added this ChangeLog
- Fixed bug: removed a bug `duplicate 'row.names' are not allowed` in `churros_compare`
- Updated DROMPAplus to `v1.17.0`

## 0.4.0
- Public release
- Updated manual
