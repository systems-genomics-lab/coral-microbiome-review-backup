#!/bin/bash

set -x
set -e
set -u
set -o pipefail


cpus=`grep -c ^processor /proc/cpuinfo`

PROJECT=/projects/coral-microbiome/

# in=$1
in=coral-microbiome

cd $PROJECT/silva/

rm -fr $in.fas
rm -fr $in.aln
rm -fr $in.trimmed.aln
rm -fr $in.tre

seqkit grep -f $in.txt /data/silva/SILVA138.fas.gz > $in.fas

mafft --auto --reorder --maxiterate 1000 --thread $cpus $in.fas > $in.aln

trimal -in $in.aln -out $in.trimmed.aln -gappyout

FastTreeMP -gamma -nt -gtr -slow -notop -nj -boot 1000 $in.trimmed.aln > $in.tre

# Rscript -e 'rmarkdown::render("/projects/coral-microbiome/coral-microbiome.Rmd")'

cd $PROJECT/
git add --all ; git commit -m "SILVA-based tree" ; git push

