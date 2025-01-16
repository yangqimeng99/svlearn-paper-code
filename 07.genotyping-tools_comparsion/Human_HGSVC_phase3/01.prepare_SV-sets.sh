#!/bin/bash

ref_genome="../../01.data_download/human/reference_genomes/human_GRCh38_full_analysis_set_plus_decoy_hla_REF.fasta"
scripts="../../scripts"

# download HGSVC Phase3 SV set
wget https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/HGSVC3/release/Variant_Calls/1.0/GRCh38/variants_GRCh38_sv_insdel_alt_HGSVC2024v1.0.vcf.gz

gunzip variants_GRCh38_sv_insdel_alt_HGSVC2024v1.0.vcf.gz 

# check SV sequences, SV in gap region excluded
svlearn prepareAlt \
	--ref_fasta ${ref_genome} \
	--ref_sv_vcf variants_GRCh38_sv_insdel_alt_HGSVC2024v1.0.vcf \
	--no-filter-overlaps \
	--out HGSVC_Phase3_sv_all_ALT

bcftools query -f '%ID\n' HGSVC_Phase3_sv_all_ALT/ref_sorted_format.vcf > variants_GRCh38_sv_insdel_HGSVC2024v1.0_clean.list.tsv

echo -e "NA24385\tHG002" > rename.list

bcftools +setGT variants_GRCh38_sv_insdel_alt_HGSVC2024v1.0.vcf -- -t a -n u | \
	bcftools view -s NA24385,HG00514 | \
	bcftools reheader --samples rename.list | \
	bcftools view -i 'ID=@variants_GRCh38_sv_insdel_HGSVC2024v1.0_clean.list.tsv' \
	> variants_GRCh38_sv_insdel_HGSVC2024v1.0_clean_filter.vcf


HGSVCPhase3="variants_GRCh38_sv_insdel_HGSVC2024v1.0_clean_filter.vcf"
mkdir -p HG002 HG00514

##### HG002, exclude SVs with missing HG002 genotypes
# HG002 0/0 SVs ID
bcftools query -f '%ID[\t%GT]\n' ${HGSVCPhase3} | awk '$2=="0/0"' | cut -f1 > HG002/HG002.REF_HOM_139254.txt

# HG002 0/1 and 1/1 SVs ID
bcftools query -f '%ID[\t%GT]\n' ${HGSVCPhase3} | awk '$2=="0/1"||$2=="1/1"' | cut -f1 > HG002/HG002.SV.list

# Randomly generate different quantities of HG002 0/0 SVs
python ${scripts}/id_sampler.py \
	-i HG002/HG002.REF_HOM_139254.txt \
	-o HG002/HG002.REF_HOM \
	-s 20000 40000 60000 80000 100000 120000 \
	--seed 42

for num in 20000 40000 60000 80000 100000 120000 139254
do
       cat HG002/HG002.SV.list HG002/HG002.REF_HOM_${num}.txt > HG002/HG002.SV_25217.REF_HOM_${num}.txt
       bcftools view \
	       -i "ID=@HG002/HG002.SV_25217.REF_HOM_${num}.txt" \
	       -s HG002 \
	       ${HGSVCPhase3} > HG002/HG002.SV_25217.REF_HOM_${num}.vcf
done


##### HG00514, exclude SVs with missing HG00514 genotypes
# HG00514 0/0 SVs ID
bcftools query -f '%ID[\t%GT]\n' ${HGSVCPhase3} | awk '$3=="0/0"' | cut -f1 > HG00514/HG00514.REF_HOM_139743.txt

# HG00514 0/1 and 1/1 SVs ID
bcftools query -f '%ID[\t%GT]\n' ${HGSVCPhase3} | awk '$3=="0/1"||$3=="1/1"' | cut -f1 > HG00514/HG00514.SV.list

# Randomly generate different quantities of HG00514 0/0 SVs
python ${scripts}/id_sampler.py \
	-i HG00514/HG00514.REF_HOM_139743.txt \
	-o HG00514/HG00514.REF_HOM \
	-s 20000 40000 60000 80000 100000 120000 \
	--seed 42

for num in 20000 40000 60000 80000 100000 120000 139743
do
	cat HG00514/HG00514.SV.list HG00514/HG00514.REF_HOM_${num}.txt > HG00514/HG00514.SV_25006.REF_HOM_${num}.txt
	bcftools view \
		-i "ID=@HG00514/HG00514.SV_25006.REF_HOM_${num}.txt" \
		-s HG00514 \
		${HGSVCPhase3} > HG00514/HG00514.SV_25006.REF_HOM_${num}.vcf
done
