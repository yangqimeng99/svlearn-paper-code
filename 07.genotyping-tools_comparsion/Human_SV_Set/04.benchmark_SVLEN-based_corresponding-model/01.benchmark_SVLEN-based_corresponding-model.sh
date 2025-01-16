sample="HG002"
sv_feature="../../../05.feature_extraction/Human_SV_Set/sv_feature.tsv"
true_sv_set="../../../02.long-reads_mapping_SVcalling/human/Human_SV_Set.vcf"
predicted_vcf_path=".."

mkdir -p sv.list sv.true_vcf

for SVTYPE in DEL INS
do
	awk -v type="$SVTYPE" '$3>=50 && $3<100 && $2==type' ${sv_feature} | cut -f1 > sv.list/SV.50-100.${SVTYPE}.list.txt
	awk -v type="$SVTYPE" '$3>=100 && $3<300 && $2==type' ${sv_feature} | cut -f1 > sv.list/SV.100-300.${SVTYPE}.list.txt
	awk -v type="$SVTYPE" '$3>=300 && $3<500 && $2==type' ${sv_feature} | cut -f1 > sv.list/SV.300-500.${SVTYPE}.list.txt
	awk -v type="$SVTYPE" '$3>=500 && $3<1000 && $2==type' ${sv_feature} | cut -f1 > sv.list/SV.500-1000.${SVTYPE}.list.txt
	awk -v type="$SVTYPE" '$3>=1000 && $3<5000 && $2==type' ${sv_feature} | cut -f1 > sv.list/SV.1k-5k.${SVTYPE}.list.txt
	awk -v type="$SVTYPE" '$3>=5000 && $2==type' ${sv_feature} | cut -f1 > sv.list/SV.5k+.${SVTYPE}.list.txt
done

# SV true genotype subsets
for SVLEN in 50-100 100-300 300-500 500-1000 1k-5k 5k+
do
	for SVTYPE in DEL INS
	do
		bcftools view -i "ID=@sv.list/SV.${SVLEN}.${SVTYPE}.list.txt" \
			-s ${sample} ${true_sv_set}  > sv.true_vcf/${sample}.${SVLEN}.${SVTYPE}.true_GT.vcf
	done
done

for tool in svlearn_24 svlearn_18 paragraph bayestyper graphtyper svtyper
do
	mkdir -p ${tool}/01.vcf ${tool}/02.bench
	for coverage in 30 20 10 5
	do
		for SVLEN in 50-100 100-300 300-500 500-1000 1k-5k 5k+
		do
			for SVTYPE in DEL INS
			do
				# SV predicted genotype subsets
				bcftools view -i "ID=@sv.list/SV.${SVLEN}.${SVTYPE}.list.txt" \
					${predicted_vcf_path}/${sample}.${tool}.${coverage}.vcf.gz \
					-O z -o ${tool}/01.vcf/${sample}.${coverage}.${SVLEN}.${SVTYPE}.vcf.gz

				# benchmark
				svlearn benchmark -n1 ${sample} -b sv.true_vcf/${sample}.${SVLEN}.${SVTYPE}.true_GT.vcf -c ${tool}/01.vcf/${sample}.${coverage}.${SVLEN}.${SVTYPE}.vcf.gz -n2 ${sample}_${coverage} -o ${tool}/02.bench/${sample}.${coverage}.${SVLEN}.${SVTYPE}.bench.tsv
				echo -e "tools  ${tool}\ncoverage  ${coverage}\ntype  ${SVTYPE}\nlength  ${SVLEN}" | cat - ${tool}/02.bench/${sample}.${coverage}.${SVLEN}.${SVTYPE}.bench.tsv | awk -F' ' -v OFS="\t"  '{for(i=1;i<=NF;i++) s[i]=s[i] (NR>1?"\t":"") $i} END{for(i=1;i<=NF;i++) print s[i]}' > ${tool}/${sample}.${coverage}.${SVLEN}.${SVTYPE}.bench.row.tsv
			done
		done
	done
done

# merge benchmark results
csvtk concat -t */${sample}.*.bench.row.tsv > benchmark_SVLEN-based_corresponding-model.tsv
