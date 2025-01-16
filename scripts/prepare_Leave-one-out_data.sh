#!/bin/bash

sample_list_file=$1
data_dir=$2
output_dir=$3

mkdir -p ${output_dir}

for sample in $(cat ${sample_list_file})
do
  files=$(grep -v "$sample" ${sample_list_file} | awk -v dir="${data_dir}" '{print dir"/"$1".train.data.tsv"}' | tr "\n" " ")

  output_file="$output_dir/lack.${sample}.24fea.train.data.tsv"
  
  csvtk concat $files > ${output_file}
  
  if [ $? -ne 0 ]; then
    echo "Error: Failed to process $sample."
  else
    echo "Processed $sample successfully. Output saved to $output_file."
  fi
done
