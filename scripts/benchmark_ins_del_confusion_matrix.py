import sys
import pysam
import argparse
import pandas as pd
import polars as pl
from datetime import datetime
from sklearn.metrics import confusion_matrix
import matplotlib.pyplot as plt
import seaborn as sns


def plot_confusion_matrix(true_labels, pred_labels, output_base, title, xlabel="Predicted Genotype", tool_name="DefaultTool", coverage=10, sv_type="SV"):
	labels = ["0/0", "0/1", "1/1"]
	cm = confusion_matrix(true_labels, pred_labels, labels=labels, normalize='true')

	rows = []
	for i, true_label in enumerate(labels):
		for j, pred_label in enumerate(labels):
			rows.append({
				"True": true_label,
				"Pred": pred_label,
				"Value": round(cm[i, j], 4), 
				"Tool": tool_name,
				"Coverage": coverage,
				"SV_Type": sv_type
			})
	tsv_file = f"{output_base}_confusion_matrix.tsv"
	pd.DataFrame(rows).to_csv(tsv_file, sep='\t', index=False)
	print(f"Confusion matrix saved as TSV: {tsv_file}")

	plt.figure(figsize=(6, 5))
	sns.heatmap(
		cm,
		annot=True,
		fmt='.4f',
		cmap='Blues',
		xticklabels=labels,
		yticklabels=labels,
		cbar=True,
		vmin=0,
		vmax=1,
		cbar_kws={"ticks": [i / 10 for i in range(11)]}
	)
	plt.title(title)
	plt.xlabel(xlabel)
	plt.ylabel("True Genotype")
	plt.tight_layout()

	plt.rcParams['pdf.fonttype'] = 42
	plt.savefig(f"{output_base}.pdf", format='pdf', dpi=300)
	plt.savefig(f"{output_base}.png", format='png', dpi=300)
	plt.close()
	print(f"Confusion matrix saved as {output_base}.pdf and {output_base}.png")


def get_benchmark_info(genotype_df, benchmark_out_file, cm_output_base, cm_title, cm_xlabel, tool, Coverage, sv_type):
	benchmark_result = {}
	sv_set_num = len(genotype_df)
	benchmark_result['sv_set_number'] = sv_set_num

	genotyped_df = genotype_df.filter(pl.col("GT_pred") != "./.")
	genotyped_sv_num = len(genotyped_df)
	benchmark_result['genotyped_sv_number'] = genotyped_sv_num

	genotype_rate = (genotyped_sv_num / sv_set_num)
	benchmark_result['genotype_rate'] = round(genotype_rate, 4)

	genotype_df_right = genotype_df.filter(pl.col('GT_pred') == pl.col('GT_true'))
	accuracy_genotyped_sv_number = len(genotype_df_right)
	benchmark_result['accuracy_genotyped_sv_number'] = accuracy_genotyped_sv_number

	true_labels = genotype_df['GT_true'].to_list()
	pred_labels = genotype_df['GT_pred'].to_list()
	plot_confusion_matrix(true_labels, pred_labels, cm_output_base, cm_title, cm_xlabel, tool, Coverage, sv_type)

	genotype_df_pred_01_11 = genotype_df.filter(pl.col('GT_pred') != './.').filter(pl.col('GT_pred') != '0/0')
	genotype_df_pred_01_11_accuracy = genotype_df_pred_01_11.filter(pl.col('GT_true') == pl.col('GT_pred'))

	precision_GT = len(genotype_df_pred_01_11_accuracy) / len(genotype_df_pred_01_11)
	benchmark_result['precision_GT'] = round(precision_GT, 4)

	genotype_df_true_01_11 = genotype_df.filter(pl.col('GT_true') != './.').filter(pl.col('GT_true') != '0/0')
	genotype_df_true_01_11_accuracy = genotype_df_true_01_11.filter(pl.col('GT_true') == pl.col('GT_pred'))
	recall_GT = len(genotype_df_true_01_11_accuracy) / len(genotype_df_true_01_11)
	benchmark_result['recall_GT'] = round(recall_GT, 4)

	f1_GT = (2 * precision_GT * recall_GT) / (precision_GT + recall_GT)
	benchmark_result['f1_GT'] = round(f1_GT, 4)

	genotype_df_pred_01_11_accuracy_2 = (genotype_df_pred_01_11
										 .filter(pl.col('GT_true') != '0/0')
										 .filter(pl.col('GT_true') != './.'))
	precision = len(genotype_df_pred_01_11_accuracy_2) / len(genotype_df_pred_01_11)
	benchmark_result['precision'] = round(precision, 4)

	genotype_df_true_01_11_accuracy_2 = (genotype_df_true_01_11
										 .filter(pl.col('GT_pred') != '0/0')
										 .filter(pl.col('GT_pred') != './.'))
	recall = len(genotype_df_true_01_11_accuracy_2) / len(genotype_df_true_01_11)
	benchmark_result['recall'] = round(recall, 4)

	f1 = (2 * precision * recall) / (precision + recall)
	benchmark_result['f1'] = round(f1, 4)

	genotype_df_00 = genotype_df.filter(pl.col('GT_true') == '0/0').filter(pl.col('GT_pred') != './.')
	genotype_df_00_accuracy = genotype_df_00.filter(pl.col('GT_true') == pl.col('GT_pred'))
	conc_00 = len(genotype_df_00_accuracy) / len(genotype_df_00)
	benchmark_result['conc_00'] = round(conc_00, 4)

	genotype_df_01 = genotype_df.filter(pl.col('GT_true') == '0/1').filter(pl.col('GT_pred') != './.')
	genotype_df_01_accuracy = genotype_df_01.filter(pl.col('GT_true') == pl.col('GT_pred'))
	conc_01 = len(genotype_df_01_accuracy) / len(genotype_df_01)
	benchmark_result['conc_01'] = round(conc_01, 4)

	genotype_df_11 = genotype_df.filter(pl.col('GT_true') == '1/1').filter(pl.col('GT_pred') != './.')
	genotype_df_11_accuracy = genotype_df_11.filter(pl.col('GT_true') == pl.col('GT_pred'))
	conc_11 = len(genotype_df_11_accuracy) / len(genotype_df_11)
	benchmark_result['conc_11'] = round(conc_11, 4)

	wgc = (conc_00 + conc_01 + conc_11) / 3
	benchmark_result['wgc'] = round(wgc, 4)

	current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
	print(current_time, "Verify model effect:")
	with open(benchmark_out_file, "w") as file:
		for key, value in benchmark_result.items():
			print(f"{key}\t{value}")
			file.write(f"{key}  {value}\n")


