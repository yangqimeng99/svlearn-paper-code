import argparse
import gzip

def process_vcf(input_vcf, output_vcf):
    with gzip.open(input_vcf, 'rt') as infile, gzip.open(output_vcf, 'wt') as outfile:
        prev_pos = None
        records = []

        for line in infile:
            
            if line.startswith('#'):
                outfile.write(line)
                continue

            
            fields = line.strip().split('\t')
            pos = fields[1]  
            id_field = fields[2]  

            
            if pos == prev_pos:
                records.append(fields)
            else:
                
                if prev_pos is not None:
                    process_records(records, outfile)

                
                records = [fields]
                prev_pos = pos

        
        if records:
            process_records(records, outfile)

def process_records(records, outfile):
    
    
    original_id = records[0][2]  
    if ';' in original_id:
        
        split_ids = original_id.split(';')
        if len(split_ids) != len(records):
            
            print(f"Warning: number of records does not match number of IDs - {len(records)} records, {len(split_ids)} IDs")
            print("original record:")
            for record in records:
                print('\t'.join(record))

            
            first_id = split_ids[0]  
            for record in records:
                record[2] = first_id  
                outfile.write('\t'.join(record) + '\n')

            print(f"The ID has been changed to: {first_id} (applies to all records)")
            return

        
        for i, record in enumerate(records):
            record[2] = split_ids[i]  
            outfile.write('\t'.join(record) + '\n')
    else:
        
        for record in records:
            outfile.write('\t'.join(record) + '\n')

def main():
    parser = argparse.ArgumentParser(description="Process VCF file to handle duplicate IDs.")
    parser.add_argument('--input', required=True, help="Path to the input VCF file (gzipped).")
    parser.add_argument('--output', required=True, help="Path to the output VCF file (gzipped).")

    args = parser.parse_args()

    process_vcf(args.input, args.output)

if __name__ == "__main__":
    main()
