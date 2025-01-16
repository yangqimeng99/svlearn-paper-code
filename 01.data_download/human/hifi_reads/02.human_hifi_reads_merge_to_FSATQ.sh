# HG002 merge hifi reads fastq
files=$(grep -w 'HG002' download.file.list.tsv | cut -f2 | tr '\n' ' ')
cat ${files} | gzip > HG002.fastq.gz

# other 14 human samples hifi reads bam
for sample in $(tail -n +2 ../15human.list.tsv)
do
	files=$(grep -w "${sample}" download.file.list.tsv | cut -f2 | tr '\n' ' ')
	samtools merge -o ${sample}.bam ${files}
	pbindex --num-threads 8 ${sample}.bam
	bam2fastq -o ${sample}.fastq.gz --num-threads 8 ${sample}.bam
done
