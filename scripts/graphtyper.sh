sample=$1
coverage=$2
refBam=$3
inputVCF=$4
refFasta=$5
region=$6
threads=$7
outname=${sample}_${coverage}



##Graghtyper
graphtyper genotype_sv ${refFasta} ${inputVCF} --sam=${refBam} --region_file=${region} --output=${outname} --threads=${threads} &> ${outname}_graphtyper_discovery.sv.log
bcftools concat -a ./${outname}/*/*.vcf.gz -O z -o ${outname}_graphtyper.vcf.gz

##filter
bcftools view --include 'SVMODEL="AGGREGATED"' ${outname}_graphtyper.vcf.gz | bcftools annotate --set-id '%INFO/OLD_VARIANT_ID' -O z -o ${outname}_graphtyper_filter.vcf.gz

mv ${outname}_graphtyper_filter.vcf.gz ${sample}.graphtyper.${covergae}.vcf.gz

