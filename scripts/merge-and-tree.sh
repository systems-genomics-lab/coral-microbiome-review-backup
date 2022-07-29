#!/bin/bash

set -x
set -e
set -u
set -o pipefail


cpus=`grep -c ^processor /proc/cpuinfo`

PROJECT=/projects/coral-microbiome

# in=$1
in=coral-microbiome

cd $PROJECT/Hug2016/

pwd

# Exclude problematic sequences
set +e
grep -v -f exclude.txt Hug2016.filtered.txt > Hug2016.clean.txt
set -e

seqkit grep -f Hug2016.clean.txt Hug2016.aln > Hug2016.clean.aln

# Merge the coral microbiome sequences to the reference alignment
time mafft --thread $cpus --reorder --adjustdirection --keeplength --compactmapout --anysymbol --ep 0.0 --add $in.fas --globalpair --maxiterate 1000 Hug2016.clean.aln > $in.mafft.add.aln

# Clean up the ids after MAFFT
cat $in.mafft.add.aln | sed 's/>.*|/>/g' > $in.aln

# Build the tree
time FastTreeMP -gamma -nt -gtr -slow -notop -nj -boot 1000 $in.aln > $in.tre
grep '>' $in.aln | sed 's/>//g'	| sort -u > microbiome-coral-tree-seq.txt

cd $PROJECT/
git add --all ; git commit -m 'Finished merge and tree' ; git push
