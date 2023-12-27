# Changelog

## 0.10.6 (2023-12-26)
- Added warning messages in `churros` when there are the same raws in `samplelist.txt`.

## 0.10.5 (2023-12-21)
- Bug fix in `gen_samplelist.sh`

## 0.10.4 (2023-12-12)
- Changed the directory of the fastqc and fastp output files from `Churros_result/$build` to `Churros_result/` because they are independent of the genome build.

## 0.10.3 (2023-11-06)
- Added convert_SraRunTable_to_samplelist.py that makes samplelist.txt from SraRunTable.txt

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
