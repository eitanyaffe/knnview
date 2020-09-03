library(MASS)
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

write.table(ll$df, "examples/df.tab", sep="\t")
saveRDS(ll$D, "examples/D.rds")
