#!/bin/bash

sample_list="../../01.data_download/sheep/15sheep.list.tsv"
scripts="../../scripts"

mkdir -p log
mkdir -p RF-models_24feature RF-models_18feature

# Perform 15 rounds of leave-one-out model training and testing
# In each round, the model is trained using all samples except one and tested on the excluded sample
cat ${sample_list} | while read sample
do
	# 18feature
	svlearn trainingModel \
		--train_set 18feature.data/lack.${sample}.18fea.train.data.tsv \
		--val_set 18feature.samples.data/${sample}.train.data.tsv \
		--train_model RandomForest \
		--threads 32 \
		--out ./RF-models_18feature/lack.${sample}.RF-model \
		> log/lack.${sample}.18feature.training_model.log 2>&1

	# 24feature
	svlearn trainingModel \
		--train_set 24feature.data/lack.${sample}.24fea.train.data.tsv \
		--val_set 24feature.samples.data/${sample}.train.data.tsv \
		--other_feature paragraph \
		--train_model RandomForest \
		--threads 32 \
		--out ./RF-models_24feature/lack.${sample}.RF-model \
		> log/lack.${sample}.24feature.training_model.log 2>&1
done
