sample="HG002"
sv_feature="../../../05.feature_extraction/Human_SV_Set/sv_feature.tsv"
true_sv_set="../../../02.long-reads_mapping_SVcalling/human/Human_SV_Set.vcf"

scripts="../../../scripts"
predicted_vcf_path=".."

############## ALL SV
mkdir -p all_out
outputPath="all_out"

for tool in svlearn_18 svlearn_24 paragraph bayestyper graphtyper svtyper
do
	for coverage in 30 20 10 5
	do
		python ${scripts}/benchmark_confusion_matrix.py \
		-n1 ${sample} -b ${true_sv_set} \
		-c ${predicted_vcf_path}/${sample}.${tool}.${coverage}.vcf.gz \
		-n2 ${sample}_${coverage} \
		-o ${outputPath}/${sample}_${coverage}.${tool}.bench.tsv \
		--cm_out ${outputPath}/${sample}_${coverage}.${tool}.confusion_matrix \
		--cm_title "${sample} ${coverage}×" \
		--tool ${tool} \
		--coverage ${coverage}
	done
done

# merge all confusion-matrix.tsv
python ${scripts}/merge_confusion_matrix.py \
	"${outputPath}/*.confusion_matrix.tsv" \
	./${sample}_all_confusion-matrix.tsv

# genotype-concordance have been shown in the benchmark matrix
# awk '$1=="True"||$1==$2' ./${sample}_all_confusion-matrix.tsv > ./${sample}_all_genotype-concordance.tsv

############## INS vs DEL
mkdir -p sv.list sv.true_vcf
awk '$2=="DEL"' ${sv_feature} | cut -f1 > sv.list/DEL.sv.list
awk '$2=="INS"' ${sv_feature} | cut -f1 > sv.list/INS.sv.list

for TYPE in INS DEL
do
	bcftools view -i "ID=@sv.list/{TYPE}.sv.list" ${true_sv_set} -s ${sample} > sv.true_vcf/${sample}.${TYPE}.true_GT.vcf
done

mkdir -p ins_del_out
outputPath="ins_del_out"

for tool in svlearn_18 svlearn_24 paragraph bayestyper graphtyper svtyper
do
	mkdir -p ${tool}/01.vcf
	for coverage in 30 20 10 5
	do
		for TYPE in INS DEL
		do
			bcftools view -i "ID=@sv.list/${TYPE}.sv.list" \
				${predicted_vcf_path}/${sample}.${tool}.${coverage}.vcf.gz \
				-O z -o ${tool}/01.vcf/${sample}.${coverage}.${TYPE}.vcf.gz

			trueSet="sv.true_vcf/${sample}.${TYPE}.true_GT.vcf"

			python ${scripts}/benchmark_ins_del_confusion_matrix.py \
				-n1 ${sample} -b ${trueSet} \
				-c ${tool}/01.vcf/${sample}.${coverage}.${TYPE}.vcf.gz \
				-n2 ${sample}_${coverage} \
				-o ${outputPath}/${sample}_${coverage}.${tool}.${TYPE}.bench.tsv \
				--cm_out ${outputPath}/${sample}_${coverage}.${tool}.${TYPE}.confusion_matrix \
				--cm_title "${sample} ${coverage}×" \
				--tool ${tool} \
				--coverage ${coverage} \
				--sv_type ${TYPE}
		done
	done
done

# merge all ins_del_confusion-matrix.tsv
python ${scripts}/merge_ins_del_confusion_matrix.py \
	"${outputPath}/*.confusion_matrix.tsv" \
	./${sample}_ins_del_confusion-matrix.tsv

awk '$1=="True"||$1==$2' ./${sample}_ins_del_confusion-matrix.tsv > ./${sample}_ins_del_genotype-concordance.tsv
