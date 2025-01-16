#!/bin/bash

sample_list="../../../01.data_download/human/15human.list.tsv"
features_dir="../../../05.feature_extraction/Human_SV_Set/"
scripts="../../../scripts"

awk '$8==0||$1=="sv_id"' ${features_dir}/sv_feature.tsv | cut -f1 > Human_SV_Set.nonTR.list.txt
awk '$8!=0||$1=="sv_id"' ${features_dir}/sv_feature.tsv | cut -f1 > Human_SV_Set.TR.list.txt

sv_nonTR_list="Human_SV_Set.nonTR.list.txt"
sv_TR_list="Human_SV_Set.TR.list.txt"

# cumulative feature ablation order:
# SD_content, SD_class, Repeat_content, Type, Repeat_class, TR_content, Mappability, GC_content, Length, TR_length
coverage="30"
while read sample
do
	# model training and testing
	python ${scripts}/cumulative_feature_ablation.py \
		--train_set ${coverage}x.24feature.data/lack.${sample}.24fea.train.data.tsv \
		--val_set ${coverage}x.24feature.samples.data/${sample}.train.data.tsv \
		--other_feature paragraph \
		--train_model RandomForest \
		--threads 32 \
		--out ${sample}.svfeature_ablation \
		--ablation_study

	# benchmark
	mkdir -p ${sample}/01.val.data ${sample}/02.bench
	while read -r No feature feature_path
	do
		cp ${sample}.svfeature_ablation/${feature_path}/val_set_pred.tsv ${sample}/01.val.data/${No}.${feature}.all.pred.tsv
		csvtk join -t -f 'sv_id;sv_id' \
			${sv_nonTR_list} \
			${sample}.svfeature_ablation/${feature_path}/val_set_pred.tsv \
			> ${sample}/01.val.data/${No}.${feature}.nonTR.pred.tsv

		csvtk join -t -f 'sv_id;sv_id' \
			${sv_TR_list} \
			${sample}.svfeature_ablation/${feature_path}/val_set_pred.tsv \
			> ${sample}/01.val.data/${No}.${feature}.TR.pred.tsv

		for sv_type in all nonTR TR
		do
			python ${scripts}/benchmark_cumulative_feature_ablation.py \
				-i ${sample}/01.val.data/${No}.${feature}.${sv_type}.pred.tsv \
				-o ${sample}/02.bench/${No}.${feature}.${sv_type}.pred.tsv 

			echo -e "sample  ${sample}\nNo  ${No}\ntype  ${sv_type}\nfeature  ${feature}" | \
				cat - ${sample}/02.bench/${No}.${feature}.${sv_type}.pred.tsv | \
				awk -F' ' -v OFS="\t"  '{for(i=1;i<=NF;i++) s[i]=s[i] (NR>1?"\t":"") $i} END{for(i=1;i<=NF;i++) print s[i]}' \
				> ${sample}/${No}.${feature}.${sv_type}.bench.row.tsv
		done
	done < Cumulative_Feature_Ablation_Analysis.list.txt
done < "${sample_list}"

csvtk concat -t */*.bench.row.tsv > Cumulative_Feature_Ablation_Analysis.becnmark.tsv
