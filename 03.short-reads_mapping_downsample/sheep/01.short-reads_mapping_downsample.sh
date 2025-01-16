#!/bin/bash

ref_genome="../../01.data_download/sheep/reference_genomes/sheep_ARS-UI_Ramb_v2.0_GCA_016772045.1_REF.fasta"
sample_list="../../01.data_download/sheep/15sheep.list.tsv"
scripts="../../scripts"
species="sheep"

# index for ref_genome
bwa-mem2.avx512bw index ${ref_genome}

# mapping
while read sample
do
	# short-reads mapping
	bash ${scripts}/bwa_dedup.sh \
		../../01.data_download/${species}/short_reads/${sample}_R1.fq.gz \
		../../01.data_download/${species}/short_reads/${sample}_R2.fq.gz \
		${ref_genome} ${sample}

	# Calculate coverage from BAM using mosdepth
	bash ${scripts}/mosdepth.sh ${sample}.dedup.sort.bam ${sample}
	coverage=$(grep -w "total" ${sample}.mosdepth.summary.txt | cut -f4)
	echo -e "${sample}\t${coverage}" >> ${species}.short-reads.coverage.tsv
done < ${sample_list}

# The original data for Romanov has a coverage close to 30×
# downsampling to 20x, 10x, 5x, and re-mapping
sample="Romanov"
coverage=$(grep -w "${sample}" ${species}.short-reads.coverage.tsv | cut -f2)

ln -s ../../01.data_download/${species}/short_reads/${sample}_R1.fq.gz ./${sample}_30_R1.fq.gz
ln -s ../../01.data_download/${species}/short_reads/${sample}_R2.fq.gz ./${sample}_30_R2.fq.gz

# ref bam
ln -s ./${sample}.dedup.sort.bam ./${sample}_30.dedup.sort.bam
ln -s ./${sample}.dedup.sort.bam.bai ./${sample}_30.dedup.sort.bam.bai

for target_coverage in 20 10 5
do
	bash ${scripts}/downsample_reads_from_fastq.sh \
		${coverage} \
		../../01.data_download/${species}/short_reads/${sample}_R1.fq.gz \
		../../01.data_download/${species}/short_reads/${sample}_R2.fq.gz \
		${target_coverage} \
		${sample} \
		4

	# short-reads mapping
	bash ${scripts}/bwa_dedup.sh \
		./${sample}_${target_coverage}_R1.fq.gz \
		./${sample}_${target_coverage}_R2.fq.gz \
		${ref_genome} \
		${sample}_${target_coverage}
done
