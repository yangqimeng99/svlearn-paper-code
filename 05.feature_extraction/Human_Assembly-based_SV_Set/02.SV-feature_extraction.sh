#!/bin/bash

alt_genome="./prepareAlt_output/alt.fasta"
scripts="../../scripts"

# Note:
# - The reference genome (ref_genome) is the same, so no repeated annotation is needed.
# - Use the results from the Human SV Set (already processed) directly for downstream analyses.
ref_genome_annotation_results="../Human_SV_Set"

ln -s ${alt_genome} ./alt.fasta

# 01.RepeatMasker
RepeatMasker -pa 64 -engine ncbi -species human -xsmall -s -no_is -cutoff 255 -frag 20000 -dir ./ -gff alt.fasta

# 02.trf
trf alt.fasta 2 7 7 80 10 50 500 -f -d -h
python ${scripts}/TRF2GFF.py -d alt.fasta.2.7.7.80.10.50.500.dat -o alt.trf.gff

# 03.GenMap
bash ${scripts}/genmap.sh alt.fasta alt.fasta.genmapK50E1

# 04.BISER, fasta.masked is the softmasked FASTA files obtained from the output of 01.RepeatMasker
biser -o alt.fasta.masked.out -t 2 --gc-heap 32G alt.fasta.masked

# 05.svlearn svFeature
svlearn svFeature \
        --ref_sv_vcf ./prepareAlt_output/ref_sorted_format_filtered_sv.vcf \ # output of 1. Create Alt Genome
        --alt_sv_bed ./prepareAlt_output/alt_sorted_format_filtered_sv.bed \ # output of 1. Create Alt Genome
        --ref_rm ${ref_genome_annotation_results}/ref.fasta.out \
        --alt_rm alt.fasta.out \ # 01.RepeatMasker output in alt.fasta
        --ref_trf ${ref_genome_annotation_results}/ref.trf.gff \
        --alt_trf alt.trf.gff \
        --ref_genmap ${ref_genome_annotation_results}/ref.fasta.genmapK50E1.txt \
        --alt_genmap alt.fasta.genmapK50E1.txt \
        --ref_biser ${ref_genome_annotation_results}/ref.fasta.masked.out \
        --alt_biser alt.fasta.masked.out \
        --out sv_feature.tsv
