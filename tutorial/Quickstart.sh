sing="singularity exec --bind /work,/work2 /work/SingularityImages/churros.0.1.0.sif"
Ddir=/work/Database/Database_fromDocker/Ensembl-GRCh38/
ncore=48

$sing churros -p $ncore -D Churrosdir2 samplelist.txt samplepairlist.txt hg38 $Ddir
# do not consider mappability
#$sing churros -p $ncore -w samplelist.txt samplepairlist.txt hg38 $Ddir

# consider mappability
#$sing churros -m -w samplelist.txt samplepairlist.txt hg38 $Ddir
