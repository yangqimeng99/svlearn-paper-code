#!/bin/bash

ref_genome="../../01.data_download/cattle/reference_genomes/cattle_ARS-UCD2.0_GCF_002263795.3_REF.fasta"
sample_list="../../01.data_download/cattle/15cattle.list.tsv"
scripts="../../scripts"
species="cattle"

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

# For samples with coverage more than 30×, perform downsampling to 30x and re-mapping
cat ${species}.short-reads.coverage.tsv | while read sample coverage
do
	if awk "BEGIN {exit !($coverage > 30)}"; then
		rm -f ${sample}.dedup.sort.bam ${sample}.dedup.sort.bam.bai

		# downsampling to 30×
		target_coverage="30"
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
		
	else
		echo "Coverage is less than 30× for ${sample}"
	fi
done

# test sample other coverage
sample="Charolais"
coverage=$(grep -w "${sample}" ${species}.short-reads.coverage.tsv | cut -f2)

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