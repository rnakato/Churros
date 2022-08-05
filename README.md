# Churros: Docker image for ChIP-seq/ATAC-seq analysis

## 1. Installation

Docker image is available at [DockerHub](https://hub.docker.com/r/rnakato/churros).

### 1.1 Docker 
To use docker command, type:

    docker pull rnakato/churros
    docker run -it --rm rnakato/churros <command>

### 1.2 Singularity

Singularity can also be used to execute the docker image:

    singularity build churros.sif docker://rnakato/churros
    singularity exec churros.sif <command>

Singularity mounts the current directory automatically. If you access the files in the other directory, mount it by `--bind` option:

    singularity exec --bind /work churros.sif <command>
    
This command mounts `/work` directory.


## 2. Usage

See the [Manual](https://churros.readthedocs.io/en/latest/).

## 2. Tutorial

Generate the database (genome, gene annotation and index file):

    build=GRCh38  # specify the build (Ensembl) that you need
    Ddir=Ensembl-$build/
    mkdir -p log
    # Download genome and gtf
    download_genomedata.sh $build $Ddir 2>&1 | tee log/Ensembl-$build
    # make index for STAR-RSEM 
    build-index.sh rsem-star $build $Ddir

### Execute bowtie2 and parse2wig+

    mapping_QC.sh exec fastq/SRR20753.fastq Rad21 "-n2 -m1" hg38

Output:
* mapfile (bam/Rad21-n2-m1-hg38.sort.bam)

* parse2wig output (parse2wigdir/Rad21-n2-m1-hg38-*)

* output by SSP (with option option)
 sspout/Rad21-n2-m1-hg38.*

* bowtie log (log/bowtie-Rad21-hg38)

* parse2wig log (log/parsestats-Rad21-n2-m1-hg38)


### Check mapping stats:

    mapping_QC.sh stats fastq/SRR20753.fastq Rad21 "-n2 -m1" hg38

||Sample	reads	|mapped unique	|%	|mapped >= 2	|%	|mapped total	|%	|unmapped	|%	|Nonredundant	|Redundant	|Complexity for10M	|Read depth	|Genome coverage	|Tested_reads	|GC summit	|NSC	|RSC	|Qtag|
----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----
|CTCF |	59,677,529	|47,893,926	|80.25	|10,056,318	|16.85	|57,950,244	|97.11	|1,727,285	|2.89	|19856031 (41.5%)	|28037895 (58.5%)	|0.732	|1.11	|0.99	|7,320,051 / 9,995,223|	43	|1.131071|	1.729936|	2|
|Rad21	|33,035,083	|9,543,103	|28.89	|3,975,423	|12.03	|13,518,526	|40.92	|19,516,557	|59.08	|8321928 (87.2%)	|1221175 (12.8%)|(0.872)	|0.46	|0.99	|8,321,928 / 9,543,103	|50	|1.162648	|0.9433482	|0|


### For multiple gzipped fastq files:

      dir=fastq/
      build=hg38
      for prefix in `ls $dir/*fastq.gz | sed -e 's/'$dir'\/'//g -e 's/.fastq.gz//g'`
      do
          fastqc.sh $prefix
          mapping_QC.sh -a exec $dir/$prefix.fastq $prefix "-n2 -m1" $build
          mapping_QC.sh -a stats $dir/$prefix.fastq $prefix "-n2 -m1" $build
      done


## 3. Commands in Churros

### download_genomedata.sh

`download_genomedata.sh` downloads the genome and gene annotation files of the genome build specified.
**Churros** assumes the reference data is downloaded bu this command.

    download_genomedata.sh <build> <outputdir>
      build:
             human (GRCh38, GRCh37)
             mouse (GRCm39, GRCm38)
             rat (mRatBN7.2)
             fly (BDGP6)
             zebrafish (GRCz11)
             chicken (GRCg6a)
             African clawed frog (xenLae2)
             C. elegans (WBcel235)
             S. serevisiae (R64-1-1)
             S. pombe (SPombe)
      Example:
             download_genomedata.sh GRCh38 Ensembl-GRCh38


### build-index.sh

`build-index.sh` builds index files of the tools specified. `<odir>` should be the same with `<outputdir>` directory provided in `download_genomedata.sh`. 
This `<odir>` is used in the **Churros** commands below.

    build-index.sh [-p ncore] -a <program> <odir>
      program: bowtie, bowtie-cs, bowtie2, bwa, chromap
      Example:
             build-index.sh bowtie2 Ensembl-GRCh38

### churros_mapping: ChIP-seq analysis

`churros_mapping` takes a fastq file as input and:
- uses `bowtie2.sh` for mapping reads
- uses `parse2wig+.sh` for generating bigWig
- uses `ssp.sh` for quality check.

`churros_mapping` contains three commands, `exec`, `stats` and `header`.

    churros_mapping [-b binsize] [-n] [-f of] [-d outputdir] [-p "bowtie2 param"] <exec|stats|header> <fastq> <prefix> <build> <Ddir>
      <command>:
         exec: bowtie2, ssp and parse2wig+;
         stats: show mapping/QC stats;
         header: print header line of the stats
      <fastq>: fastq file
      <prefix>: output prefix
      <build>: genome build (e.g., hg38)
      <Ddir>: directory of bowtie2 index
      Options:
         -b: binsize of parse2wig+ (defalt: 100)
         -m: consider genome mappability in parse2wig+
         -n: omit ssp
         -f: output format of parse2wig+ (default: 3)
                  0: compressed wig (.wig.gz)
                  1: uncompressed wig (.wig)
                  2: bedGraph (.bedGraph)
                  3: bigWig (.bw)
         -d: output directory of cram files (default: cram)
         -p "bowtie2 param": parameter of bowtie2 (shouled be quated)
      Example:
         For single-end: churros_mapping exec chip.fastq.gz chip hg38 Database/Ensembl-GRCh38
         For paired-end: churros_mapping exec "-1 chip_1.fastq.gz -2 chip_2.fastq.gz" chip hg38 Database/Ensembl-GRCh38

          
### bowtie2.sh

### parse2wig+.sh 

### ssp.sh

    ssp.sh [-k kmer] [-o dir] [-p] <mapfile> <prefix> <build> <genometable>
       <mapfile>: mapfile (SAM|BAM|CRAM|TAGALIGN format)
       <prefix>: output prefix
       <build>: genome build (e.g., hg38)
       <genometable>: genome table file
       Options:
          -k: read length (36 or 50) for mappability calculation (default: 50)
          -p: for paired-end file
         -o: output directory (default: sspout)
       Example:
          For single-end: ssp.sh chip.sort.bam chip hg38 genometable.hg38.txt
          For single-end: ssp.sh -p chip.sort.bam chip hg38 genometable.hg38.txt


## 4. Utility scripts in Churros
   
### parsebowtielog.pl

### parsebowtielog2.pl

## 5. Build Docker image from Dockerfile

First clone and move to the repository

    git clone https://github.com/rnakato/RumBall.git
    cd RumBall

Then type:

    docker build -t <account>/rumball

## 6. Contact

Ryuichiro Nakato: rnakato AT iqb.u-tokyo.ac.jp
