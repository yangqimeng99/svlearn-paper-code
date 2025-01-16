#!/bin/bash

sample_list="../../01.data_download/cattle/15cattle.list.tsv"
alt_genome="./prepareAlt_output/alt.fasta"
scripts="../../scripts"
species="cattle"

# index for alt_genome
bwa-mem2.avx512bw index ${alt_genome}

# 14 training samples
grep -v "^Charolais$" ${sample_list} | while read sample
do
	bash ${scripts}/bwa_dedup.sh \
		../../03.short-reads_mapping_downsample/${species}/${sample}_R1.fq.gz \
		../../03.short-reads_mapping_downsample/${species}/${sample}_R2.fq.gz \
		${alt_genome} \
		${sample}_alt
done


# test sample other coverage
sample="Charolais"
for coverage in 30 20 10 5
do
	bash ${scripts}/bwa_dedup.sh \
		../../03.short-reads_mapping_downsample/${species}/${sample}_${coverage}_R1.fq.gz \
		../../03.short-reads_mapping_downsample/${species}/${sample}_${coverage}_R2.fq.gz \
		${alt_genome} \
		${sample}_${coverage}_alt
done
