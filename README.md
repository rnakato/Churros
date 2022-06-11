# Churros: Docker image for ChIP-seq/ATAC-seq analysis

Docker image is available at [DockerHub](https://hub.docker.com/r/rnakato/churros).

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

## churros_mapping: ChIP-seq analysis

Usage:

    mapping_QC.sh [-s] [-e] [-a] [-d bamdir] <exec|stats> <fastq> <prefix> <bowtie param> <build>

## ssp.sh

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
