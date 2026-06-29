library(methylKit)

files <- list("Bismarkdir/SRR1609039_trimmed_bismark_bt2.sorted.bam", "Bismarkdir/SRR1609040_trimmed_bismark_bt2.sorted.bam")
sample.id <- list("SRR1609039", "SRR1609040")

myobj=processBismarkAln(location = files,　
				   sample.id=sample.id,
				   assembly="hg38",
				   read.context="CpG",
				   mincov = 4,
				   treatment=c(0,1),
				   save.folder=getwd()
				   )

if (!dir.exists("methylKit")){
	dir.create("methylKit")	
}

pdf("methylKit/methyl_stats.pdf")
getMethylationStats(myobj[[1]],plot=TRUE,both.strands=FALSE)
dev.off()

pdf("methylKit/coverage_stats.pdf")
getCoverageStats(myobj[[2]],plot=TRUE,both.strands=FALSE)
dev.off()

meth=unite(myobj, destrand=FALSE)

pdf("methylKit/getCorrelation.pdf")
getCorrelation(meth,plot=TRUE)
dev.off()

pdf("methylKit/clusterSamples.pdf")
clusterSamples(meth, dist="correlation", method="ward", plot=TRUE)
dev.off()

pdf("methylKit/clusterSamples.pdf")
PCASamples(meth, screeplot=TRUE)
PCASamples(meth)
dev.off()

myDiff=calculateDiffMeth(meth, mc.cores=2)
