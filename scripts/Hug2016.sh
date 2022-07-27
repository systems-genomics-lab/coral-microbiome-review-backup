#!/bin/bash

set -x
set -e
set -u
set -o pipefail


cpus=`grep -c ^processor /proc/cpuinfo`

PROJECT=/projects/coral-microbiome/

# in=$1
in=coral-microbiome

cd $PROJECT/Hug2016/


# Download the rRNA alignment published in Hug et al 2016
wget -O Hug2016.original.aln -t 0 https://static-content.springer.com/esm/art%3A10.1038%2Fnmicrobiol.2016.48/MediaObjects/41564_2016_BFnmicrobiol201648_MOESM208_ESM.txt

# Clean up the ids of the sequences in the alignment
cat Hug2016.original.aln | sed 's/,.*//g' | sed 's/__/;/g' | sed 's/;/_/g' | sed -e ':loop' -e 's/>\(.*\)-\(.*\)/>\1_\2/g' -e 't loop' > Hug2016.aln

grep '>' Hug2016.original.aln | sort -u | wc -l
grep '>' Hug2016.aln | sort -u | wc -l

# Collected ids from Hug et al 2016
grep '>' Hug2016.aln | sed 's/>//g' | sort -u > Hug2016.txt

# Remove ambiguous sequences
set +e
cat Hug2016.txt | grep -v -i uncultured Hug2016.txt | grep -v -i unclassified | awk '{if (length($1) > 30) print $1;}' |  sort -u > Hug2016.filtered.txt
set -e
seqkit grep -f Hug2016.filtered.txt Hug2016.aln > Hug2016.filtered.aln

# Copy the clustered beneficial sequences
cat ../sequences/beneficial_clustered.fas | sed 's/__/_/g' > beneficial.fas
grep '>' beneficial.fas | sed 's/>//g' | sort -u > beneficial.txt

# Copy the clustered parasitic (pathogenic) sequences
cat ../sequences/pathogenic_clustered.fas | sed 's/__/_/g' > parasitic.fas
grep '>' parasitic.fas | sed 's/>//g' | sort -u > parasitic.txt

# Build the relationship table
cp relationships_init.tsv relationships.tsv
cat beneficial.txt | awk '{print $1"\tBeneficial"}' >> relationships.tsv
cat parasitic.txt | awk '{print $1"\tParasitic"}' >> relationships.tsv
grep -f Symbiodinium.txt Hug2016.filtered.txt  | awk '{print $1"\tSymbiodinium-associated"}' >> relationships.tsv

# Compile all coral microbiome (beneficial, parasitic, and Symbiodinium-associated) into a single fasta file
cp coral-microbiome_init.fas coral-microbiome.fas
cat beneficial.fas >> coral-microbiome.fas
cat parasitic.fas >> coral-microbiome.fas

cd $PROJECT/
git add --all ; git commit -m 'Added Hug et al 2016 alignment' ; git push
