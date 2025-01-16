#!/bin/bash

sample_list="../../01.data_download/human/15human.list.tsv"
scripts="../../scripts"

mkdir -p log 
mkdir -p RF-models_24feature RF-models_18feature

# Perform 15 rounds of leave-one-out model training and testing on the 30x coverage training dataset
# In each round, the model is trained using all samples except one and tested on the excluded sample
coverage="30"
cat ${sample_list} | while read sample
do
	# 18feature
	svlearn trainingModel \
		--train_set ${coverage}x.18feature.data/lack.${sample}.18fea.train.data.tsv \
		--val_set ${coverage}x.18feature.samples.data/${sample}.train.data.tsv \
		--train_model RandomForest \
		--threads 32 \
		--out ./RF-models_18feature/lack.${sample}.${coverage}x.RF-model \
		> log/lack.${sample}.${coverage}x.18feature.training_model.log 2>&1

	# 24feature
	svlearn trainingModel \
		--train_set ${coverage}x.24feature.data/lack.${sample}.24fea.train.data.tsv \
		--val_set ${coverage}x.24feature.samples.data/${sample}.train.data.tsv \
		--other_feature paragraph \
		--train_model RandomForest \
		--threads 32 \
		--out ./RF-models_24feature/lack.${sample}.${coverage}x.RF-model \
		> log/lack.${sample}.${coverage}x.24feature.training_model.log 2>&1
done