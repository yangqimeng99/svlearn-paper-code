#!/bin/bash

ref_genome="../../01.data_download/human/reference_genomes/human_GRCh38_full_analysis_set_plus_decoy_hla_REF.fasta"
sample_list="../../01.data_download/human/15human.list.tsv"
scripts="../../scripts"

trf ${ref_genome} 2 7 7 80 10 50 500 -f -d -h
python ${scripts}/TRF2GFF.py -d $(basename ${ref_genome}).2.7.7.80.10.50.500.dat -o $(basename ${ref_genome}).trf.gff
awk '{print $1"\t"$4-1"\t"$5}' $(basename ${ref_genome}).trf.gff > trf.bed

while read sample
do
	bash ${scripts}/sniffles_snf.sh ${sample}.hifi.sort.bam ${sample} ${ref_genome} trf.bed
	echo "${sample}.snf" >> snf.list.tsv
done < ${sample_list}

bash ${scripts}/sniffles_multisample_SV-filter.sh snf.list.tsv Human_SV_Set ${ref_genome} trf.bed

# 300bp uniq SV
svlearn prepareAlt \
	--ref_fasta ${ref_genome} \
	--ref_sv_vcf Human_SV_Set.pav.vcf \
	--min-distance 300 \
	--out Human_SV_Set_alt

bcftools query -f '%ID\n' Human_SV_Set_alt/ref_sorted_format_filtered_sv.vcf > Human_SV_Set.ID.list.tsv
bcftools view -i "ID=@Human_SV_Set.ID.list.tsv" Human_SV_Set.pav.vcf > Human_SV_Set.vcf

# for plot Fig.2a-b
bcftools query -H -f '%ID\t%SVTYPE\t%SVLEN[\t%GT]\n' Human_SV_Set.vcf | sed 's/-//g' > Human_SV_Set.SVLEN.GT.tsv
