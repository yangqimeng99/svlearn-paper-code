wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR398/001/ERR3988781/ERR3988781_1.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR398/001/ERR3988781/ERR3988781_2.fastq.gz

bash scripts/fastp.sh ERR3988781_1.fastq.gz ERR3988781_2.fastq.gz HG00514
