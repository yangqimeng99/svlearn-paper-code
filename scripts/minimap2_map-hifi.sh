ref_genome=$1
hifi_reads=$2
sample=$3

minimap2 -ax map-hifi \
	--MD \
	-L \
	--cs \
	-t 32 \
	-H \
	${ref_genome} \
	${hifi_reads} | \
samtools sort --threads 8 -o ${sample}.hifi.sort.bam

samtools index ${sample}.hifi.sort.bam
