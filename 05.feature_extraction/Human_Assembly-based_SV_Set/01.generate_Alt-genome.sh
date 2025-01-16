#!/bin/bash

ref_genome="../../01.data_download/human/reference_genomes/human_GRCh38_full_analysis_set_plus_decoy_hla_REF.fasta"
sv_set="../../04.assembly-based_SVcalling/human/Human_Assembly-based_SV_Set.vcf"

svlearn prepareAlt \
	--ref_fasta ${ref_genome} \
	--ref_sv_vcf ${sv_set} \
	--min-distance 300 \
	--out prepareAlt_output
