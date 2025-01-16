#!/bin/bash

sample_list="../../01.data_download/human/15human.list.tsv"

for num in 18 24; do
    # f1 
    echo -e "sample\t${num}feature_F1" > "${num}_f1.txt"
    echo -e "sample\t${num}feature_wGC" > "${num}_wgc.txt"
    while read sample; do
            grep -w "${sample}" Read-based_Assembly-based_leave-one-out_benchmark.result.tsv \
            | awk -v num="$num" '$3==num' \
            | cut -f10 \
            | awk -v sample="$sample" 'NR==1 {a=$1} NR==2 {b=$1} END {diff = a - b; if (diff < 0) diff = -diff; print sample "\t" diff >> "'"${num}_f1.txt"'"}'
    done < "$sample_list"

    #  wGC 
    while read sample; do
	    grep -w "${sample}" Read-based_Assembly-based_leave-one-out_benchmark.result.tsv \
            | awk -v num="$num" '$3==num' \
            | cut -f17 \
            | awk -v sample="$sample" 'NR==1 {a=$1} NR==2 {b=$1} END {diff = a - b; if (diff < 0) diff = -diff; print sample "\t" diff >> "'"${num}_wgc.txt"'"}'
    done < "$sample_list"
done

csvtk join -t -f sample *.txt > Read-based_Assembly-based_leave-one-out_benchmark_difference.tsv
rm *.txt

