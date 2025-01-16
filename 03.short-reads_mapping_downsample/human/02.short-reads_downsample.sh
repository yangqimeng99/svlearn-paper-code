#!/bin/bash

sample_list="../../01.data_download/human/15human.list.tsv"
scripts="../../scripts"
species="human"

cat ${species}.short-reads.coverage.tsv | while read sample coverage
do
	# ~30× FASTQ links created
	ln -s ../../01.data_download/${species}/short_reads/${sample}_R1.fq.gz ./${sample}_30_R1.fq.gz
	ln -s ../../01.data_download/${species}/short_reads/${sample}_R2.fq.gz ./${sample}_30_R2.fq.gz
	
	# downsample coverage to 20×, 10× and 5×
	for target_coverage in 20 10 5
	do
		bash ${scripts}/downsample_reads_from_fastq.sh \
			${coverage} \
			../../01.data_download/${species}/short_reads/${sample}_R1.fq.gz \
			../../01.data_download/${species}/short_reads/${sample}_R2.fq.gz \
			${target_coverage} \
			${sample} \
			4
	done
done
