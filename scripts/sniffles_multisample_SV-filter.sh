conda activate sniffles_2.2

snf_files_list=$1
prefix=$2
ref_genome=$3
trf_bed=$4

sniffles --input ${snf_files_list} \
	--vcf ${prefix}.raw.vcf \
	--reference ${ref_genome} \
	--tandem-repeats ${trf_bed} \
	--threads 12 \
	--minsupport 4 \
	--minsvlen 50

python svlearn-paper-code/scripts/ChangeSnifflesVcfFormat.py \
	-r ${ref_genome} \
	-v ${prefix}.raw.vcf \
	-o ${prefix}.format.vcf

# filter 50bp-1Mb non-missing INS/DEL
bcftools view -i 'SVLEN>=50 || SVLEN<=-50' ${prefix}.format.vcf | \
	bcftools view -i 'F_MISSING=0' | \
	grep -E '#|INS|DEL' | \
	bcftools view -i 'SVLEN>-1000000&&SVLEN<1000000' | \
	bcftools view -i 'CHROM~"^chr[0-9XY]*$"' > ${prefix}.pav.vcf
