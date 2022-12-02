# DE analysis of E.coli wild type and slyA mutant straints

```{r load_libs}
print("Hello Differential Gene Expression!")

knitr::opts_knit$set(root.dir = '../../')

## Setup
### Bioconductor and CRAN libraries used
library(DESeq2)
library(tidyverse)
library(RColorBrewer)
library(pheatmap)
library(DEGreport)
library(tximport)
library(ggplot2)
library(ggrepel)
```


```{python}
import pandas as pd

os.getcwd()

gen = pd.read_table("../data/reference/reference_ecoli_k12/genomic.gff", skiprows = 3, sep='\t', header = None)
gen.head()

cds = gen[gen.iloc[:,2] == "CDS"]
cds

```

```{r load_files}
#List the quants file from Salmon
getwd()
files <- dir("../map/alignment", recursive = TRUE, pattern = "quant.sf", full.names = TRUE)

names(files) <- dir("../map/alignment")

```


```{r import txi}
txi <- tximport(files,, type = "salmon")
```