for i in $(cat download.file.list.tsv)
do
	aws s3 cp ${i} .
done
