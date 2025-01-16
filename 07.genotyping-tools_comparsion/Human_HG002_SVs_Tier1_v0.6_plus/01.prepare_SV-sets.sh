#!/bin/bash

ref_genome="../../01.data_download/human/reference_genomes/hs37d5.fa"

# HG002 robust SV benchmark on GRCh37 the 
# calls with PASS in the FILTER field are our highest confidence set of SVs >=50bp
wget https://ftp.ncbi.nlm.nih.gov/ReferenceSamples/giab/release/AshkenazimTrio/HG002_NA24385_son/NIST_SV_v0.6/HG002_SVs_Tier1_v0.6.vcf.gz

bcftools view -i 'FILTER="PASS"' HG002_SVs_Tier1_v0.6.vcf.gz | bgzip > HG002_SVs_Tier1_PASS_v0.6.vcf.gz
tabix HG002_SVs_Tier1_PASS_v0.6.vcf.gz

bcftools query -f '%CHROM\t%POS0\t%END\t%ID\t%SVTYPE\n' \
	HG002_SVs_Tier1_PASS_v0.6.vcf.gz > HG002_SVs_Tier1_v0.6.pass.sv.bed

# HG002 benchmark regions on GRCh37
# this defines regions in which HG002_SVs_Tier1_v0.6.vcf.gz should contain close to 100 % of true insertions and deletions >=50bp
wget https://ftp.ncbi.nlm.nih.gov/ReferenceSamples/giab/release/AshkenazimTrio/HG002_NA24385_son/NIST_SV_v0.6/HG002_SVs_Tier1_v0.6.bed

# HG005 SV set on GRCh37
wget https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data/ChineseTrio/analysis/PacBio_CCS_15kb_20kb_chemistry2_12072020/HG005/HG005.hs37d5.pbsv.vcf.gz

# filter HG005 SV set
bcftools view -i 'SVLEN>=50 || SVLEN<=-50' HG005.hs37d5.pbsv.vcf.gz | \
	bcftools view -i 'SVTYPE=="INS"||SVTYPE=="DEL"' | \
	bcftools view -i 'F_MISSING==0' | \
	bcftools annotate --set-id '%CHROM\_%POS\_%ID' -O z -o HG005.hs37d5.pbsv.sv.resetID.vcf.gz

# Query SV information from the HG005 VCF file and cluster them to identify non-overlapping SVs.
# Filter SVs that do not overlap within the HG005 dataset and ensure they are at least 500bp away from the benchmark regions in HG002.
# Modify genotypes in the VCF file, changing '0/1' and '1/1' to '0/0', and apply a custom header for sample renaming (HG002 genotypes).
echo -e "HG005\tHG002" > rename.list
bcftools query -f '%CHROM\t%POS0\t%END\t%ID\n' HG005.hs37d5.pbsv.sv.resetID.vcf.gz | \
	bedtools cluster -i - | \
	awk '{arr[$5]++; lines[$5]=lines[$5] $0 RS} END {for (i in arr) if (arr[i]==1) printf "%s", lines[i]}' | \
	cut -f1-4 | \
	bedtools window -a - -b HG002_SVs_Tier1_v0.6.pass.sv.bed -v -w 500 | \
	bedtools intersect -a - -b HG002_SVs_Tier1_v0.6.bed -f 1 | \
	cut -f4 | \
	bcftools view -i 'ID=@-' HG005.hs37d5.pbsv.sv.resetID.vcf.gz | \
	sed 's/0\/1/0\/0/g' | sed 's/1\/1/0\/0/g' | \
	bcftools reheader -s rename.list > HG005.hs37d5.pbsv.sv.resetID_add_to_HG002_GT.vcf

bgzip HG005.hs37d5.pbsv.sv.resetID_add_to_HG002_GT.vcf
tabix HG005.hs37d5.pbsv.sv.resetID_add_to_HG002_GT.vcf.gz

bcftools concat -a HG002_SVs_Tier1_PASS_v0.6.vcf.gz HG005.hs37d5.pbsv.sv.resetID_add_to_HG002_GT.vcf.gz > HG002_SVs_Tier1_PASS_v0.6_add_3810_00.vcf


# 300bp uniq SV. svlearn v0.0.1
svlearn prepareAlt \
	--ref_fasta ${ref_genome} \
	--ref_sv_vcf HG002_SVs_Tier1_PASS_v0.6_add_3810_00.vcf \
	--out Human_HG002_SVs_Tier1_v0.6_plus_alt

bcftools query -f '%ID\n' Human_HG002_SVs_Tier1_v0.6_plus_alt/ref_sorted_format_filtered_sv.vcf \
	bcftools view -i 'ID=@-' HG002_SVs_Tier1_PASS_v0.6_add_3810_00.vcf > Human_HG002_SVs_Tier1_v0.6_plus.vcf
