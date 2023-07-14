# Changelog

## 0.9.3 (2023-07-06)
- Add Genometable file for S.pombe
- Modify `ssp.sh` to take a mptable as an argument
- Modify `churros_mapping` to use the mptable in `Ddir/mappability_Mosaics_kmer`
- Bug fix in `calculate_mappability_mosaics.sh`
- Bug fix of `chrros_mapping stats` command when paired-end ChIP-seq data is applied

## 0.9.2 (2023-06-23)
- Update ChromHMM from v1.23 to v1.24

## 0.9.1 (2023-05-11)
- Remove /root/.cpanm/work directory

## 0.9.0 (2023-04-25)
- Changed the base image from rnakato/database to rnakato/mapping (to simplify installation)
- Add [GenMap](https://github.com/cpockrandt/genmap): fast computation of genome mappability
- Add `gen_samplelist.sh` and `gen_samplepairlist.sh`, utilities to create samplelist.txt and samplepairlist.txt.

## 0.8.0 (2023-02-19)
- Update gene annotation for T2T genome
- Update DROMPAplus to v1.17.1
- Bigfix of calculate_mappability_mosaics.sh

## 0.7.1 (2023-02-10)
- Fix bug in macs2.sh

## 0.7.0 (2023-02-08)
- Change default value of peak-calling (MACS2) from `--nomodel` to default

## 0.6.0 (2023-01-30)
- Add [TOBIAS](https://github.com/loosolab/TOBIAS): differential ATAC-seq analysis
- Add [STITCHIT](https://github.com/SchulzLab/STITCHIT): link regulatory elements to genes

## 0.5.0 (2023-01-07)
- Add [Bismark](https://github.com/FelixKrueger/Bismark) and Bismark.sh for bisulfite sequencing analysis
- Add [TrimGalore](https://github.com/FelixKrueger/TrimGalore) for adapter and quality trimming of FastQ files
- Add [Cutadapt](https://cutadapt.readthedocs.io/en/stable/index.html) for adapter trimming of FastQ files

## 0.4.1 (2022-11-24)
- Add ChangeLog
- Bugfix: removed a bug `duplicate 'row.names' are not allowed` in `churros_compare
- Update DROMPA+ to `v1.17.0`.

## 0.4.0
- Public release
- Update manual
