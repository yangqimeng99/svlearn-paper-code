raw_fq_r1=$1
raw_fq_r2=$2
clean_fq_prefix=$3

fastp \
        -i ${raw_fq_r1} \
        -I ${raw_fq_r2} \
        -o ${clean_fq_prefix}_R1.fq.gz \
        -O ${clean_fq_prefix}_R2.fq.gz \
        --html ${clean_fq_prefix}.fastp.html \
        --json ${clean_fq_prefix}.fastp.json \
        --thread 6
