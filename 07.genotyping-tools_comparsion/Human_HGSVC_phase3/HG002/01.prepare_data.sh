#!/bin/bash

ref_genome="../../../../01.data_download/human/reference_genomes/human_GRCh38_full_analysis_set_plus_decoy_hla_REF.fasta"
ref_bam_dir="../../../../03.short-reads_mapping_downsample"
scripts="../../../../scripts"
species="human"
sample="HG002"

# Note:
# - The reference genome (ref_genome) is the same, so no repeated annotation is needed.
# - Use the results from the Human SV Set (already processed) directly for downstream analyses.
ref_genome_annotation_results="../../../../05.feature_extraction/Human_SV_Set/"

for num in 20000 40000 60000 80000 100000 120000 139254
do
    mkdir HG002.SV_25217.REF_HOM_${num}
    cd HG002.SV_25217.REF_HOM_${num}
    # prepare alt
    svlearn prepareAlt \
    	--ref_fasta ${ref_genome} \
    	--ref_sv_vcf ../HG002.SV_25217.REF_HOM_${num}.vcf \
    	--no-filter-overlaps \
    	--out prepareAlt_output
    
    alt_genome="prepareAlt_output/alt.fasta"
    ln -s ${alt_genome} alt.fasta
    prepareAlt_output="./prepareAlt_output"
    
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
            --ref_sv_vcf ${prepareAlt_output}/ref_sorted_format.vcf \ # output of 1. Create Alt Genome
            --alt_sv_bed ${prepareAlt_output}/alt.bed \ # output of 1. Create Alt Genome
            --ref_rm ${ref_genome_annotation_results}/ref.fasta.out \
            --alt_rm alt.fasta.out \ # 01.RepeatMasker output in alt.fasta
            --ref_trf ${ref_genome_annotation_results}/ref.trf.gff \
            --alt_trf alt.trf.gff \
            --ref_genmap ${ref_genome_annotation_results}/ref.fasta.genmapK50E1.txt \
            --alt_genmap alt.fasta.genmapK50E1.txt \
            --ref_biser ${ref_genome_annotation_results}/ref.fasta.masked.out \
            --alt_biser alt.fasta.masked.out \
            --out sv_feature.tsv
    
    # mapping_alt_bam
    # index for alt_genome
    bwa-mem2.avx512bw index ${alt_genome}
    # mapping
    for coverage in 30 20 10 5
    do
    	bash ${scripts}/bwa_dedup.sh \
    		../../../../03.short-reads_mapping_downsample/${species}/${sample}_${coverage}_R1.fq.gz \
    		../../../../03.short-reads_mapping_downsample/${species}/${sample}_${coverage}_R2.fq.gz \
    		${alt_genome} \
    		${sample}_${coverage}_alt
    done
    
    
    
     
    for coverage in 30 20 10 5
    do
    	# svlearn Alignment feature
    	svlearn alignFeature \
    		--ref_fasta ${ref_genome} \
    		--alt_fasta ${alt_genome} \
    		--ref_sv_vcf ${prepareAlt_output}/ref_sorted_format.vcf \
    		--alt_sv_bed ${prepareAlt_output}/alt.bed \
    		--ref_bam ${ref_bam_dir}/${species}/${sample}_${coverage}.dedup.sort.bam \
    		--alt_bam ./${sample}_${coverage}_alt.dedup.sort.bam \
    		--threads 6 \
    		--out ${sample}_${coverage}.alignFeature
    	
    	# svlearn Paragraph feature
    	svlearn runParagraph \
    		--ref_fasta ${ref_genome} \
    		--alt_fasta ${alt_genome} \
    		--ref_sv_vcf ${prepareAlt_output}/ref_sorted_format.vcf \
    		--alt_sv_vcf ${prepareAlt_output}/alt_sorted_format.vcf \
    		--ref_bam ${ref_bam_dir}/${species}/${sample}_${coverage}.dedup.sort.bam \
    		--alt_bam ./${sample}_${coverage}_alt.dedup.sort.bam \
    		--threads 6 \
    		--out ${sample}_${coverage}.paraFeature
    done
    
    
    
    # prepare other tools input file
    
    # graphtyper
    grep -v -E 'alt|_decoy|chrEBV|HLA-' ${ref_genome}.fai | awk '{print $1":0-"$2}' > GRCh38.genotyping_sv.region
    bgzip -c ${prepareAlt_output}/ref_sorted_format.vcf > graphtyper.ref_sorted_format.vcf.gz
    bcftools index graphtyper.ref_sorted_format.vcf.gz
    
    #bayestyper
    bcftools norm -m+ -o bayestyper.ref_sorted_format_multi_allelic.vcf -O z ${prepareAlt_output}/ref_sorted_format.vcf
    
    #svtyper
    bcftools view -i 'SVTYPE="DEL"' ${prepareAlt_output}/ref_sorted_format.vcf | bcftools +fill-tags - -- -t END | awk '{if($0 ~ /^#/) print $0; else print $0 ";CIPOS=-100,100;CIEND=-100,100"}' > svtyper.ref_sorted_format_filtered_del_ann.vcf
    
    bcftools view -i 'SVTYPE="DEL"' ${prepareAlt_output}/alt_sorted_format.vcf | awk '{if($0 ~ /^#/) print $0; else print $0 ";CIPOS=-100,100;CIEND=-100,100"}' > svtyper.alt_sorted_format_filtered_ins_ann.vcf
    cd ../
done
