sing="singularity exec --bind /work,/work2 /work/SingularityImages/churros.0.2.0.sif"

while read LINE; do
    LINE=($LINE)
    prefix=${LINE[0]}
    fq1=${LINE[1]}
    $sing churros_mapping -p 12 exec "$fq1" $prefix hg38 Ensembl-GRCh38
done < samplelist.txt
