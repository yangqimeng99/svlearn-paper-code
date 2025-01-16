sample="HG002"
sv_feature="../../../05.feature_extraction/Human_SV_Set/sv_feature.tsv"
true_sv_set="../../../02.long-reads_mapping_SVcalling/human/Human_SV_Set.vcf"
predicted_vcf_path=".."

mkdir -p sv.list sv.true_vcf

awk '$1!="sv_id"' ${sv_feature} | cut -f1 > sv.list/all.sv.list
#awk '$9!=0&&$2=="DEL"' ${sv_feature} | cut -f1 > sv.list/DEL.TR.sv.list
#awk '$9!=0&&$2=="INS"' ${sv_feature} | cut -f1 > sv.list/INS.TR.sv.list
#awk '$9==0&&$2=="INS"' ${sv_feature} | cut -f1 > sv.list/INS.nonTR.sv.list
#awk '$9==0&&$2=="DEL"' ${sv_feature} | cut -f1 > sv.list/DEL.nonTR.sv.list

# SV true genotype subsets
for TYPE in all
do
	bcftools view -i "ID=@sv.list/${TYPE}.sv.list" \
		-s ${sample} ${true_sv_set}  > sv.true_vcf/${sample}.${TYPE}.true_GT.vcf
done

for tool in paragraph bayestyper graphtyper svtyper svlearn_18 svlearn_24
do
	mkdir -p ${tool}/01.vcf ${tool}/02.bench
	for coverage in 30 20 10 5
	do
		for TYPE in all
		do
			# SV predicted genotype subsets
			bcftools view -i "ID=@sv.list/${TYPE}.sv.list" \
				${predicted_vcf_path}/${sample}.${tool}.${coverage}.vcf.gz \
				-O z -o ${tool}/01.vcf/${sample}.${coverage}.${TYPE}.vcf.gz

			# benchmark
			svlearn benchmark -n1 ${sample} -b sv.true_vcf/${sample}.${TYPE}.true_GT.vcf \
			       	-n2 ${sample}_${coverage} -c ${tool}/01.vcf/${sample}.${coverage}.${TYPE}.vcf.gz \
				-o ${tool}/02.bench/${sample}.${coverage}.${TYPE}.bench.tsv
			
			echo -e "tools  ${tool}\ncoverage  ${coverage}\ntype  ${TYPE}" | \
				cat - ${tool}/02.bench/${sample}.${coverage}.${TYPE}.bench.tsv | \
				awk -F' ' -v OFS="\t"  '{for(i=1;i<=NF;i++) s[i]=s[i] (NR>1?"\t":"") $i} END{for(i=1;i<=NF;i++) print s[i]}' > ${tool}/${sample}.${coverage}.${TYPE}.bench.row.tsv
		done
	done
done

# merge benchmark results
csvtk concat -t */${sample}.*.all.bench.row.tsv > benchmark_allSV_corresponding-model.tsv
