scripts="../../../../scripts"
region="GRCh38.genotyping_sv.region"
ref_genome="../../../../01.data_download/human/reference_genomes/human_GRCh38_full_analysis_set_plus_decoy_hla_REF.fasta"
refCanon="../../../../01.data_download/human/reference_genomes/GRCh38.canon.fasta"
refDecoy="../../../../01.data_download/human/reference_genomes/GRCh38.decoy.fasta"
prepareAlt_output="./prepareAlt_output"
models_dir="../../../../06.model_training_test/Human_SV_Set"
species="human"
sample="HG00514"

for num in 20000 40000 60000 80000 100000 120000 139743
do
    cd HG00514.SV_25006.REF_HOM_${num}
    for coverage in 30 20 10 5
    do
    	# svlearn 18 feature
    	svlearn genotype \
    		-v ${prepareAlt_output}/ref_sorted_format.vcf \
    	        --model ${models_dir}/RF-models_18feature/lack.HG002.${coverage}x.RF-model/RandomForest_model.joblib \
    	        -s sv_feature.tsv \
    	        -a ${sample}_${coverage}.alignFeature/BreakPoint_ReadDepth_2Bam_feature.tsv \
    	        -n ${sample}_${coverage} \
    	        -o ${sample}_${coverage}.pred.all.18fea.vcf
    	bgzip -c ${sample}_${coverage}.pred.all.18fea.vcf > ./HG002.svlearn_18.${covergae}.vcf.gz
    
    
    	# svlearn 24 feature
    	svlearn genotype \
    		-v ${prepareAlt_output}/ref_sorted_format.vcf \
    		--model ${models_dir}/RF-models_24feature/lack.HG002.${coverage}x.RF-model/RandomForest_model.joblib \
    		-s sv_feature.tsv \
    		-a ${sample}_${coverage}.alignFeature/BreakPoint_ReadDepth_2Bam_feature.tsv \
    		-p ${sample}_${coverage}.paraFeature/para_feature.tsv \
    		-n ${sample}_${coverage} \
    		-o ${sample}_${coverage}.pred.all.24fea.vcf
    	bgzip -c ${sample}_${coverage}.pred.all.24fea.vcf > ./HG002.svlearn_24.${covergae}.vcf.gz
    	
	# paragraph
	gunzip -c ${sample}_${coverage}.paraFeature/ref_paragraph_out/genotypes.vcf.gz | awk -v old="GT_paragraph_ref" -v new="${sample}_${covergae}" '{if($0 ~ /^#CHROM/) gsub(old, new); print}' | bgzip > ${sample}.paragraph.${coverage}.vcf.gz

    	# graphtyper
    	bash ${scripts}/graphtyper.sh \
    		${sample} \
    		${coverage} \
    		./${sample}_${coverage}.dedup.sort.bam \
    		graphtyper.ref_sorted_format.vcf.gz \
    		${ref_genome} \
    		${region} \
    		16
    
    	# bayestyper
    	bash ${scripts}/bayestyper.sh \
    		${sample} \
    		${coverage} \
    		./${sample}_${coverage}.dedup.sort.bam \
    		16 \
    		bayestyper.ref_sorted_format_multi_allelic.vcf \
    		${refCanon} \
    		${refDecoy}
    
    	# svtyper
    	bash ${scripts}/svtyper.sh \
    		svtyper.ref_sorted_format_filtered_del_ann.vcf \
    		svtyper.alt_sorted_format_filtered_ins_ann.vcf \
    		${prepareAlt_output}/ref_sorted_format.vcf \
    		./${sample}_${coverage}.dedup.sort.bam \
    		./${sample}_${coverage}_alt.dedup.sort.bam \
    		${sample} \
    		${coverage}
    done
    cd ../
done
    
