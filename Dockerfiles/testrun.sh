for tool in sambamba fastq-dump bedtools samtools macs2 drompa+ ssp trim_galore genmap  bismark bowtie bowtie2 chromap deeptools cutadapt epilogos
do
    echo $tool
    docker run --rm -it rnakato/churros $tool --version
done

for tool in STITCH bwa
do
    echo $tool
    docker run --rm -it rnakato/churros $tool
done

for tool in edgeR DESeq2 ChIPseeker rGREAT clusterProfiler motifbreakR
do
    docker run -it --rm rnakato/churros R -e "library("$tool"); sessionInfo(package = "$tool")"
done
