#!/bin/bash

sample_list="../../../01.data_download/cattle/15cattle.list.tsv"
scripts="../../../scripts"
species="Cattle"

while read sample
do
	python ${scripts}/feature_importance.py \
		--model ../RF-models_18feature/lack.${sample}.RF-model/RandomForest_model.joblib \
		--train_set ../18feature.data/lack.${sample}.18fea.train.data.tsv \
	       	--out ${species}_${sample}_18feature.tsv \
		--model_name ${species}_${sample}_18feature

	python ${scripts}/feature_importance.py \
		--model ../RF-models_24feature/lack.${sample}.RF-model/RandomForest_model.joblib \
		--train_set ../24feature.data/lack.${sample}.24fea.train.data.tsv \
		--out ${species}_${sample}_24feature.tsv \
		--other_feature \
		--model_name ${species}_${sample}_24feature
done

csvtk concat -t ./*.tsv | bash ${scripts}/feature_convert.sh > ${species}_feature_importance.tsv
