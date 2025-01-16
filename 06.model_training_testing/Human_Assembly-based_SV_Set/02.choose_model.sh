#!/bin/bash

sample_list="../../01.data_download/human/15human.list.tsv"
scripts="../../scripts"

mkdir -p log

# Perform 15 rounds of leave-one-out model selection on the 30x coverage training dataset.
coverage="30"
cat ${sample_list} | while read sample
do
	# 18feature
	python ${scripts}/choose_Model.py \
		--train_set ${coverage}x.18feature.data/lack.${sample}.18fea.train.data.tsv \
		--threads 8 \
		--out lack.${sample}.${coverage}x.18feature.choose_model \
		> log/${sample}.${coverage}x.18feature.choose_model.log 2>&1

	# 24feature
	python ${scripts}/choose_Model.py \
		--train_set ${coverage}x.24feature.data/lack.${sample}.24fea.train.data.tsv \
		--other_feature paragraph \
		--threads 8 \
		--out lack.${sample}.${coverage}x.24feature.choose_model \
		> log/${sample}.${coverage}x.24feature.choose_model.log 2>&1
done