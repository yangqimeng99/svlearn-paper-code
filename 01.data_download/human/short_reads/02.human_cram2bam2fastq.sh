# HG002 short reads fastq
mv HG002_HiSeq30x_subsampled_R1.fastq.gz HG002_R1.fq.gz
mv HG002_HiSeq30x_subsampled_R2.fastq.gz HG002_R2.fq.gz

# other 14 human samples short reads cram2bam2fastq
for sample in $(tail -n +2 ../15human.list.tsv)
do
	samtools view -b -T ../reference_genomes/human_GRCh38_full_analysis_set_plus_decoy_hla_REF.fasta ${sample}.final.cram > ${sample}.dedup.sort.bam
	samtools index ${sample}.dedup.sort.bam
	java -jar /software/bin/bazam.jar -bam ${sample}.dedup.sort.bam -r1 ${sample}_R1.fq.gz -r2 ${sample}_R2.fq.gz
done
