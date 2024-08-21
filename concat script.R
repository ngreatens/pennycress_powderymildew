setwd("C:/Users/Nicholas.Greatens/OneDrive - USDA/Desktop/pennycress")
library(seqinr)
library(readxl)

#replace "N"s or "-"s with "?"s when on ends of sequences

library(seqinr)
fasta <- read.fasta("alignment.fasta")

#erase previous contents of file
cat("", file = "alignment_ntoq.fasta", append = FALSE)

#replace "N"s or "-"s with "?"s when on ends of sequences
for (i in 1:length(fasta))
{
  name <- names(fasta[i])
  seq <- ""
  seq_len <- length(fasta[[i]])
  for (j in 1:seq_len)
  {
    if(fasta[[i]][j] == "-")
    {
      fasta[[i]][j]<- "?"
    }
    else break
  }
  for (j in 1:seq_len)
  {
    if(fasta[[i]][seq_len + 1 - j] == "-")
    {
      fasta[[i]][seq_len + 1 - j]<- "?"
    }
    else break
  }
  for (j in 1:seq_len)
  {
    seq <- paste0(seq,fasta[[i]][j], collapse = ",")
  }
  cat(paste0(">", name, "\n", seq, "\n"), file = "alignment_ntoq.fasta", append = TRUE)
}

#use single fasta with all seqs combined after alignment. Seqs in a single alignment should be
#of one length. e.g. everything ITS is 700 bp. Everything ef1a is 900, etc.
fasta <- read.fasta(file = "alignment_ntoq.fasta")
align_table <- read.csv("erysiphe_pennycress_datatable.csv")

#subset table to remove unneded cols
align_table <- align_table[,c(1,10:15)]

#get size of table
nrows <- nrow(align_table)
ncols <- ncol(align_table)

#make table with  the lengths of sequences, if present.
len_table <- data.frame(matrix(ncol = ncols, nrow = nrows))
colnames(len_table)<- colnames(align_table)
len_table[,1]<-align_table[,1]
for (i in 1:nrows)
{
  for (j in 2:ncols)
  {
    str <- as.character(align_table[i,j])
    len_table[i,j] = length(fasta[[str]][1:length(fasta[[str]])])
  }
}

#make new fasta file with qs

#erase previous contents of file
cat("", file = "alignment_w_qs.fasta", append = FALSE)

#for samples with missing data, add fasta sequences
for (i in 1:nrows){
  for (j in 2:ncols){
    if(len_table[i,j] == 0){
      loc_len <- max(len_table[j])
      samplename <- align_table[i,1]
      str <- paste0(samplename, "_", colnames(align_table)[j], "_missing_data", collapse = ",")
      seq = ""
      for(k in 1:loc_len){seq<-paste0(seq, "?", collapse = ",")}
      align_table[i,j] <- str
      cat(paste0(">", str, "\n", seq, "\n"), file = "alignment_w_qs.fasta", append = TRUE)
    } else{
      str <-align_table[i,j]
      seq = ""
      seq_len <- length(fasta[[as.character(align_table[i,j])]])
      for(k in 1:seq_len){seq <- paste0(seq, fasta[[as.character(align_table[i,j])]][k], collapse = ",")}
      cat(paste0(">", str, "\n", seq, "\n"), file = "alignment_w_qs.fasta", append = TRUE)
    }
    
  }
}

##next step concatenate relevant sequences

#erase previous contents of file
cat("", file = "concat.fasta", append = FALSE)

#read in fasta file again, now with missing seqs as ???s
fasta <- read.fasta(file = "alignment_w_qs.fasta")
for (i in 1:nrows)
  {
  concatseq <- ""
  samplename <- align_table[i,1]
  for (j in 2:ncols)
    {
     seq = ""
     seq_len <- length(fasta[[as.character(align_table[i,j])]])
     for(k in 1:seq_len){seq <- paste0(seq, fasta[[as.character(align_table[i,j])]][k], collapse = ",")}
     concatseq <- paste0(concatseq, seq, collapse = ",") 
    }
  cat(paste0(">", samplename, "\n", concatseq, "\n", collapse = ","), file = "concat.fasta", append = TRUE)
  }


#check length of concat files
concat_fasta <- read.fasta(file = "concat.fasta")
concat_summary <- data.frame(matrix(ncol = 2, nrow = length(concat_fasta)))
colnames(concat_summary) <- c("sample", "seq_length")
for (i in 1 : length(concat_fasta))
  {
  concat_summary[i,1]<-names(concat_fasta[i])
  concat_summary[i,2]<-length(concat_fasta[[i]])
  }

#print length of loci
align_summmary <- data.frame(matrix(nrow = ncols-1, ncol = 3))
colnames(align_summmary) <- c("sample", "number of bases", "position in alignment")
minpos <- 1
for (i in 1:nrow(align_summmary))
{
   align_summmary[i,1]<-colnames(align_table)[i+1]
   align_summmary[i,2]<- max(len_table[,(i+1)])
   maxpos <- minpos + align_summmary[i,2] - 1
   align_summmary[i,3] <- paste0(minpos, "-", maxpos, collapse = ",")
   minpos <- minpos + align_summmary[i,2]
}

# print partitions file
cat("#nexus\n", file = "partitions.nexus", append = FALSE)
cat("begin sets;\n", file = "partitions.nexus", append = TRUE)
for (i in 1 : nrow(align_summmary)){
  locus = align_summmary[i,1]
  pos = align_summmary[i,3]
  cat(paste0("\tcharset ", locus, " = ", pos,";\n", collapse = ","), file = "partitions.nexus", append = TRUE)
}
cat("end;", file = "partitions.nexus", append = TRUE)
