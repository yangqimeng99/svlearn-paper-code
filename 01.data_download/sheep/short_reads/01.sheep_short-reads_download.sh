for R1 in $(grep -v '#' download.file.list.tsv | cut -f5)
do
	wget ${R1}
done

for R2 in $(grep -v '#' download.file.list.tsv | cut -f6)
do
	wget ${R2}
done

