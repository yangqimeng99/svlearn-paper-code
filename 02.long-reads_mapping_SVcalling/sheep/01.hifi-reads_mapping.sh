#!/bin/bash

ref_genome="../../01.data_download/sheep/reference_genomes/sheep_ARS-UI_Ramb_v2.0_GCA_016772045.1_REF.fasta"
sample_list="../../01.data_download/sheep/15sheep.list.tsv"
scripts="../../scripts"


while read sample
do
	echo ${sample}
	bash ${scripts}/minimap2_map-hifi.sh ${ref_genome} ../../01.data_download/sheep/hifi_reads/${sample}.fastq.gz ${sample}
	bash ${scripts}/mosdepth.sh ${sample}.hifi.sort.bam ${sample}
done < ${sample_list}

