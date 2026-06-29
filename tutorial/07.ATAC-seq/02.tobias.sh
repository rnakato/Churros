sing="singularity exec --bind /work,/work2,/work3 /work3/SingularityImages/churros.2.0.0.sif"

build=hg38
Ddir=Referencedata_$build
genome=$Ddir/genome.fa

samplelist=samplelist.txt
chdir=Churros_result/$build/
odir=$chdir/tobias

while read -r LINE || [ -n "$LINE" ]; do
    LINE=($LINE)
    label=${LINE[0]}

    bam=$chdir/bam/$label.sort.bam
    peak=$chdir/macs/${label}_peaks.narrowPeak
    echo -e "\nTOBIAS: $bam and $peak.."
    $sing churros_tobias.sh -o $odir $bam $peak $genome $label
done < $samplelist
