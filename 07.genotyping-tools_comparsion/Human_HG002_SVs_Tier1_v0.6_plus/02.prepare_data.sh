#!/bin/bash

ref_genome="../../01.data_download/human/reference_genomes/hs37d5.fa"
scripts="../../scripts"
species="human"
sample="HG002"
alt_genome="Human_HG002_SVs_Tier1_v0.6_plus_alt/alt.fasta"
prepareAlt_output="./Human_HG002_SVs_Tier1_v0.6_plus_alt"

ln -s ${alt_genome} alt.fasta
ln -s ${ref_genome} ref.fasta

# 01.RepeatMasker
RepeatMasker -pa 64 -engine ncbi -species human -xsmall -s -no_is -cutoff 255 -frag 20000 -dir ./ -gff alt.fasta
RepeatMasker -pa 64 -engine ncbi -species human -xsmall -s -no_is -cutoff 255 -frag 20000 -dir ./ -gff ref.fasta
    
# 02.trf
trf alt.fasta 2 7 7 80 10 50 500 -f -d -h 
trf ref.fasta 2 7 7 80 10 50 500 -f -d -h
python ${scripts}/TRF2GFF.py -d alt.fasta.2.7.7.80.10.50.500.dat -o alt.trf.gff
python ${scripts}/TRF2GFF.py -d ref.fasta.2.7.7.80.10.50.500.dat -o ref.trf.gff

# 03.GenMap
bash ${scripts}/genmap.sh alt.fasta alt.fasta.genmapK50E1
bash ${scripts}/genmap.sh ref.fasta ref.fasta.genmapK50E1

# 04.BISER, fasta.masked is the softmasked FASTA files obtained from the output of 01.RepeatMasker
biser -o alt.fasta.masked.out -t 2 --gc-heap 32G alt.fasta.masked
biser -o ref.fasta.masked.out -t 2 --gc-heap 32G ref.fasta.masked

# 05.svlearn svFeature
svlearn svFeature \
    --ref_sv_vcf  ${prepareAlt_output}/ref_sorted_format_filtered_sv.vcf \ # output of 1. Create Alt Genome
    --alt_sv_bed  ${prepareAlt_output}/alt_sorted_format_filtered_sv.bed \ # output of 1. Create Alt Genome
    --ref_rm ref.fasta.out \
    --alt_rm alt.fasta.out \ # 01.RepeatMasker output in alt.fasta
    --ref_trf ref.trf.gff \
    --alt_trf alt.trf.gff \
    --ref_genmap ref.fasta.genmapK50E1.txt \
    --alt_genmap alt.fasta.genmapK50E1.txt \
    --ref_biser ref.fasta.masked.out \
    --alt_biser alt.fasta.masked.out \
    --out sv_feature.tsv

# mapping_ref_bam
#index 
bwa-mem2.avx512bw index ${ref_genome}
# mapping
for coverage in 30 20 10 5
do
	bash ${scripts}/bwa_dedup.sh \
			../../03.short-reads_mapping_downsample/${species}/${sample}_${coverage}_R1.fq.gz \
			../../03.short-reads_mapping_downsample/${species}/${sample}_${coverage}_R2.fq.gz \
			${ref_genome} \
			${sample}_${coverage}
done

    
# mapping_alt_bam
# index for alt_genome
bwa-mem2.avx512bw index ${alt_genome}
# mapping 
for coverage in 30 20 10 5
do
bash ${scripts}/bwa_dedup.sh \
	../../03.short-reads_mapping_downsample/${species}/${sample}_${coverage}_R1.fq.gz \
	../../03.short-reads_mapping_downsample/${species}/${sample}_${coverage}_R2.fq.gz \
	${alt_genome} \
	${sample}_${coverage}_alt
done



# Alignment_Paragraph-feature_extraction
for coverage in 30 20 10 5
do
# svlearn Alignment feature
svlearn alignFeature \
	--ref_fasta ${ref_genome} \
	--alt_fasta ${alt_genome} \
	--ref_sv_vcf ${prepareAlt_output}/ref_sorted_format_filtered_sv.vcf \
	--alt_sv_bed ${prepareAlt_output}/alt_sorted_format_filtered_sv.bed \
	--ref_bam ${sample}_${coverage}.dedup.sort.bam \
	--alt_bam ${sample}_${coverage}_alt.dedup.sort.bam \
	--threads 6 \
	--out ${sample}_${coverage}.alignFeature

# svlearn Paragraph feature
svlearn runParagraph \
	--ref_fasta ${ref_genome} \
	--alt_fasta ${alt_genome} \
	--ref_sv_vcf ${prepareAlt_output}/ref_sorted_format_filtered_sv.vcf \
	--alt_sv_vcf ${prepareAlt_output}/alt_sorted_format_filtered_sv.vcf \
	--ref_bam ${sample}_${coverage}.dedup.sort.bam \
	--alt_bam ${sample}_${coverage}_alt.dedup.sort.bam \
	--threads 6 \
	--out ${sample}_${coverage}.paraFeature
done



# prepare other tools input file

# graphtyper
grep -v -E 'alt|_decoy|chrEBV|HLA-' ${ref_fasta}.fai | awk '{print $1":0-"$2}' > hs37d5.genotyping_sv.region
bgzip -c ${prepareAlt_output}/ref_sorted_format_filtered_sv.vcf > graphtyper.ref_sorted_format.vcf.gz
bcftools index graphtyper.ref_sorted_format.vcf.gz

#bayestyper
bcftools norm -m+ -o bayestyper.ref_sorted_format_multi_allelic.vcf -O z ${prepareAlt_output}/ref_sorted_format_filtered_sv.vcf

#svtyper
bcftools view -i 'SVTYPE="DEL"' ${prepareAlt_output}/ref_sorted_format_filtered_sv.vcf | bcftools +fill-tags - -- -t END | awk '{if($0 ~ /^#/) print $0; else print $0 ";CIPOS=-100,100;CIEND=-100,100"}' > svtyper.ref_sorted_format_filtered_del_ann.vcf

bcftools view -i 'SVTYPE="DEL"' ${prepareAlt_output}/alt_sorted_format_filtered_sv.vcf | awk '{if($0 ~ /^#/) print $0; else print $0 ";CIPOS=-100,100;CIEND=-100,100"}' > svtyper.alt_sorted_format_filtered_ins_ann.vcf


