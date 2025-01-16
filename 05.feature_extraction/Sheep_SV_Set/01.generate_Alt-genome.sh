#!/bin/bash

ref_genome="../../01.data_download/sheep/reference_genomes/sheep_ARS-UI_Ramb_v2.0_GCA_016772045.1_REF.fasta"
sv_set="../../02.long-reads_mapping_SVcalling/sheep/Sheep_SV_Set.vcf"

svlearn prepareAlt \
	--ref_fasta ${ref_genome} \
	--ref_sv_vcf ${sv_set} \
	--min-distance 300 \
	--out prepareAlt_output
