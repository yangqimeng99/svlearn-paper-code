#!/bin/bash

ref_genome="../../01.data_download/human/reference_genomes/human_GRCh38_full_analysis_set_plus_decoy_hla_REF.fasta"
alt_genome="./prepareAlt_output/alt.fasta"
scripts="../../scripts"

ln -s ${ref_genome} ./ref.fasta
ln -s ${alt_genome} ./alt.fasta

# 01.RepeatMasker, Please adjust the `-pa` and `-species` parameters based on the actual circumstances.
RepeatMasker -pa 64 -engine ncbi -species human -xsmall -s -no_is -cutoff 255 -frag 20000 -dir ./ -gff ref.fasta
RepeatMasker -pa 64 -engine ncbi -species human -xsmall -s -no_is -cutoff 255 -frag 20000 -dir ./ -gff alt.fasta

# 02.trf
trf ref.fasta 2 7 7 80 10 50 500 -f -d -h
trf alt.fasta 2 7 7 80 10 50 500 -f -d -h
python ${scripts}/TRF2GFF.py -d ref.fasta.2.7.7.80.10.50.500.dat -o ref.trf.gff
python ${scripts}/TRF2GFF.py -d alt.fasta.2.7.7.80.10.50.500.dat -o alt.trf.gff

# 03.GenMap
bash ${scripts}/genmap.sh ref.fasta ref.fasta.genmapK50E1
bash ${scripts}/genmap.sh alt.fasta alt.fasta.genmapK50E1

# 04.BISER, fasta.masked is the softmasked FASTA files obtained from the output of 01.RepeatMasker
biser -o ref.fasta.masked.out -t 2 --gc-heap 32G ref.fasta.masked
biser -o alt.fasta.masked.out -t 2 --gc-heap 32G alt.fasta.masked

# 05.svlearn svFeature
svlearn svFeature \
        --ref_sv_vcf ./prepareAlt_output/ref_sorted_format_filtered_sv.vcf \ # output of 1. Create Alt Genome
        --alt_sv_bed ./prepareAlt_output/alt_sorted_format_filtered_sv.bed \ # output of 1. Create Alt Genome
        --ref_rm ref.fasta.out \ # 01.RepeatMasker output in ref.fasta
        --alt_rm alt.fasta.out \ # 01.RepeatMasker output in alt.fasta
        --ref_trf ref.trf.gff \
        --alt_trf alt.trf.gff \
        --ref_genmap ref.fasta.genmapK50E1.txt \
        --alt_genmap alt.fasta.genmapK50E1.txt \
        --ref_biser ref.fasta.masked.out \
        --alt_biser alt.fasta.masked.out \
        --out sv_feature.tsv

# 06.repeat-class for Fig.2c
bash ${scripts}/repeat_class_convert.sh sv_feature.tsv | cut -f1-4 > SV_repeat-class.tsv
