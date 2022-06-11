for id in SRR227447 SRR227448 SRR227552 SRR227553 SRR227563 SRR227564 SRR227575 SRR227576 SRR227598 SRR227599 SRR227639 SRR227640
do
    singularity exec --bind /work,/work2 /work/SingularityImages/SRAtools.3.0.0.sif fastq-dump $id
done

pigz *.fastq
