#!/bin/bash

sample_list="../../01.data_download/sheep/15sheep.list.tsv"
scripts="../../scripts"

mkdir -p log

# Perform 15 rounds of leave-one-out model selection
cat ${sample_list} | while read sample
do
	# 18feature
	python ${scripts}/choose_Model.py \
		--train_set 18feature.data/lack.${sample}.18fea.train.data.tsv \
		--threads 8 \
		--out lack.${sample}.18feature.choose_model \
		> log/${sample}.18feature.choose_model.log 2>&1

	# 24feature
	python ${scripts}/choose_Model.py \
		--train_set 24feature.data/lack.${sample}.24fea.train.data.tsv \
		--other_feature paragraph \
		--threads 8 \
		--out lack.${sample}.24feature.choose_model \
		> log/${sample}.24feature.choose_model.log 2>&1
done

# choose model results summary
species="sheep"
output_file="choose_model_results.tsv"

echo -e "species\ttest_sample\tfeature_num\tRandom Forest\tK-Nearest Neighbors\tNaive Bayes\tLogistic Regression\tGradient Boosting\tSVM" > "$output_file"

cat ${sample_list} | while read sample; do
    for number in 18 24; do
        input_file="log/${sample}.${number}feature.choose_model.log"
        Random_Forest=$(awk -F'= ' '/Random Forest: Average 10-Fold Accuracy/ {print $2}' "$input_file")
        K_Nearest_Neighbors=$(awk -F'= ' '/K-Nearest Neighbors: Average 10-Fold Accuracy/ {print $2}' "$input_file")
        Naive_Bayes=$(awk -F'= ' '/Naive Bayes: Average 10-Fold Accuracy/ {print $2}' "$input_file")
        Logistic_Regression=$(awk -F'= ' '/Logistic Regression: Average 10-Fold Accuracy/ {print $2}' "$input_file")
        Gradient_Boosting=$(awk -F'= ' '/Gradient Boosting: Average 10-Fold Accuracy/ {print $2}' "$input_file")
        SVM=$(awk -F'= ' '/SVM: Average 10-Fold Accuracy/ {print $2}' "$input_file")

        echo -e "${species}\t${sample}\t${number}\t${Random_Forest}\t${K_Nearest_Neighbors}\t${Naive_Bayes}\t${Logistic_Regression}\t${Gradient_Boosting}\t${SVM}" >> "$output_file"
    done
done

