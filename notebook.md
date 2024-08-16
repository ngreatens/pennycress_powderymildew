## manually fill out excel table

1. copied sample info and sequence accessions from reference. excel formatted in anticipation of use with ggtree 

## in ncbi 

* download seqs into files: its.fasta, btub.fasta, etc.
* manually combine our ITS + LSU, connect by Ns,  to correct aligment later and replace gapwith ??s

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

* manually edit seqs as needed to correct for obvious misalignments
* also replace gaps in our ITS, LSU segment with ?s
* also trim alignments where only one sequence has data


## in r studio

run alignment through custom r script (concat.r) to: 
* change dashes to ?s when on beginning or end of sequences. Doesn't matter to iqtree, but important for mrbayes
* concatenate alignments with missing sequences replaced by ??s
* concatenated alignment (concat.fasta) available in github

## in terminal, use iqtree

* get partitions file with align_summary table output from r script
* use iqtree with partitions, best model as estimated by modelfinder within iqtree, and 1000 bootstraps

```
iqtree2 -s concat.fasta -p partitions.nex -m MFP+MERGE -B 1000
```

## format tree in ggtree

* formatted in ggtree. necessary files in github





