for R1 in $(grep -v '#' download.file.list.tsv | cut -f5)
do
	wget ${R1}
done

for R2 in $(grep -v '#' download.file.list.tsv | cut -f6)
do
	wget ${R2}
done

cat ERR10310247_1.fastq.gz ERR10310250_1.fastq.gz > ERR10310247-ERR10310250_1.fastq.gz
cat ERR10310247_2.fastq.gz ERR10310250_2.fastq.gz > ERR10310247-ERR10310250_2.fastq.gz
