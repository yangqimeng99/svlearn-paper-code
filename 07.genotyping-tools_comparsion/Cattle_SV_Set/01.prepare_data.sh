prepareAlt_output="../../05.feature_extraction/Cattle_SV_Set/prepareAlt_output"
ref_genome="../../01.data_download/cattle/reference_genomes/cattle_ARS-UCD2.0_GCF_002263795.3_REF.fasta"

# prepare other tools input file
# graphtyper

grep -v -E 'alt|_decoy|chrEBV|HLA-' ${ref_genome}.fai | awk '{print $1":0-"$2}' > cattle.genotyping_sv.region
bgzip -c ${prepareAlt_output}/ref_sorted_format_filtered_sv.vcf > graphtyper.ref_sorted_format.vcf.gz
bcftools index graphtyper.ref_sorted_format.vcf.gz

#bayestyper
bcftools norm -m+ -o bayestyper.ref_sorted_format_multi_allelic.vcf -O z ${prepareAlt_output}/ref_sorted_format_filtered_sv.vcf

#svtyper
bcftools view -i 'SVTYPE="DEL"' ${prepareAlt_output}/ref_sorted_format_filtered_sv.vcf | bcftools +fill-tags - -- -t END | awk '{if($0 ~ /^#/) print $0; else print $0 ";CIPOS=-100,100;CIEND=-100,100"}' > svtyper.ref_sorted_format_filtered_del_ann.vcf

bcftools view -i 'SVTYPE="DEL"' ${prepareAlt_output}/alt_sorted_format_filtered_sv.vcf | awk '{if($0 ~ /^#/) print $0; else print $0 ";CIPOS=-100,100;CIEND=-100,100"}' > svtyper.alt_sorted_format_filtered_ins_ann.vcf
