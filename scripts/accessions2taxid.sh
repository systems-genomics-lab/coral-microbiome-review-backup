#!/bin/bash

set -x
set -e
set -u
set -o pipefail

cat ../silva/coral-microbiome.txt | sed 's/\..*//g' | sort -u > accessions.txt

zgrep -w -f accessions.txt /data/taxonomy/2022.07/nucl.accession2taxid.gz | cut -f 1,3 | sort -u | sed '1iaccession\ttaxid' > accessions2taxid.tsv

wc -l accessions.txt
wc -l accessions2taxid.tsv
