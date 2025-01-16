#!/bin/bash

scripts="../../../scripts"

cat sheep_short-reads_raw-data.list.tsv | while read sample raw_fq_r1 raw_fq_r2
do
	bash ${scripts}/fastp.sh ${raw_fq_r1} ${raw_fq_r2} ${sample}
done
