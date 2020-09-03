library(shiny)
library(Rtsne)
library(digest)

if (Sys.getenv("KNNVIEW_DIR") == "")
    stop("The variable KNNVIEW_DIR must be set in the environment, see https://github.com/eitanyaffe/knnview")

# load knnview code
source(paste0(Sys.getenv("KNNVIEW_DIR"), "/knnview.r"))

# de-randomize results
set.seed(1)

# get sample table
df = read.table(paste0(Sys.getenv("KNNVIEW_DIR"), "/examples/df.tab"))

# get distance matrix
D = readRDS(paste0(Sys.getenv("KNNVIEW_DIR"), "/examples/D.rds"))

# init
knnview.init(k=10, df=df, D=D, field.id="sample", field.cluster="cluster", use.df.xy=T)
