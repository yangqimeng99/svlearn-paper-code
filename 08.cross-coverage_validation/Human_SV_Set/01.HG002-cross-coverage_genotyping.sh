#!/bin/bash

prepareAlt_output="../../05.feature_extraction/Human_SV_Set/prepareAlt_output"
svlearn_feature_dir="../../05.feature_extraction/Human_SV_Set"
species="human"
sample="HG002"
models_dir="../../06.model_training_test/Human_SV_Set/"

# cross-coverage genotyping
for coverage in 30 20 10 5
do
	for model_coverage in 30 20 10 5
	do
		# svlearn 18 feature
		svlearn genotype \
			-v ${prepareAlt_output}/ref_sorted_format_filtered_sv.vcf \
			--model ${models_dir}/RF-models_18feature/lack.HG002.${model_coverage}x.RF-model/RandomForest_model.joblib \
			-s ${svlearn_feature_dir}/sv_feature.tsv \
			-a ${svlearn_feature_dir}/${sample}_${coverage}.alignFeature/BreakPoint_ReadDepth_2Bam_feature.tsv \
			-n ${sample}_${coverage} \
			-o ${sample}_${coverage}.pred.all.18fea.${model_coverage}x.vcf

		 bgzip -c ${sample}_${coverage}.pred.all.18fea.${model_coverage}x.vcf > ${sample}.svlearn_18.${covergae}.${model_coverage}x.vcf.gz

		 # svlearn 24 feature
		 svlearn genotype \
			-v ${prepareAlt_output}/ref_sorted_format_filtered_sv.vcf \
			--model ${models_dir}/RF-models_24feature/lack.HG002.${model_coverage}x.RF-model/RandomForest_model.joblib \
			-s ${svlearn_feature_dir}/sv_feature.tsv \
			-a ${svlearn_feature_dir}/${sample}_${coverage}.alignFeature/BreakPoint_ReadDepth_2Bam_feature.tsv \
			-p ${svlearn_feature_dir}/${sample}_${coverage}.paraFeature/para_feature.tsv \
			-n ${sample}_${coverage} \
			-o ${sample}_${coverage}.pred.all.24fea.${model_coverage}x.vcf

		 bgzip -c ${sample}_${coverage}.pred.all.24fea.${model_coverage}x.vcf > ${sample}.svlearn_24.${covergae}.${model_coverage}x.vcf.gz
	done
done


