#!/bin/bash

ref_genome="../../01.data_download/human/reference_genomes/human_GRCh38_full_analysis_set_plus_decoy_hla_REF.fasta"
sample_list="../../01.data_download/human/15human.list.tsv"
scripts="../../scripts"
species="human"

# index for ref_genome
bwa-mem2.avx512bw index ${ref_genome}

# HG002: Mapping FASTQ to BAM
bash ${scripts}/bwa_dedup.sh \
	../../01.data_download/${species}/short_reads/HG002_R1.fq.gz \
	../../01.data_download/${species}/short_reads/HG002_R2.fq.gz \
	${ref_genome} \
	HG002

# Others 14 human samples: Download CRAM, already converted to BAM, and links created
for sample in $(tail -n +2 ${sample_list})
do
	ln -s ../../01.data_download/${species}/short_reads/${sample}.dedup.sort.bam .
	ln -s ../../01.data_download/${species}/short_reads/${sample}.dedup.sort.bam.bai .
done

# Calculate coverage from BAM using mosdepth
while read sample
do
	bash ${scripts}/mosdepth.sh ${sample}.dedup.sort.bam ${sample}
	coverage=$(grep -w "total" ${sample}.mosdepth.summary.txt | cut -f4)
	echo -e "${sample}\t${coverage}" >> ${species}.short-reads.coverage.tsv
done < ${sample_list}
