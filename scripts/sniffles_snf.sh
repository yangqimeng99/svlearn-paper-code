conda activate sniffles_2.2
inputBam=$1
sample=$2
ref_genome=$3
trf_bed=$4

sniffles --input ${inputBam} --snf ${sample}.snf \
        --reference ${ref_genome} \
        --tandem-repeats ${trf_bed} \
        --threads 16 --minsupport 4 --minsvlen 50
