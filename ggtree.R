#load packages
library(ggtree)
library(readxl)
library(glue)
library(treeio)

#read in tree
tree <- read.iqtree("tree.nwk")


#read in csv
df <-read.csv("erysiphe_pennycress_datatable.csv")

#use glue to make new label
df <- dplyr::mutate(df, lab = glue("~{Sample_ID}~{Location}~on~italic({Host})~{nonitalic}~{subsp}"))

#get bootstrap values
q <- ggtree(tree)
d <- q$data
#select internal nodes
d <- d[!d$isTip,]
#convert to numeric
d$UFboot <- as.numeric(d$UFboot)
d80 <- d[d$UFboot>=80,]

cladeoffset=0.0425

#tree
p<- ggtree(tree)  %<+% df +
  geom_tiplab(
    aes(label = lab), 
    linesize = .15,
    geom = "label",
    label.size = 0,
    label.padding = unit(0, "lines"),
    parse = TRUE,
    size = 2.5,
    show.legend = FALSE,
    align = FALSE
  ) +
  geom_cladelab(node=26, label = " Erysiphe alliariicola", offset = cladeoffset,  align = TRUE, fontface=3, fontsize = 2.5) +
  geom_cladelab(node=31, label = " Erysiphe crucifearum", offset = cladeoffset, fontsize = 2.5, align = TRUE, fontface=3) +
  geom_cladelab(node=22, label = " Erysiphe radulescui", offset = cladeoffset, fontsize = 2.5, align = TRUE, fontface=3) +
  geom_striplab('s1','s2', label = " Erysiphe intermedia", offset = cladeoffset, fontsize = 2.5, align = TRUE, fontface=3) +
  xlim(0,.1) + 
  geom_text2(data = d80, aes(label = UFboot), size = 2, hjust = 1.2, vjust = -.5) 
#save to tif image file.
p
