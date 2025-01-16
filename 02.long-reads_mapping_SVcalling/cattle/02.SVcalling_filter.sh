#!/bin/bash

ref_genome="../../01.data_download/cattle/reference_genomes/cattle_ARS-UCD2.0_GCF_002263795.3_REF.fasta"
sample_list="../../01.data_download/cattle/15cattle.list.tsv"
scripts="../../scripts"
species="Cattle"

trf ${ref_genome} 2 7 7 80 10 50 500 -f -d -h
python ${scripts}/TRF2GFF.py -d $(basename ${ref_genome}).2.7.7.80.10.50.500.dat -o $(basename ${ref_genome}).trf.gff
awk '{print $1"\t"$4-1"\t"$5}' $(basename ${ref_genome}).trf.gff > trf.bed

while read sample
do
	bash ${scripts}/sniffles_snf.sh ${sample}.hifi.sort.bam ${sample} ${ref_genome} trf.bed
	echo "${sample}.snf" >> snf.list.tsv
done < ${sample_list}

bash ${scripts}/sniffles_multisample_SV-filter.sh snf.list.tsv ${species}_SV_Set ${ref_genome} trf.bed

# 300bp uniq SV
svlearn prepareAlt \
	--ref_fasta ${ref_genome} \
	--ref_sv_vcf ${species}_SV_Set.pav.vcf \
	--min-distance 300 \
	--out ${species}_SV_Set_alt

bcftools query -f '%ID\n' ${species}_SV_Set_alt/ref_sorted_format_filtered_sv.vcf > ${species}_SV_Set.ID.list.tsv
bcftools view -i "ID=@${species}_SV_Set.ID.list.tsv" ${species}_SV_Set.pav.vcf > ${species}_SV_Set.vcf

# summary SVLEN and GT
bcftools query -H -f '%ID\t%SVTYPE\t%SVLEN[\t%GT]\n' ${species}_SV_Set.vcf | sed 's/-//g' > ${species}_SV_Set.SVLEN.GT.tsv
