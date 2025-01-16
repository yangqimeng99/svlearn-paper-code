#!/bin/bash

sample_list="../../01.data_download/human/15human.list.tsv"

mkdir -p 18feature.Assembly-based 18feature.Read-based 24feature.Assembly-based 24feature.Read-based

coverage="30"
while read sample
do
	for features in 18 24
	do
		# Read-based: Human_SV_Set 30x coverage
		read_based="../Human_SV_Set/RF-models_${features}feature/lack.${sample}.${coverage}x.RF-model"
		echo -e "sample  ${sample}\nDetection_Method  Read-based\nFeatures  ${features}" | \
			cat - ${read_based}/val_result.txt | \
			awk -F' ' -v OFS="\t"  '{for(i=1;i<=NF;i++) s[i]=s[i] (NR>1?"\t":"") $i} END{for(i=1;i<=NF;i++) print s[i]}' > ${features}feature.Read-based/${sample}.val.bench.row.tsv
		
		# Assembly-based
		assembly_based="./RF-models_${features}feature/lack.${sample}.${coverage}x.RF-model"
		echo -e "sample  ${sample}\nDetection_Method  Assembly-based\nFeatures  ${features}" | \
			cat - ${assembly_based}/val_result.txt | \
			awk -F' ' -v OFS="\t"  '{for(i=1;i<=NF;i++) s[i]=s[i] (NR>1?"\t":"") $i} END{for(i=1;i<=NF;i++) print s[i]}' > ${features}feature.Assembly-based/${sample}.val.bench.row.tsv
	done
done < ${sample_list}

csvtk concat -t *-based/*.val.bench.row.tsv > Read-based_Assembly-based_leave-one-out_benchmark.result.tsv
