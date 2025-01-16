#!/bin/bash

sv_set="../../04.assembly-based_SVcalling/human/Human_Assembly-based_SV_Set.vcf"
sample_list="../../01.data_download/human/15human.list.tsv"
features_dir="../../05.feature_extraction/Human_Assembly-based_SV_Set"
scripts="../../scripts"

mkdir -p 01.true.gt
mkdir -p 30x.24feature.samples.data
mkdir -p 30x.18feature.samples.data

coverage="30"
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
		${features_dir}/${sample}_${coverage}.alignFeature/BreakPoint_ReadDepth_2Bam_feature.tsv \
		${features_dir}/${sample}_${coverage}.paraFeature/para_feature.tsv \
		> ${coverage}x.24feature.samples.data/${sample}.train.data.tsv

	cut -f 1-20  ${coverage}x.24feature.samples.data/${sample}.train.data.tsv \
		> ${coverage}x.18feature.samples.data/${sample}.train.data.tsv
done

# create multi-sample 24feature training data matrix
bash ${scripts}/prepare_Leave-one-out_data.sh \
	${sample_list} \
	${coverage}x.24feature.samples.data \
	${coverage}x.24feature.data

# create multi-sample 18feature training data matrix
mkdir -p 30x.18feature.data
cat ${sample_list} | while read sample
do
	cut -f 1-20 ${coverage}x.24feature.data/lack.${sample}.24fea.train.data.tsv \
		> ${coverage}x.18feature.data/lack.${sample}.18fea.train.data.tsv
done
