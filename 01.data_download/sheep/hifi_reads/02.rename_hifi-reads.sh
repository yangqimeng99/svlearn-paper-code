cat sheep_hifi-reads.list.tsv | while read sample raw_hifi
do
	mv ${raw_hifi} ${sample}.fastq.gz
done