def main(args=None):
	parser = argparse.ArgumentParser(description="Benchmark the genotyped SV set based SV ID.")
	parser.add_argument("-b", "--base_set", type=str, required=True, help="True sv vcf set", metavar="file")
	parser.add_argument("-c", "--call_set", type=str, required=True, help="Predict sv vcf set", metavar="file")
	parser.add_argument("-n1", "--base_sample_name", type=str, required=True, help="Sample name in true sv vcf set", metavar="str")
	parser.add_argument("-n2", "--call_sample_name", type=str, required=True, help="Sample name in predict sv vcf set", metavar="str")
	parser.add_argument("-o", "--out", type=str, default="benchmark.result.tsv", help="Output benchmark result file")
	parser.add_argument("--cm_out", type=str, default="confusion_matrix", help="Base name for confusion matrix files (PDF and PNG)")
	parser.add_argument("--cm_title", type=str, default="Genotype Confusion Matrix", help="Title for confusion matrix plot")
	parser.add_argument("--cm_xlabel", type=str, default="Predicted Genotype", help="X-axis label for confusion matrix")
	parser.add_argument("--tool", type=str, default="DefaultTool", help="The tool being evaluated")
	parser.add_argument("--coverage", type=str, default="10", help="The Sample coverage being evaluated")
	parser.add_argument("--sv_type", type=str, default="SV", help="The SV type being evaluated")

	parsed_args = parser.parse_args(args=args)
	base_set_file = parsed_args.base_set
	call_set_file = parsed_args.call_set
	base_sample_name = parsed_args.base_sample_name
	call_sample_name = parsed_args.call_sample_name
	benchmark_out_file = parsed_args.out
	cm_output_base = parsed_args.cm_out
	cm_title = parsed_args.cm_title
	cm_xlabel = parsed_args.cm_xlabel
	tool = parsed_args.tool
	coverage = int(parsed_args.coverage)
	sv_type = parsed_args.sv_type

	base_set = pysam.VariantFile(base_set_file, "r")
	call_set = pysam.VariantFile(call_set_file, "r")
	base_call_set = {}

	gt_dict = {
		(0, 1): "0/1",
		(1, 0): "0/1",
		(0, 0): "0/0",
		(1, 1): "1/1",
		(None,): "./.",
	}

	for call_record in call_set:
		call_gt = gt_dict.get(call_record.samples[call_sample_name]['GT'], "./.")
		base_call_set[call_record.id] = [call_gt]

	for base_record in base_set:
		if base_record.id in base_call_set:
			true_gt = gt_dict.get(base_record.samples[base_sample_name]['GT'], "./.")
			base_call_set[base_record.id].insert(0, true_gt)
		else:
			base_call_set[base_record.id] = [true_gt, "./."]

	base_set.close()
	call_set.close()

	sv_id = list(base_call_set.keys())
	true_GT = [value[0] for value in base_call_set.values()]
	pred_GT = [value[1] for value in base_call_set.values()]

	geno_df = pl.DataFrame({
		'sv_id': sv_id,
		'GT_true': true_GT,
		'GT_pred': pred_GT
	})

	geno_df = geno_df.filter(pl.col('GT_true') != './.')

	if len(geno_df) == 0:
		print("No sv can be genotyped.")
		sys.exit(1)

	get_benchmark_info(geno_df, benchmark_out_file, cm_output_base, cm_title, cm_xlabel, tool, coverage, sv_type)

	current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
	print(current_time, "Benchmark result has been saved in", benchmark_out_file)
	print(current_time, "Confusion matrix saved in", f"{cm_output_base}.pdf and {cm_output_base}.png")
	print(current_time, "Benchmark finished.")


if __name__ == "__main__":
	main()
