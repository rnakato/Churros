echo -n "download peaks.tar.gz.."
wget -q https://x.gd/Oi5Yc -O peaks.tar.gz
echo "done."
tar zxvf peaks.tar.gz

# Create an example peak list for the reference
cp peakdir/Rad21_ENCSR000BTQ_rep1_peaks.narrowPeak ./reference.bed
