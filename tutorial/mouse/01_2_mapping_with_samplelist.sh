#sing="singularity exec --bind /work,/work2 /work/SingularityImages/churros.0.2.0.sif"
sing="singularity exec churros.0.2.0.sif"

build=mm10
Ddir=Ensembl-GRCm38

while read LINE; do
    LINE=($LINE)
    prefix=${LINE[0]}
    fq1=${LINE[1]}
    $sing churros_mapping -m -p 12 exec "$fq1" $prefix $build $Ddir
done < samplelist.txt

# output QC stats
$sing churros_mapping -m header "$fq1" label $build $Ddir > churros.QCstats.tsv

while read LINE; do
    LINE=($LINE)
    prefix=${LINE[0]}
    fq1=${LINE[1]}
    $sing churros_mapping -m stats "$fq1" $prefix $build $Ddir  >> churros.QCstats.tsv
done < samplelist.txt
