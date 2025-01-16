#!/bin/bash

ref_genome="../../01.data_download/cattle/reference_genomes/cattle_ARS-UCD2.0_GCF_002263795.3_REF.fasta"
sv_set="../../02.long-reads_mapping_SVcalling/cattle/Cattle_SV_Set.vcf"

svlearn prepareAlt \
	--ref_fasta ${ref_genome} \
	--ref_sv_vcf ${sv_set} \
	--min-distance 300 \
	--out prepareAlt_output
