#!/bin/bash

set -x
set -e
set -u
set -o pipefail


cpus=`grep -c ^processor /proc/cpuinfo`

PROJECT=/projects/coral-microbiome/

# in=$1
in=coral-microbiome

rm -fr $PROJECT/$in"_files"
rm -fr $PROJECT/$in.html
rm -fr $PROJECT/$in.md

rm -fr $PROJECT/tree/$in.fas
rm -fr $PROJECT/tree/$in.aln
rm -fr $PROJECT/tree/$in.trimmed.aln
rm -fr $PROJECT/tree/$in.tre

cd $PROJECT/tree/

seqkit grep -f $in.txt $PROJECT/sequences/db.fas > $in.fas

mafft-ginsi --reorder --maxiterate 1000 --thread $cpus $in.fas > $in.aln

trimal -in $in.aln -out $in.trimmed.aln -gappyout

FastTreeMP -gamma -nt -gtr -slow -notop -nj -boot 1000 $in.trimmed.aln > $in.tre

Rscript -e 'rmarkdown::render("/projects/coral-microbiome/coral-microbiome.Rmd")'


cd $PROJECT/
git add --all ; git commit -m 'auto-commit' ; git push

