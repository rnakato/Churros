sing="singularity exec --bind /work,/work2,/work3 /work3/SingularityImages/churros.1.4.0.sif"

#sing="singularity exec churros.sif"

build=hg38
Ddir=Referencedata_$build

# Total read normalization (in the pdf directory)
$sing churros_visualize samplepairlist.txt drompa+ $build $Ddir

# Spike-in normalization (in the pdf_spikein directory)
$sing churros_visualize --pdfdir pdf_spikein --chipdirectory Spikein --inputdirectory TotalReadNormalized \
                        samplepairlist.txt drompa+ $build $Ddir
