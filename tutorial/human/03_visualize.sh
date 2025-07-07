sing="singularity exec --bind /work,/work2,/work3 /work3/SingularityImages/churros.1.5.1.sif"

#sing="singularity exec churros.sif"

build=hg38
Ddir=Referencedata_$build

$sing churros_visualize samplepairlist.txt drompa+ $build $Ddir

# for no input control
#$sing churros_visualize --pdfdir pdf_noinpput samplepairlist.noinput.txt drompa+ $build $Ddir

$sing churros_visualize Churros_result/$build/macs/samplepairlist.txt drompa+.macspeak $build $Ddir
$sing churros_visualize -b 5000 -l 8000 -P "--scale_tag 100" samplepairlist.txt drompa+.bin5M $build $Ddir

# visualize -log10(p) distribution
$sing churros_visualize --pvalue -b 5000 -l 8000 samplepairlist.txt drompa+.pval.bin5M $build $Ddir

# Genome-wide view
$sing churros_visualize -G Churros_result/$build/macs/samplepairlist.txt drompa+ $build $Ddir
