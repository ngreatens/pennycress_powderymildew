## manually fill out excel table

1. copied sample info and sequence accessions from reference. excel formatted in anticipation of use with ggtree 

## in ncbi 

* download seqs into files: its.fasta, btub.fasta, etc.

## in terminal, using bioawk, muscle

* download seqs into files: its.fasta, btub.fasta, etc.
* remove comments

```
for file in *fasta; do bioawk -c fastx '{print ">"$name"\n"$seq}' $file > $(basename $file .fasta)_nocomments.fna; done
```

*  muscle align each locus

```
for file in *fna; do muscle -align $file -output $(basename $file _nocomments.fna)_aligned.fasta; done
```

*  concat aligned seqs 

```
cat *aligned.fasta >> alignment.fasta
```

* manually edit seqs as needed to correct for obvious misalignments. in this case, I only removed basepairs that were trailing long after the sequences. e.g. I removed the last c here. 

```
>OR427778.1
ACTGTTGTGGAGCCCTACAACGCAACCCTTTCTGTTCATCAACTTGTCGAAAACTCTGACGAGACTTTCTGTATTGACAA
TGAAGCACTCTATGAAATATGTATGAGAACTTTAAAGCTCTCGAATCCATCTTATGGTGATCTCAATCATTTGGTATCTG
CTGTCATGTCAGGTGTAACAACTTGTCTTCGTTTCCCAGGTCAACTCAACTCAGATCTTAGAAAACTGGCGGTTAACATG
GTTCCATTTCCTCGT-----------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-------------------------------------------C
```

## in r

run alignment through custom r script (concat.r) to: 
* change dashes to ?s when on beginning or end of sequences. Doesn't matter to iqtree, but important for mrbayes
* concatenate alignments with missing sequences replaced by ??s

## convert alignment to 



