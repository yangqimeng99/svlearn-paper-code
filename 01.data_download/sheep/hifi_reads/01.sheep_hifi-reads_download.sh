for hifi_reads in $(grep -v '#' download.file.list.tsv | cut -f5)
do
	wget ${hifi_reads}
done

fastq-dump --gzip SRR14226309
