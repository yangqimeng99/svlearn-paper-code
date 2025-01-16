#!/bin/bash

sv_set="../../02.long-reads_mapping_SVcalling/human/Human_SV_Set.vcf"
sample_list="../../01.data_download/human/15human.list.tsv"
features_dir="../../05.feature_extraction/Human_SV_Set/"
scripts="../../scripts"

mkdir -p 01.true.gt
mkdir -p 30x.24feature.samples.data 20x.24feature.samples.data 10x.24feature.samples.data 5x.24feature.samples.data
mkdir -p 30x.18feature.samples.data 20x.18feature.samples.data 10x.18feature.samples.data 5x.18feature.samples.data

cat ${sample_list} | while read sample
do
	# True genotype label
	bcftools view -s ${sample} ${sv_set} | \
		bcftools query -f '%ID\t[%GT\n]' | \
		csvtk add-header -t -n sv_id,GT_true > 01.true.gt/${sample}.true.gt.tsv

	for coverage in 30 20 10 5
	do
		# Merge genotype labels with feature data based on 'sv_id'
		csvtk join -t -f 'sv_id' \
			01.true.gt/${sample}.true.gt.tsv \
			${features_dir}/sv_feature.tsv \
			${features_dir}/${sample}_${coverage}.alignFeature/BreakPoint_ReadDepth_2Bam_feature.tsv \
			${features_dir}/${sample}_${coverage}.paraFeature/para_feature.tsv \
			> ${coverage}x.24feature.samples.data/${sample}.train.data.tsv

		cut -f 1-20  ${coverage}x.24feature.samples.data/${sample}.train.data.tsv \
			> ${coverage}x.18feature.samples.data/${sample}.train.data.tsv
	done
done

# create multi-sample 24feature training data matrix
for coverage in 30 20 10 5
do
	bash ${scripts}/prepare_Leave-one-out_data.sh \
		${sample_list} \
		${coverage}x.24feature.samples.data \
		${coverage}x.24feature.data
done

# create multi-sample 18feature training data matrix
mkdir -p 30x.18feature.data 20x.18feature.data 10x.18feature.data 5x.18feature.data
cat ${sample_list} | while read sample
do
	for coverage in 30 20 10 5
	do
		cut -f 1-20 ${coverage}x.24feature.data/lack.${sample}.24fea.train.data.tsv \
			> ${coverage}x.18feature.data/lack.${sample}.18fea.train.data.tsv
	done
done
