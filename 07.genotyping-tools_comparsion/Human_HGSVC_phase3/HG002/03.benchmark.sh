ref_genome="../../../../01.data_download/human/reference_genomes/human_GRCh38_full_analysis_set_plus_decoy_hla_REF.fasta"
sample="HG002"


for num in 20000 40000 60000 80000 100000 120000 139254
do
	cd HG002.SV_25217.REF_HOM_${num}
        # generate filter300_sv.list & all.sv.list
	svlearn prepareAlt \
		--ref_fasta ${ref_genome} \
		--ref_sv_vcf ../HG002.SV_25217.REF_HOM_${num}.vcf \
		--min-distance 300 \
		--out filter300_HG002.SV_25217.REF_HOM_${num}
	
	filter300_output="filter300_HG002.SV_25217.REF_HOM_${num}"
	bcftools query -f '%ID\n' ${filter300_output}/alt_sorted_format_filtered_sv.vcf > filter300_sv_${num}.list # filter300_sv.list

	awk '$1!="sv_id"' sv_feature.tsv | cut -f1 > all_sv_${num}.list # all.sv.list
	

        # benchmark 6 tools

        mkdir -p 00.list 01.true_vcf
        mv *sv.list 00.list/
	for SVTYPE in all filter300
	do
		bcftools view -i "ID=@00.list/${SVTYPE}_sv_${num}.list" ../HG002.SV_25217.REF_HOM_${num}.vcf | bcftools view -s ${sample} > 01.true_vcf/${sample}.${num}.${SVTYPE}.true_GT.vcf
	done


        for tool in svlearn_24 svlearn_18 paragraph bayestyper graphtyper svtyper
        do
        	mkdir -p ${tool}/01.vcf ${tool}/02.bench
        	for coverage in 30 20 10 5
        	do
			for SVTYPE in all filter300
        		do
        			bcftools view -i "ID=@00.list/${SVTYPE}_sv_${num}.list" ${sample}.${tool}.${coverage}.${num}.vcf.gz -O z -o ${tool}/01.vcf/${sample}.${coverage}.${num}.${SVTYPE}.vcf.gz
        			svlearn benchmark -n1 ${sample} -b 01.true_vcf/${sample}.${num}.${SVTYPE}.true_GT.vcf -c ${tool}/01.vcf/${sample}.${coverage}.${num}.${SVTYPE}.vcf.gz -n2 ${sample}_${coverage} -o ${tool}/02.bench/${sample}.${coverage}.${num}.${SVTYPE}.bench.tsv
        			echo -e "tools  ${tool}\ncoverage  ${coverage}\ntype  ${SVTYPE}\nhomref_num  ${num}" | cat - ${tool}/02.bench/${sample}.${coverage}.${num}.${SVTYPE}.bench.tsv | awk -F' ' -v OFS="\t"  '{for(i=1;i<=NF;i++) s[i]=s[i] (NR>1?"\t":"") $i} END{for(i=1;i<=NF;i++) print s[i]}' > ${tool}/${sample}.${coverage}.${num}.${SVTYPE}.bench.row.tsv
        		done
        	done
        done
	cd ../
done

csvtk concat -t */*/HG002.*.bench.row.tsv > ${sample}.benchmark_6tools.tsv
        

