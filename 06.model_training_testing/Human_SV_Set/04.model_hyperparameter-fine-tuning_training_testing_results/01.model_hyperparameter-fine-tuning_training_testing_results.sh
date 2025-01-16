#!/bin/bash

species="human"
sample_list="../../../01.data_download/human/15human.list.tsv"

for num in 18 24
do
	cat ${sample_list} | while read sample
        do
		# extract wGC & F1
		awk '
                {
                    for (i=1; i<=NF; i++)  {
                        a[NR,i] = $i
                    }
                    max_col = NF > max_col ? NF : max_col
                    max_row = NR
                }
                END {
                    for (i=1; i<=max_col; i++) {
                        for (j=1; j<=max_row; j++) {
                            printf("%s%s", a[j,i], (j==max_row ? ORS : OFS))
                        }
                    }
                }' OFS="\t" ../RF-models_${num}feature/lack.${sample}.${coverage}x.RF-model/val_result.txt > transposed_val_result.txt
		
		awk -v species="$species" -v num="$num" -v sample="$sample" '
		BEGIN { FS=OFS="\t" }
		NR==1 { print "species", "num", "test_sample", $0 }  
		NR>1 { print species, num, sample, $0 }         
		' transposed_val_result.txt > ${sample}_${num}fea_final_val_result.tsv
		rm transposed_val_result.txt
		
		# extract Best parameters & accuracy
		awk -v species="$species" -v num="$num" -v sample="$sample" '
		BEGIN {
		    FS=": "; OFS="\t";
		    print "species", "num", "test_sample", "Best parameters", "accuracy"  
		}
		{
		    if ($0 ~ /Best parameters:/) {
			best_params = substr($0, index($0, "Best parameters:") + length("Best parameters:") + 1)   
		    }
		    if ($0 ~ /The validation data accuracy is:/) {
			accuracy = $2      
		    }
		}
		END {
		    print species, num, sample, best_params, accuracy
		}
		' ../log/lack.${sample}.${coverage}x.${num}feature.training_model.log > ${sample}_${num}fea_best_parameters.tsv
	done
done

csvtk concat -t ./*best_parameters.tsv > leave-one-out_best_parameters.tsv
csvtk concat -t ./*final_val_result.tsv > leave-one-out_testing_result.tsv




