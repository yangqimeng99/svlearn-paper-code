#!/bin/bash

sample_list="../../01.data_download/human/15human.list.tsv"
scripts="../../scripts"

ref_bam_dir="../../03.short-reads_mapping_downsample/human"

# create ref-based SV bed 
bcftools query \
	-f '%CHROM\t%POS0\t%END\t%ID\t%SVTYPE\n' \
	./prepareAlt_output/ref_sorted_format_filtered_sv.vcf \
	> ref.sv.bed

# link alt-based SV bed
ln -s ./prepareAlt_output/alt_sorted_format_filtered_sv.bed ./alt.sv.bed

# Count the number of mapped short reads at SV sites in ref and ref+alt BAM files under 30x coverage
coverage="30"
output_tsv="mapped_reads_summary.tsv"
echo -e "Sample\tRef_DEL\tRef_Alt_DEL\tRef_INS\tRef_Alt_INS" > ${output_tsv}

while read sample
do
	python ${scripts}/mapped-reads_count.py \
		--ref_bam ${ref_bam_dir}/${sample}_${coverage}.dedup.sort.bam \
		--alt_bam ./${sample}_${coverage}_alt.dedup.sort.bam \
		--ref_sv_bed ./ref.sv.bed \
		--alt_sv_bed ./alt.sv.bed \
		--prefix ${sample}

	ref_del=$(awk '$7=="DEL" && $4 != 0' "${sample}_ref_sv_reads_info.tsv" | wc -l)
	ref_alt_del=$(awk '$7=="DEL" && $4 != 0' "${sample}_ref_alt_sv_reads_info.tsv" | wc -l)

	ref_ins=$(awk '$7=="INS" && $4 != 0' "${sample}_ref_sv_reads_info.tsv" | wc -l)
	ref_alt_ins=$(awk '$7=="INS" && $4 != 0' "${sample}_ref_alt_sv_reads_info.tsv" | wc -l)

	echo -e "${sample}\t${ref_del}\t${ref_alt_del}\t${ref_ins}\t${ref_alt_ins}" >> ${output_tsv}
done < ${sample_list}
