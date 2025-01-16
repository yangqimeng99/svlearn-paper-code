sample=$1
coverage=$2
refBam=$3
threads=$4
inuptVCF=$5
refCanon=$6
refDecoy=$7
outputPrefix=${sample}_${coverage}


mkdir -p bayestyper_${outputPrefix}
cd bayestyper_${outputPrefix}
echo "${outputPrefix}	M	${outputPrefix}" >> sample.tsv

##refCanon,refDecoy:fasta;sampleTsv:<sample_id>, <sex> and <outputPrefix>
mkdir -p ./kmc_tmp
kmc -k55 -ci1 -fbam ${refBam} ${outputPrefix} ./kmc_tmp
bayesTyperTools makeBloom -k ${outputPrefix} -p ${threads}

bayesTyper cluster -r 10 -v ${inuptVCF} -s sample.tsv -g ${refCanon} -d ${refDecoy} -p ${threads}
bayesTyper genotype -r 10 -v bayestyper_unit_1/variant_clusters.bin -c bayestyper_cluster_data -s sample.tsv -g ${refCanon} -d ${refDecoy} -o bayestyper_unit_1/bayestyper  -z -p ${threads}

# output file splits multiple allelic variants
bcftools norm -m -both -o bayestyper_unit_1/norm_out_bayestyper.vcf.gz -O z bayestyper_unit_1/bayestyper.vcf.gz
bcftools filter -i 'ALT != "*"' bayestyper_unit_1/norm_out_bayestyper.vcf.gz -O z -o bayestyper_unit_1/filter_bayestyper.vcf.gz
python ${scripts}/bayestyper_convert_multiple-alleles_into_biallelic.py --input bayestyper_unit_1/filter_bayestyper.vcf.gz --output bayestyper_unit_1/final_bayestyper.vcf.gz
rm bayestyper_unit_1/filter_bayestyper.vcf.gz #delete process files
rm bayestyper_unit_1/norm_out_bayestyper.vcf.gz #delete process files
mv bayestyper_unit_1/final_bayestyper.vcf.gz ../${sample}.bayestyper.${coverage}.vcf.gz
cd ../




