sing="singularity exec --bind /work,/work2 /work/SingularityImages/churros.0.2.0.sif"
build=hg38
Ddir=Ensembl-GRCh38

$sing churros_visualize --mpbl samplepairlist.txt drompa+ $build $Ddir
$sing churros_visualize --mpbl -m macs/samplepairlist.txt drompa+.macspeak $build $Ddir
$sing churros_visualize --mpbl -b 5000 -l 8000 -P "--scale_tag 100" samplepairlist.txt drompa+.bin5M $build $Ddir

# visualize -log10(p) distribution
$sing churros_visualize --mpbl --pvalue -b 5000 -l 8000 samplepairlist.txt drompa+.pval.bin5M $build $Ddir

# Genome-wide view
$sing churros_visualize --mpbl -G Churros_result/macs/samplepairlist.txt drompa+ $build $Ddir
