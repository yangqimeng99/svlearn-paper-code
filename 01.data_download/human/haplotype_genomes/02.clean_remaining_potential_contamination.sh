# remove remaining potential contamination contigs
data_files=("HG002.paternal.f1_assembly_v2_genbank.fa.gz" "HG002.maternal.f1_assembly_v2_genbank.fa.gz" "HG01109.paternal.f1_assembly_v2_genbank.fa.gz" "HG01109.maternal.f1_assembly_v2_genbank.fa.gz" "HG03492.paternal.f1_assembly_v2_genbank.fa.gz" "HG01361.paternal.f1_assembly_v2_genbank.fa.gz" "HG03516.paternal.f1_assembly_v2_genbank.fa.gz")

for file in "${data_files[@]}"; do
    mv "$file" ./down_remaining_potential_contamination/
done


samples=("HG002_1 HG002.paternal.f1_assembly_v2_genbank.fa.gz" \
         "HG002_2 HG002.maternal.f1_assembly_v2_genbank.fa.gz" \
         "HG01109_1 HG01109.paternal.f1_assembly_v2_genbank.fa.gz" \
         "HG01109_2 HG01109.maternal.f1_assembly_v2_genbank.fa.gz" \
         "HG03492_1 HG03492.paternal.f1_assembly_v2_genbank.fa.gz" \
         "HG01361_1 HG01361.paternal.f1_assembly_v2_genbank.fa.gz" \
         "HG03516_1 HG03516.paternal.f1_assembly_v2_genbank.fa.gz")

for sample_info in "${samples[@]}"; do
    read -r sample file <<< "$sample_info"
    grep "$sample" remaining_potential_contamination.list.tsv | cut -f2 | \
    seqkit grep -f - -v "./down_remaining_potential_contamination/$file" | gzip - > "./$file"
done
