#!/bin/bash

sample="HG002"
true_sv_set="../../02.long-reads_mapping_SVcalling/human/Human_SV_Set.vcf"

# cross-coverage benchmark
for model_coverage in 30 20 10 5
do
	mkdir -p ${model_coverage}x_model/benchmark_results
	for coverage in 30 20 10 5
	do
		for tool in svlearn_18 svlearn_24
		do
			svlearn benchmark -n1 ${sample} -b ${true_sv_set} \
				-n2 ${sample}_${coverage} -c ${sample}.${tool}.${covergae}.${model_coverage}x.vcf.gz \
				-o ${model_coverage}x_model/benchmark_results/${sample}.${tool}.${covergae}.${model_coverage}x.bench.tsv

			echo -e "tools  ${tool}\nmodel  ${model_coverage}x\ncoverage  ${coverage}" | \
				cat - ${model_coverage}x_model/benchmark_results/${sample}.${tool}.${covergae}.${model_coverage}x.bench.tsv | \
				awk -F' ' -v OFS="\t"  '{for(i=1;i<=NF;i++) s[i]=s[i] (NR>1?"\t":"") $i} END{for(i=1;i<=NF;i++) print s[i]}' > ${model_coverage}x_model/${sample}.${tool}.${covergae}.${model_coverage}x.bench.row.tsv
		done
	done
done

# merge benchmark results
csvtk concat -t *x_model/*.bench.row.tsv > HG002-cross-coverage_benchmark.tsv
