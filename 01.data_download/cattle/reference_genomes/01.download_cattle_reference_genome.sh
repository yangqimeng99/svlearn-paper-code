#!/bin/bash

scripts="../../../scripts"

# ARS-UCD1.2
wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/002/263/795/GCF_002263795.1_ARS-UCD1.2/GCF_002263795.1_ARS-UCD1.2_genomic.fna.gz

gunzip GCF_002263795.1_ARS-UCD1.2_genomic.fna.gz

python ${scripts}/ChangeChrNameInFaOrGff.py -i GCF_002263795.1_ARS-UCD1.2_genomic.fna --fa -n cattle_chr_rename.list -o cattle_ARS-UCD2.0_GCF_002263795.3_REF.fasta

samtools faidx cattle_ARS-UCD2.0_GCF_002263795.3_REF.fasta

# for bayestyper running,generate two new fasta file
for i in {1..29} X MT;do echo chr${i};done > chr_seq.list
for i in {1..29} X MT;do seqkit grep -p chr${i} cattle_ARS-UCD2.0_GCF_002263795.3_REF.fasta >> cattle.canon.fasta;done
cut -f1 cattle_ARS-UCD2.0_GCF_002263795.3_REF.fasta.fai | grep -v -w -f chr_seq.list - | seqkit grep -f - cattle_ARS-UCD2.0_GCF_002263795.3_REF.fasta > cattle.decoy.fasta
samtools faidx cattle.canon.fasta
samtools faidx cattle.decoy.fasta

