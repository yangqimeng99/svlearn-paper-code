# GRCh38
wget https://ftp.ncbi.nlm.nih.gov/1000genomes/ftp/technical/reference/GRCh38_reference_genome/GRCh38_full_analysis_set_plus_decoy_hla.fa
mv GRCh38_full_analysis_set_plus_decoy_hla.fa human_GRCh38_full_analysis_set_plus_decoy_hla_REF.fasta
samtools faidx human_GRCh38_full_analysis_set_plus_decoy_hla_REF.fasta

# GRCh38.no_alt for PAV
grep -v -E 'alt|_decoy|chrEBV|HLA-' human_GRCh38_full_analysis_set_plus_decoy_hla_REF.fasta.fai | cut -f1 > GRCh38.no_alt.list
samtools faidx human_GRCh38_full_analysis_set_plus_decoy_hla_REF.fasta -r GRCh38.no_alt.list > GRCh38.no_alt.fa
samtools faidx GRCh38.no_alt.fa

# for bayestyper running,generate two new GRCh38 fasta file
for i in {1..22} X Y;do echo chr${i};done > chr_seq.list
for i in {1..22} X Y;do seqkit grep -p chr${i} human_GRCh38_full_analysis_set_plus_decoy_hla_REF.fasta >> GRCh38.canon.fasta;done
cut -f1 human_GRCh38_full_analysis_set_plus_decoy_hla_REF.fasta.fai | grep -v -w -f chr_seq.list - | seqkit grep -f - human_GRCh38_full_analysis_set_plus_decoy_hla_REF.fasta > GRCh38.decoy.fasta
samtools faidx GRCh38.canon.fasta
samtools faidx GRCh38.decoy.fasta

# GRCh37 hs37d5.fa
wget https://ftp.ncbi.nlm.nih.gov/1000genomes/ftp/technical/reference/phase2_reference_assembly_sequence/hs37d5.fa.gz .
gunzip hs37d5.fa.gz
samtools faidx hs37d5.fa

# for bayestyper running,generate two new GRCh37 fasta file
for i in {1..22} X Y;do echo chr${i};done > chr_seq.list
for i in {1..22} X Y;do seqkit grep -p chr${i} hs37d5.fa >> hs37d5.canon.fasta;done
cut -f1 hs37d5.fa.fai | grep -v -w -f chr_seq.list - | seqkit grep -f - hs37d5.fa > hs37d5.decoy.fasta
samtools faidx hs37d5.canon.fasta
samtools faidx hs37d5.decoy.fasta
