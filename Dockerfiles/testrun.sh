for tool in fastq-dump bedtools samtools drompa+ ssp trim_galore genmap  bismark bowtie bowtie2 chromap deeptools cutadapt epilogos
do
    echo $tool
    docker run --rm -it rnakato/churros:0.9.0 $tool --version
done
for tool in STITCH bwa
do
    echo $tool
    docker run --rm -it rnakato/churros:0.9.0 $tool
done