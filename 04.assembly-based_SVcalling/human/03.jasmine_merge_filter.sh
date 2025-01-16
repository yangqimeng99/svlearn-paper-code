#!/bin/bash

ref_genome="../../01.data_download/human/reference_genomes/human_GRCh38_full_analysis_set_plus_decoy_hla_REF.fasta"
sample_list="../../01.data_download/human/15human.list.tsv"

# Filter SVs from PAV results
cat ${sample_list} | while read sample
do
	bcftools view \
		-i '((INFO/SVTYPE == "INS" && INFO/SVLEN >= 50) || (INFO/SVTYPE == "DEL" && INFO/SVLEN <= -50))' \
		pav_${sample}.vcf.gz > pav_${sample}.indel.vcf
done

ls ./pav_*.indel.vcf > pav_vcf_list.tsv

# Jasmine merge SVs from different samples
conda activate jasminesv
jasmine \
	genome_file=../../01.data_download/human/reference_genomes/GRCh38.no_alt.fa \
	file_list=pav_vcf_list.tsv \
	spec_len=50 \
	max_dist_linear=0.5 \
	min_dist=100 \
	threads=36 \
	out_file=PAV_SV_merge.vcf
	--ignore_strand \
	--output_genotypes \
	--allow_intrasample \
	--default_zero_genotype

# filter SV set
bcftools annotate \
	--header-lines <(echo '##INFO=<ID=STRANDS,Number=1,Type=String,Description="Indicates the read strand support for the variant">') PAV_SV_merge.vcf | \
	bcftools view -i 'SVLEN>=50 || SVLEN<=-50' | \
	grep -v -F -e '.|1' -e '1|.' | \
	bcftools view -i 'SVLEN>-1000000&&SVLEN<1000000' | \
	bcftools view -i 'CHROM~"^chr[0-9XY]*$"' > PAV_SV_merge_filtered.vcf

# Convert genotype format
bcftools +setGT PAV_SV_merge_filtered.vcf -- -t a -n u > PAV_SV_merge_filtered_format.vcf

# Rename the samples name that changed because of jasmine
bcftools reheader \
	-s jasmine_result_rename_samples.list.tsv \
	PAV_SV_merge_filtered_format.vcf > PAV_SV_merge_filtered_format_rename.vcf

# 300bp uniq SV
svlearn prepareAlt \
	--ref_fasta ${ref_genome} \
	--ref_sv_vcf PAV_SV_merge_filtered_format_rename.vcf \
	--min-distance 300 \
	--out Human_Assembly-based_SV_Set_alt

bcftools query -f '%ID\n' \
	Human_Assembly-based_SV_Set_alt/ref_sorted_format_filtered_sv.vcf \
	> Human_Assembly-based_SV_Set.ID.list.tsv

bcftools view -i "ID=@Human_Assembly-based_SV_Set.ID.list.tsv" \
	PAV_SV_merge_filtered_format_rename.vcf \
	> Human_Assembly-based_SV_Set.vcf
