import pandas as pd
import glob
import argparse

def merge_confusion_matrices(file_pattern, output_file):
    tools = ["svlearn_24", "svlearn_18", "paragraph", "bayestyper", "graphtyper", "svtyper"]
    coverage_levels = [30, 20, 10, 5]
    type = ["INS", "DEL"]

    tools_dict = {
        "svlearn_24": "SVLearn_24",
        "svlearn_18": "SVLearn_18",
        "paragraph": "Paragraph",
        "bayestyper": "BayesTyper",
        "graphtyper": "GraphTyper2",
        "svtyper": "SVTyper"
    }

    # Get all files matching the pattern
    file_list = glob.glob(file_pattern)

    # List to store individual dataframes
    df_list = []
    for file in file_list:
        df = pd.read_csv(file, sep='\t')  # Assuming tab-separated values
        df_list.append(df)

    # Combine all dataframes into one
    combined_df = pd.concat(df_list, ignore_index=True)
    
    # Save the combined dataframe to the output file
    combined_df.to_csv(output_file, sep='\t', index=False)
    print(f"Combined data saved to {output_file}")

def main():
    parser = argparse.ArgumentParser(description="Merge confusion matrix data from multiple files.")
    parser.add_argument("file_pattern", type=str, help="File pattern for input files (e.g., ./out/*.confusion_matrix_confusion_matrix.tsv)")
    parser.add_argument("output_file", type=str, help="Output file name (e.g., ./ins_del_confusion_matrix.tsv)")

    args = parser.parse_args()
    
    merge_confusion_matrices(args.file_pattern, args.output_file)

if __name__ == "__main__":
    main()
