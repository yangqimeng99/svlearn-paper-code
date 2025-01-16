#!/bin/bash

svlearn_feature_dir="../05.feature_extraction"
models_dir="../06.model_training_test"

# Models for human, cattle, and sheep
human_model="${models_dir}/Human_SV_Set/RF-models_24feature/lack.HG002.30x.RF-model/RandomForest_model.joblib"
cattle_model="${models_dir}/Cattle_SV_Set/RF-models_24feature/lack.Charolais.RF-model/RandomForest_model.joblib"
sheep_model="${models_dir}/Sheep_SV_Set/RF-models_24feature/lack.Romanov.RF-model/RandomForest_model.joblib"

samples=("HG002" "Charolais" "Romanov")
samples_species=("human" "cattle" "sheep")

models=("${human_model}" "${cattle_model}" "${sheep_model}")
model_names=("human" "cattle" "sheep")

# each 24feature model (human, cattle, sheep)
for model_idx in ${!models[@]}; do
    model=${models[$model_idx]}
    model_name=${model_names[$model_idx]}

    # each sample (HG002, Charolais, Romanov)
    for sample_idx in ${!samples[@]}; do
	sample=${samples[$sample_idx]}
	sample_species=${samples_species[$sample_idx]}
	true_sv_set="../02.long-reads_mapping_SVcalling/${sample_species}/${sample_species^}_SV_Set.vcf"

        for coverage in 30 20 10 5; do
            feature_dir="${svlearn_feature_dir}/${sample_species^}_SV_Set"

            # svlearn 24 feature genotyping
            svlearn genotype \
                -v "${feature_dir}/prepareAlt_output/ref_sorted_format_filtered_sv.vcf" \
                --model "${model}" \
                -s "${feature_dir}/sv_feature.tsv" \
                -a "${feature_dir}/${sample}_${coverage}.alignFeature/BreakPoint_ReadDepth_2Bam_feature.tsv" \
                -p "${feature_dir}/${sample}_${coverage}.paraFeature/para_feature.tsv" \
                -n "${sample}_${coverage}" \
                -o "${sample}_${coverage}.24fea.${model_name}.vcf"

            bgzip -c "${sample}_${coverage}.24fea.${model_name}.vcf" > "${sample}.svlearn_24.${coverage}.${model_name}.vcf.gz"

	    # benchmark
	    svlearn benchmark -n1 ${sample} -b ${true_sv_set} \
		    -n2 "${sample}_${coverage}" -c "${sample}.svlearn_24.${coverage}.${model_name}.vcf.gz" \
		    -o ${sample}.svlearn_24.${coverage}.${model_name}.bench.tsv

	    echo -e "sample  ${sample}\nmodel_used  ${model_name}\ncoverage  ${coverage}" | \
		    cat - ${sample}.svlearn_24.${coverage}.${model_name}.bench.tsv \
		    awk -F' ' -v OFS="\t"  '{for(i=1;i<=NF;i++) s[i]=s[i] (NR>1?"\t":"") $i} END{for(i=1;i<=NF;i++) print s[i]}' > ${sample}.svlearn_24.${coverage}.${model_name}.bench.row.tsv
        done
    done
done

csvtk concat -t *.bench.row.tsv > cross-species_24feature_benchmark.tsv
