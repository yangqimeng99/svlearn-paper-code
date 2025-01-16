#!/bin/bash

inputBAM=$1
prefix=$2

mosdepth --threads 4 \
	--fast-mode \
	--no-per-base \
	--by 300 \
	${prefix} \
	${inputBAM}

