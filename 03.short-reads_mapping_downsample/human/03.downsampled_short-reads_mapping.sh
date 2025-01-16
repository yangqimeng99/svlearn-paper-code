#!/bin/bash

ref_genome="../../01.data_download/human/reference_genomes/human_GRCh38_full_analysis_set_plus_decoy_hla_REF.fasta"
sample_list="../../01.data_download/human/15human.list.tsv"
scripts="../../scripts"

while read sample
do
	# ~30× BAM
	ln -s ./${sample}.dedup.sort.bam ./${sample}_30.dedup.sort.bam
	ln -s ./${sample}.dedup.sort.bam.bai ./${sample}_30.dedup.sort.bam.bai

	# mapping reads at 20×, 10× and 5×
	for coverage in 20 10 5
	do
		bash ${scripts}/bwa_dedup.sh \
			./${sample}_${coverage}_R1.fq.gz \
			./${sample}_${coverage}_R2.fq.gz \
			${ref_genome} \
			${sample}_${coverage}
	done
done < ${sample_list}
