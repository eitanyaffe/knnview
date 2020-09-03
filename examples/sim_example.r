library(shiny)
library(Rtsne)
library(MASS)
library(digest)

if (Sys.getenv("KNNVIEW_DIR") == "")
    stop("The variable KNNVIEW_DIR must be set in the environment, see https://github.com/eitanyaffe/knnview")

# load knnview code
source(paste0(Sys.getenv("KNNVIEW_DIR"), "/knnview.r"))

# de-randomize results
set.seed(1)

##########################################################################################
# simulate data
##########################################################################################

sim.data=function(n.clusters, n.samples.per.cluster, sd)
{
    df.clusters = data.frame(x=runif(n.clusters), y=runif(n.clusters))

    df.samples = NULL
    for (i in 1:n.clusters) {
        sid = 1:n.samples.per.cluster + (i-1)*n.samples.per.cluster
        xy = mvrnorm(n=n.samples.per.cluster,
                     mu=c(df.clusters$x[i],df.clusters$y[i]),
                     Sigma=matrix(c(sd^2,0,0,sd^2), 2, 2))
        df.samples.i = data.frame(sample=sid, cluster=i, x=xy[,1], y=xy[,2])
        df.samples = rbind(df.samples, df.samples.i)
    }
    D = as.matrix(dist(as.matrix(df.samples[,c("x", "y")])))
    colnames(D) = df.samples$sample
    rownames(D) = df.samples$sample
    return (list(df=df.samples, D=D))
}
ll = sim.data(n.clusters=10, n.samples.per.cluster=40, sd=0.03)

##########################################################################################

# init
knnview.init(k=10, df=ll$df, D=ll$D, field.id="sample", field.cluster="cluster", use.df.xy=T)
