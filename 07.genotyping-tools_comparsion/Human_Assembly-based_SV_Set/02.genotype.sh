scripts="../../scripts"
ref_bam_dir="../../03.short-reads_mapping_downsample"
prepareAlt_output="../../05.feature_extraction/Human_Assembly-based_SV_Set/prepareAlt_output"
region="GRCh38.genotyping_sv.region"
ref_genome="../../01.data_download/human/reference_genomes/human_GRCh38_full_analysis_set_plus_decoy_hla_REF.fasta"
refCanon="../../01.data_download/human/reference_genomes/GRCh38.canon.fasta"
refDecoy="../../01.data_download/human/reference_genomes/GRCh38.decoy.fasta"
svlearn_feature_dir="../../05.feature_extraction/Human_Assembly-based_SV_Set"
models_dir="../../06.model_training_test/Human_SV_Set"
species="human"
sample="HG002"

for coverage in 30 20 10 5
do
	# svlearn 18 feature(correspond coverage model) 
	svlearn genotype \
		-v ${prepareAlt_output}/ref_sorted_format_filtered_sv.vcf \
		--model ${models_dir}/RF-models_18feature/lack.HG002.30x.RF-model/RandomForest_model.joblib \
		-s ${svlearn_feature_dir}/sv_feature.tsv \
		-a ${svlearn_feature_dir}/${sample}_${coverage}.alignFeature/BreakPoint_ReadDepth_2Bam_feature.tsv \
		-n ${sample}_${coverage} \
		-o ${sample}_${coverage}.pred.all.18fea.vcf
	bgzip -c ${sample}_${coverage}.pred.all.18fea.vcf > ./${sample}.svlearn_18.${covergae}.vcf.gz

	# svlearn 24 feature(correspond coverage model)
	svlearn genotype \
		-v ${prepareAlt_output}/ref_sorted_format_filtered_sv.vcf \
		--model ${models_dir}/RF-models_24feature/lack.HG002.30x.RF-model/RandomForest_model.joblib \
		-s ${svlearn_feature_dir}/sv_feature.tsv \
		-a ${svlearn_feature_dir}/${sample}_${coverage}.alignFeature/BreakPoint_ReadDepth_2Bam_feature.tsv \
		-p ${svlearn_feature_dir}/${sample}_${coverage}.paraFeature/para_feature.tsv \
		-n ${sample}_${coverage} \
		-o ${sample}_${coverage}.pred.all.24fea.vcf
	bgzip -c ${sample}_${coverage}.pred.all.24fea.vcf > ./${sample}.svlearn_24.${covergae}.vcf.gz

	# paragraph
	gunzip -c ${svlearn_feature_dir}/${sample}_${coverage}.paraFeature/ref_paragraph_out/genotypes.vcf.gz | awk -v old="GT_paragraph_ref" -v new="${sample}_${covergae}" '{if($0 ~ /^#CHROM/) gsub(old, new); print}' | bgzip > ${sample}.paragraph.${coverage}.vcf.gz
	
	# graphtyper
	bash ${scripts}/graphtyper.sh \
		${sample} \
		${coverage} \
		${ref_bam_dir}/${species}/${sample}_${coverage}.dedup.sort.bam \
		graphtyper.ref_sorted_format.vcf.gz \
		${ref_genome} \
		${region} \
		16

	# bayestyper
	bash ${scripts}/bayestyper.sh \
		${sample} \
		${coverage} \
		${ref_bam_dir}/${species}/${sample}_${coverage}.dedup.sort.bam \
		16 \
		bayestyper.ref_sorted_format_multi_allelic.vcf \
		${refCanon} \
		${refDecoy}

	# svtyper
	bash ${scripts}/svtyper.sh \
		svtyper.ref_sorted_format_filtered_del_ann.vcf \
		svtyper.alt_sorted_format_filtered_ins_ann.vcf \
		${prepareAlt_output}/ref_sorted_format_filtered_sv.vcf \
		${ref_bam_dir}/${species}/${sample}_${coverage}.dedup.sort.bam \
		${svlearn_feature_dir}/${sample}_${coverage}_alt.dedup.sort.bam \
		${sample} \
		${coverage}
done
