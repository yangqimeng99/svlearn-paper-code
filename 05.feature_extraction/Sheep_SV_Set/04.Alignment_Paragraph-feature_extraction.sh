#!/bin/bash

ref_genome="../../01.data_download/sheep/reference_genomes/sheep_ARS-UI_Ramb_v2.0_GCA_016772045.1_REF.fasta"
alt_genome="./prepareAlt_output/alt.fasta"
sample_list="../../01.data_download/sheep/15sheep.list.tsv"
species="sheep"

ref_bam_dir="../../03.short-reads_mapping_downsample"
prepareAlt_output="./prepareAlt_output" # output in 01.generate_Alt-genome.sh

# 14 training samples
grep -v "^Romanov$" ${sample_list} | while read sample
do
	# svlearn Alignment feature
	svlearn alignFeature \
		--ref_fasta ${ref_genome} \
		--alt_fasta ${alt_genome} \
		--ref_sv_vcf ${prepareAlt_output}/ref_sorted_format_filtered_sv.vcf \
		--alt_sv_bed ${prepareAlt_output}/alt_sorted_format_filtered_sv.bed \
		--ref_bam ${ref_bam_dir}/${species}/${sample}.dedup.sort.bam \
		--alt_bam ./${sample}_alt.dedup.sort.bam \
		--threads 6 \
		--out ${sample}.alignFeature

	# svlearn Paragraph feature
	svlearn runParagraph \
		--ref_fasta ${ref_genome} \
		--alt_fasta ${alt_genome} \
		--ref_sv_vcf ${prepareAlt_output}/ref_sorted_format_filtered_sv.vcf \
		--alt_sv_vcf ${prepareAlt_output}/alt_sorted_format_filtered_sv.vcf \
		--ref_bam ${ref_bam_dir}/${species}/${sample}.dedup.sort.bam \
		--alt_bam ./${sample}_alt.dedup.sort.bam \
		--threads 6 \
		--out ${sample}.paraFeature
done

# test sample other coverage
sample="Romanov"
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

# Use the 30× features of the test sample for subsequent leave-one-out testing
ln -s ./Romanov_30.alignFeature ./Romanov.alignFeature
ln -s ./Romanov_30.paraFeature ./Romanov.paraFeature

