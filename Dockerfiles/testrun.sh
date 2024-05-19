version=1.0.0
for tool in sambamba fastq-dump bedtools samtools macs2 drompa+ ssp trim_galore genmap bismark bowtie bowtie2 chromap deeptools cutadapt epilogos cobind.py
do
    echo $tool
    docker run --rm -it rnakato/churros:$version $tool --version
done

for tool in STITCH bwa
do
    echo $tool
    docker run --rm -it rnakato/churros:$version $tool
done

for tool in edgeR DESeq2 ChIPseeker rGREAT clusterProfiler motifbreakR ATACseqQC TFBSTools
do
    docker run -it --rm rnakato/churros:$version R -e "library("$tool")"
done
