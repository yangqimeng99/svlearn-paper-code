del_ref_vcf=$1
ins_alt_vcf=$2
all_sv_vcf=$3
ref_bam=$4
alt_bam=$5
sample=$6
coverage=$7
out_put=${sample}_${coverage}

svtyper \
	-i ${del_ref_vcf} \
	-B ${ref_bam} \
	-l ${out_put}_ref.bam.json > ${out_put}_svtyper_del.vcf

svtyper \
	-i ${ins_alt_vcf} \
	-B ${alt_bam} \
	-l ${out_put}_alt.bam.json > ${out_put}_svtyper_ins.vcf

bcftools query -f '%ID\t[%GT]\n' ${out_put}_svtyper_del.vcf > ${out_put}_svtyper_sv.gt.tsv
bcftools query -f '%ID\t[%GT]\n' ${out_put}_svtyper_ins.vcf | awk '{if ($2=="0/0") {print $1"\t1/1"} else if ($2=="1/1") {print $1"\t0/0"} else {print $0}}' >> ${out_put}_svtyper_sv.gt.tsv

bcftools view ${all_sv_vcf} | grep '##' > ${out_put}_svtyper_sv.gt.vcf
echo -e "##FORMAT=<ID=GT,Number=1,Type=String,Description="Genotype">" >> ${out_put}_svtyper_sv.gt.vcf
echo -e "#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFORMAT\tsvtyper_GT" >> ${out_put}_svtyper_sv.gt.vcf
bcftools view ${all_sv_vcf} | grep -v '^#' | awk '{print $0"\tGT"}' | csvtk join -t -H -f '3;1' - ${out_put}_svtyper_sv.gt.tsv >> ${out_put}_svtyper_sv.gt.vcf

#bcftools view ${all_sv_vcf} | grep -v '#' | awk '{print $0"\tGT"}' | csvtk join -t -H -f '3;1' - ${out_put}_svtyper_sv.gt.tsv >> ${out_put}_svtyper_sv.gt.vcf

rm -rf ${out_put}_svtyper_del.vcf ${out_put}_svtyper_ins.vcf ${out_put}_svtyper_sv.gt.tsv ${out_put}_alt.bam.json ${out_put}_ref.bam.json

awk -v old="svtyper_GT" -v new="${sample}_${covergae}" '{if($0 ~ /^#CHROM/) gsub(old, new); print}' ${out_put}_svtyper_sv.gt.vcf | bgzip > ${sample}.svtyper.${covergae}.vcf.gz
