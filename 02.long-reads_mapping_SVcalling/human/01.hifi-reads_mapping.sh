#!/bin/bash

ref_genome="../../01.data_download/human/reference_genomes/human_GRCh38_full_analysis_set_plus_decoy_hla_REF.fasta"
sample_list="../../01.data_download/human/15human.list.tsv"
scripts="../../scripts"


while read sample
do
	echo ${sample}
	bash ${scripts}/minimap2_map-hifi.sh ${ref_genome} ../../01.data_download/human/hifi_reads/${sample}.fastq.gz ${sample}
	bash ${scripts}/mosdepth.sh ${sample}.hifi.sort.bam ${sample}
done < ${sample_list}

