#!/bin/bash

coverage=$1
inputFastqR1=$2
inputFastqR2=$3
targetDepth=$4
sample=$5
threads=$6

echo "The coverage of ${sample} short-reads is ${coverage}x"
proportion=$(awk -v target=$targetDepth -v c=$coverage 'BEGIN { printf "%.3f", target/c }')
echo "The proportion of downsample to ${targetDepth} is ${proportion}"

seqkit sample \
	--proportion ${proportion} \
	--rand-seed 12 \
	--threads ${threads} \
	--out-file ${sample}_${targetDepth}_R1.fq.gz \
	${inputFastqR1}

seqkit sample \
        --proportion ${proportion} \
        --rand-seed 12 \
        --threads ${threads} \
	--out-file ${sample}_${targetDepth}_R2.fq.gz \
	${inputFastqR2}

echo "ALL DONE!"
