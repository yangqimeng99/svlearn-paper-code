#!/bin/bash
docker run \
	--name human_pav --rm \
	-v ${PWD}:${PWD} \
	-w ${PWD} \
	becklab/pav:2.3.4 \
	-c 64
