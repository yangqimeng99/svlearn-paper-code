#!/bin/bash

ref_genome="../../01.data_download/cattle/reference_genomes/cattle_ARS-UCD2.0_GCF_002263795.3_REF.fasta"
sample_list="../../01.data_download/cattle/15cattle.list.tsv"
scripts="../../scripts"


while read sample
do
	echo ${sample}
	bash ${scripts}/minimap2_map-hifi.sh ${ref_genome} ../../01.data_download/cattle/hifi_reads/${sample}.fastq.gz ${sample}
	bash ${scripts}/mosdepth.sh ${sample}.hifi.sort.bam ${sample}
done < ${sample_list}

