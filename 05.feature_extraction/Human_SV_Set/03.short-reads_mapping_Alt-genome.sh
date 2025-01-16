#!/bin/bash

sample_list="../../01.data_download/human/15human.list.tsv"
alt_genome="./prepareAlt_output/alt.fasta"
scripts="../../scripts"
species="human"

# index for alt_genome
bwa-mem2.avx512bw index ${alt_genome}

while read sample
do
	for coverage in 30 20 10 5
	do
		bash ${scripts}/bwa_dedup.sh \
			../../03.short-reads_mapping_downsample/${species}/${sample}_${coverage}_R1.fq.gz \
			../../03.short-reads_mapping_downsample/${species}/${sample}_${coverage}_R2.fq.gz \
			${alt_genome} ${sample}_${coverage}_alt
	done
done < ${sample_list}
