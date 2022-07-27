sing="singularity exec --bind /work,/work2 /work/SingularityImages/churros.0.1.0.sif"
Ddir=/work/Database/Database_fromDocker/Ensembl-GRCh38/

$sing churros samplelist.txt samplepairlist.txt hg38 $Ddir
