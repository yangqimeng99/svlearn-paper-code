#!/bin/bash

scripts="../../../scripts"

wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/016/772/045/GCA_016772045.1_ARS-UI_Ramb_v2.0/GCA_016772045.1_ARS-UI_Ramb_v2.0_genomic.fna.gz

gunzip GCA_016772045.1_ARS-UI_Ramb_v2.0_genomic.fna.gz

python ${scripts}/ChangeChrNameInFaOrGff.py -i GCA_016772045.1_ARS-UI_Ramb_v2.0_genomic.fna --fa -n sheep_chr_rename.list -o sheep_ARS-UI_Ramb_v2.0_GCA_016772045.1_REF.fasta

samtools faidx sheep_ARS-UI_Ramb_v2.0_GCA_016772045.1_REF.fasta

# for bayestyper running,generate two new fasta file
for i in {1..26} X Y;do echo chr${i};done > chr_seq.list
for i in {1..26} X Y;do seqkit grep -p chr${i} sheep_ARS-UI_Ramb_v2.0_GCA_016772045.1_REF.fasta >> sheep.canon.fasta;done
cut -f1 sheep_ARS-UI_Ramb_v2.0_GCA_016772045.1_REF.fasta.fai | grep -v -w -f chr_seq.list - | seqkit grep -f - sheep_ARS-UI_Ramb_v2.0_GCA_016772045.1_REF.fasta > sheep.decoy.fasta
samtools faidx sheep.canon.fasta
samtools faidx sheep.decoy.fasta

