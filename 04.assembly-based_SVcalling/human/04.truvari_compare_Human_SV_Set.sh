#!/bin/bash

bgzip -c ../../02.long-reads_mapping_SVcalling/human/Human_SV_Set.vcf > Human_SV_Set.vcf.gz
tabix Human_SV_Set.vcf.gz

bcftools sort Human_Assembly-based_SV_Set.vcf | bgzip > Human_Assembly-based_SV_Set.vcf.gz
tabix Human_Assembly-based_SV_Set.vcf.gz

conda activate truvari
truvari bench -r 500 -p 0 -P 0.5 -s 50 --sizemax 1000000 \
	-b Human_SV_Set.vcf.gz \
	-c Human_Assembly-based_SV_Set.vcf.gz \
	--output compare_Human_SV_Set_r500
