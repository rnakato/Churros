sing="singularity exec --bind /work,/work2,/work3 /work3/SingularityImages/churros.1.4.0.sif"

build=hg38
Ddir_ref=Referencedata_${build}
gt=$Ddir_ref/genometable.txt
gene=$Ddir_ref/gtf_chrUCSC/chr.proteincoding.gene.refFlat

mkdir -p profile

# Use DROMPAplus to generate profile plots
# https://drompaplus.readthedocs.io/en/latest/content/drompa/Profile.html

pdir=Churros_result_Quickstart/hg38//bigWig/TotalReadNormalized/
s1="-i $pdir/H3K79me2_0_rep1.100.bw,$pdir/WCE_0_rep1.100.bw,H3K79me2_0_rep1"
s2="-i $pdir/H3K79me2_25_rep1.100.bw,$pdir/WCE_25_rep1.100.bw,H3K79me2_25_rep1"
s3="-i $pdir/H3K79me2_50_rep1.100.bw,$pdir/WCE_50_rep1.100.bw,H3K79me2_50_rep1"
s4="-i $pdir/H3K79me2_75_rep1.100.bw,$pdir/WCE_75_rep1.100.bw,H3K79me2_75_rep1"
s5="-i $pdir/H3K79me2_100_rep1.100.bw,$pdir/WCE_100_rep1.100.bw,H3K79me2_100_rep1"

$sing drompa+ PROFILE --gt $gt -g $gene $s1 $s2 $s3 $s4 $s5 -o profile/TotalReadNormalized-H3K79me2 --widthfromcenter 10000

pdir=Churros_result_Quickstart/hg38//bigWig/Spikein/
idir=Churros_result_Quickstart/hg38//bigWig/RawCount
s1="-i $pdir/H3K79me2_0_rep1.100.bw,$idir/WCE_0_rep1.100.bw,H3K79me2_0_rep1"
s2="-i $pdir/H3K79me2_25_rep1.100.bw,$idir/WCE_25_rep1.100.bw,H3K79me2_25_rep1"
s3="-i $pdir/H3K79me2_50_rep1.100.bw,$idir/WCE_50_rep1.100.bw,H3K79me2_50_rep1"
s4="-i $pdir/H3K79me2_75_rep1.100.bw,$idir/WCE_75_rep1.100.bw,H3K79me2_75_rep1"
s5="-i $pdir/H3K79me2_100_rep1.100.bw,$idir/WCE_100_rep1.100.bw,H3K79me2_100_rep1"

$sing drompa+ PROFILE --gt $gt -g $gene $s1 $s2 $s3 $s4 $s5 -o profile/Spikein-H3K79me --widthfromcenter 10000
