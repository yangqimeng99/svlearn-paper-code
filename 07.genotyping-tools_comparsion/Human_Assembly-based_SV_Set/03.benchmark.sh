ref_genome="../../01.data_download/human/reference_genomes/human_GRCh38_full_analysis_set_plus_decoy_hla_REF.fasta"
svlearn_feature_dir="../../05.feature_extraction/Human_Assembly-based_SV_Set"
true_sv_set="../../04.assembly-based_SVcalling/human/Human_Assembly-based_SV_Set.vcf"
sample="HG002"


awk '$1!="sv_id"' ${svlearn_feature_dir}/sv_feature.tsv | cut -f1 > all_sv.list # all.sv.list


# benchmark 6 tools

mkdir -p 00.list 01.true_vcf
mv all_sv.list 00.list/
bcftools view -i "ID=@00.list/all_sv.list" ${true_sv_set} | bcftools view -s ${sample} > 01.true_vcf/${sample}.true_GT.vcf



for tool in svlearn_24 svlearn_18 paragraph bayestyper graphtyper svtyper
do
	mkdir -p ${tool}/01.vcf ${tool}/02.bench
	for coverage in 30 20 10 5
	do
		 bcftools view -i "ID=@00.list/all_sv.list" ${sample}.${tool}.${coverage}.vcf.gz -O z -o ${tool}/01.vcf/${sample}.${coverage}.vcf.gz
		 svlearn benchmark -n1 ${sample} -b 01.true_vcf/${sample}.true_GT.vcf -c ${tool}/01.vcf/${sample}.${coverage}.vcf.gz -n2 ${sample}_${coverage} -o ${tool}/02.bench/${sample}.${coverage}.bench.tsv
		 echo -e "tools  ${tool}\ncoverage  ${coverage}\n" | cat - ${tool}/02.bench/${sample}.${coverage}.bench.tsv | awk -F' ' -v OFS="\t"  '{for(i=1;i<=NF;i++) s[i]=s[i] (NR>1?"\t":"") $i} END{for(i=1;i<=NF;i++) print s[i]}' > ${tool}/${sample}.${coverage}.bench.row.tsv
	done
done


csvtk concat -t */HG002.*.bench.row.tsv > assembly_based_SV-set_benchmark.tsv
        

