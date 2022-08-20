sing="singularity exec --bind /work,/work2 /work/SingularityImages/churros.0.2.0.sif"
Ddir=/work/Database/Database_fromDocker/Ensembl-GRCh38/
ncore=48

$sing churros -p $ncore --mpbl --outputpvalue samplelist.txt samplepairlist.txt hg38 $Ddir


#$sing churros -p $ncore -D Churrosdir3 samplelist.txt samplepairlist.txt hg38 $Ddir
# do not consider mappability
#$sing churros -p $ncore -w samplelist.txt samplepairlist.txt hg38 $Ddir

# consider mappability
#$sing churros -m -w samplelist.txt samplepairlist.txt hg38 $Ddir
