#!/bin/bash

ref_genome="../../01.data_download/human/reference_genomes/human_GRCh38_full_analysis_set_plus_decoy_hla_REF.fasta"
alt_genome="./prepareAlt_output/alt.fasta"
sample_list="../../01.data_download/human/15human.list.tsv"
scripts="../../scripts"
species="human"

ref_bam_dir="../../03.short-reads_mapping_downsample"
prepareAlt_output="./prepareAlt_output" # output in 01.generate_Alt-genome.sh

while read sample
do
	for coverage in 30 20 10 5
	do
		# svlearn Alignment feature
		svlearn alignFeature \
			--ref_fasta ${ref_genome} \
			--alt_fasta ${alt_genome} \
			--ref_sv_vcf ${prepareAlt_output}/ref_sorted_format_filtered_sv.vcf \
			--alt_sv_bed ${prepareAlt_output}/alt_sorted_format_filtered_sv.bed \
			--ref_bam ${ref_bam_dir}/${species}/${sample}_${coverage}.dedup.sort.bam \
			--alt_bam ./${sample}_${coverage}_alt.dedup.sort.bam \
			--threads 6 \
			--out ${sample}_${coverage}.alignFeature
		
		# svlearn Paragraph feature
		svlearn runParagraph \
			--ref_fasta ${ref_genome} \
			--alt_fasta ${alt_genome} \
			--ref_sv_vcf ${prepareAlt_output}/ref_sorted_format_filtered_sv.vcf \
			--alt_sv_vcf ${prepareAlt_output}/alt_sorted_format_filtered_sv.vcf \
			--ref_bam ${ref_bam_dir}/${species}/${sample}_${coverage}.dedup.sort.bam \
			--alt_bam ./${sample}_${coverage}_alt.dedup.sort.bam \
			--threads 6 \
			--out ${sample}_${coverage}.paraFeature
	done
done < ${sample_list}
