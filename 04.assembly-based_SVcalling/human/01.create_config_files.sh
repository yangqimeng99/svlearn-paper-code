#!/bin/bash

echo -e "NAME\tHAP1\tHAP2" > assemblies.tsv

for i in `cat ../../01.data_download/human/15human.list.tsv`
do 
	echo -e "${i}\t../../01.data_download/human/haplotype_genomes/${i}.paternal.f1_assembly_v2_genbank.fa.gz\t../../01.data_download/human/haplotype_genomes/${i}.maternal.f1_assembly_v2_genbank.fa.gz"
done >> assemblies.tsv
