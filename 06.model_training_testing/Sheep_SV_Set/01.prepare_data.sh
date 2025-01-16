#!/bin/bash

sv_set="../../02.long-reads_mapping_SVcalling/sheep/Sheep_SV_Set.vcf"
sample_list="../../01.data_download/sheep/15sheep.list.tsv"
features_dir="../../05.feature_extraction/Sheep_SV_Set"
scripts="../../scripts"

mkdir -p 01.true.gt
mkdir -p 24feature.samples.data
mkdir -p 18feature.samples.data

cat ${sample_list} | while read sample
do
	# True genotype label
	bcftools view -s ${sample} ${sv_set} | \
		bcftools query -f '%ID\t[%GT\n]' | \
		csvtk add-header -t -n sv_id,GT_true > 01.true.gt/${sample}.true.gt.tsv

	# Merge genotype labels with feature data based on 'sv_id'
	csvtk join -t -f 'sv_id' \
		01.true.gt/${sample}.true.gt.tsv \
		${features_dir}/sv_feature.tsv \
		${features_dir}/${sample}.alignFeature/BreakPoint_ReadDepth_2Bam_feature.tsv \
		${features_dir}/${sample}.paraFeature/para_feature.tsv \
		> 24feature.samples.data/${sample}.train.data.tsv

	cut -f 1-20  24feature.samples.data/${sample}.train.data.tsv \
		> 18feature.samples.data/${sample}.train.data.tsv
done

# create multi-sample 24feature training data matrix
bash ${scripts}/prepare_Leave-one-out_data.sh \
	${sample_list} \
	24feature.samples.data \
	24feature.data

# create multi-sample 18feature training data matrix
mkdir -p 18feature.data
cat ${sample_list} | while read sample
do
	cut -f 1-20 24feature.data/lack.${sample}.24fea.train.data.tsv \
		> 18feature.data/lack.${sample}.18fea.train.data.tsv
done
