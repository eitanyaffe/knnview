###################################################################################################
# core functions
###################################################################################################

# single step
get.nn=function(D, ids, k)
{
    result = NULL
    for (i in 1:dim(D)[1]) {
        oo = setdiff(order(D[,i]), i)[1:k]
        NN = ids[oo]
        result.i = data.frame(id=ids[i], t(NN))
        names(result.i)[-1] = paste0("n", 1:k)
        result = rbind(result, result.i)
    }
    result
}

# single step
get.purity=function(D, ids, clusters, weights, k)
{
    result = NULL
    for (i in 1:dim(D)[1]) {
        oo = setdiff(order(D[,i]), i)[1:k]
        NN.clusters = clusters[oo]
        NN.weights = weights[oo]
        ix = (NN.clusters == clusters[i])
        score = sum(NN.weights[ix]) / sum(NN.weights)
        oneighbor = ifelse(any(!ix), ids[oo][which(!ix)[1]], NA)
        result.i = data.frame(id=ids[i], cluster=clusters[i], score=score, oneighbor=oneighbor)
        result = rbind(result, result.i)
    }
    result
}

# recursive calls
get.purity.recursive=function(D, ids, clusters, k, min.score=0.9, max.iter=10)
{
    result = NULL
    weights = rep(1, length(ids))
    for (iter in 1:max.iter) {
        rr = get.purity(D=D, ids=ids, clusters=clusters, weights=weights, k=k)
        ix = rr$score < min.score & !is.element(rr$id, result$id)
        N = sum(ix)
        if (N == 0)
            break
        cat(sprintf("iteration #%d: identified %d putative cross-contaminated samples\n",  iter, N))
        clusters[ix] = "CC"
        weights[ix] = 1/2^iter
        result = rbind(result, rr[ix,])
    }
    cat(sprintf("total number of putative cross-contaminated samples: %d\n",  dim(result)[1]))
    result
}

###################################################################################################
# plot function
###################################################################################################

plot.tnse.internal=function(df, df.purity, col.field, label.field,
                            col.legend, show.legend, df.NN, nn.count, cex,
                            xlim, ylim, selected.sample=NA, show.labels=T, to.file=F)
{
    cex.text = 1
    lwd = 3

    df$col = df[,paste0(col.field, ".col")]

    if (!is.na(selected.sample)) {
        ix = match(selected.sample, df$id)
        df = rbind(df[-ix,], df[ix,])
    }

    in.range=function(v, lim) { v>=lim[1] & v<=lim[2] }
    df = df[in.range(df$x, xlim) & in.range(df$y, ylim),]

    plot.new()
    plot.window(xlim=xlim, ylim=ylim)

    if (!is.na(selected.sample)) {
        NN.ids = as.vector(df.NN[df.NN$id == selected.sample,-1])
        ix.start = match(selected.sample, df$id)
        ix.end = match(NN.ids, df$id)
        if (!is.na(nn.count)) {
            max.count = min(nn.count, length(ix.end))
            ix.end = ix.end[1:max.count]
        }
        segments(x0=df$x[ix.start], x1=df$x[ix.end], y0=df$y[ix.start], y1=df$y[ix.end], col="lightgray")
    }

    # plot(df$x, df$y, col=df$col, pch=19, cex=cex, xlim=xlim, ylim=ylim, xlab=NA, ylab=NA)
    points(df$x, df$y, col=df$col, pch=19, cex=cex)

    ix = match(df.purity$id, df$id)
    points(df$x[ix], df$y[ix], col=ifelse(df.purity$score < 1, "lightgray", NA), pch=1, cex=cex, lwd=lwd)
    points(df$x[ix], df$y[ix], col=ifelse(df.purity$score < 0.9, "darkgray", NA), pch=1, cex=cex, lwd=lwd)
    points(df$x[ix], df$y[ix], col=ifelse(df.purity$score < 0.8, "black", NA), pch=1, cex=cex, lwd=lwd)

    if (!is.na(selected.sample)) {
        ix = match(selected.sample, df$id)
        points(df$x[ix], df$y[ix], col=1, pch=19, cex=0.7)
    }

    if (show.labels)
        text(df$x, df$y, pos=4, label=df[,label.field], cex=cex.text)

    if (show.legend) {
        ll = col.legend[[col.field]]
        cex = ifelse(length(ll$vals) < 10, 1, 0.7)
        max.legend = .knnview$max.legend

        if (length(ll$vals) > max.legend) {
            ix = floor((1:max.legend) * length(ll$vals)/max.legend)
            ll$vals = ll$vals[ix]
            ll$cols = ll$cols[ix]
        }
        legend("topright", title=col.field, legend=ll$vals, fill=ll$cols, border=NA, cex=cex, box.lwd=0)
    }
    box()
}

plot.nn=function(df, df.plot, D, col.field, label.field, show.labels,
                 col.legend, show.legend, ksize,
                 nn.count, only.cluster, selected.sample=NA)
{
    if (is.na(selected.sample)) {
        plot.new()
        plot.window(0:1, 0:1)
        text(0.5, 0.5, "no sample selected")
        return (NULL)
    }

    df$col = df[,paste0(col.field, ".col")]

    diag(D) = 1
    mmax = max(1-D)

    Dcluster = df$cluster[match(colnames(D), df$id)]

    ix = match(selected.sample, colnames(D))
    Dx = D[ix,]
    if (only.cluster) {
        cluster = Dcluster[ix]
        Dx = Dx[Dcluster == cluster]
    }
    nn.count = min(nn.count, length(Dx))
    Dx = rev(sort(Dx)[1:nn.count])[-1]
    Dcols = df$col[match(names(Dx), df$id)]
    mai = par("mai")
    mai[2] = 1.2
    par(mai=mai)

    score = df$score[match(selected.sample, df$id)]
    main = sprintf("Nearest neighbours of sample %s\npurity score=%.2f", selected.sample, score)

    mm = barplot(1-Dx, names.arg=names(Dx), col=Dcols, las=2, xlim=c(0,mmax), width=0.6, space=0.4,
                 horiz=T, xlab="Similarity", border=NA)

    rect(xleft=0, xright=1, ybottom=mm[dim(mm)[1]-ksize]+0.4, ytop=mm[dim(mm)[1]]+0.5, col="lightgray", border=NA)

    mm = barplot(1-Dx, names.arg=names(Dx), col=Dcols, las=2, xlim=c(0,mmax), width=0.6, space=0.4, add=T,
                 horiz=T, xlab="distance", border=NA)

    title(main=main)

    if (show.labels) {
        ix = match(names(Dx), df$id)
        labs = df[ix,label.field]
        text(x=1-Dx, y=mm, pos=4, labs, cex=0.75)
    }
}

###################################################################################################
# main knnview function
###################################################################################################

knnview.cluster=function(
    df,                            # data.frame of samples.
    D,                             # distance matrix of samples.
    k=10,                          # k value used in kNN.
    min.score=0.9,                 # classify sample as pure if purity score is at least this score
    run.recursive=F,               # if true runs until convergence
    field.id="id",                 # sample column in df .
    field.cluster="cluster",       # cluster column in df.
    fields=c("id", "cluster"),     # columns in df used for text/color annotation.
    init.field.col="cluster",      # initial field used for color.
    init.field.label="cluster",    # initial field used for label.
    plot.all=T,                    # if false, plots only clusters involved in non-perfect scores.
    use.df.xy=F,                   # override t-SNE coords with user-specified x/y coords in the df.
    max.items.in.legend=40         # max items displayed in color legend
    )
{
    df$id = df[,field.id]
    df$cluster = df[,field.cluster]

    # select ids
    all.ids = intersect(df$id, (colnames(D)))
    if (length(all.ids) == 0) {
        stop(sprintf("The ids of the parameter 'df' (field: %s) and the columns and rows of the matrix 'D'", field.id))
    }

    # filter df
    df = df[is.element(df$id, all.ids),]

    # filter D
    ix = match(all.ids, colnames(D))
    D = D[ix,ix]

    # sort df by D
    ix = match(colnames(D), df$id)
    if (any(is.na(ix)))
        stop("some matrix columns missing in sample table")
    df = df[ix,]

    # add colors
    ll = list()
    for (field in fields) {
        vals = sort(unique(df[,field]))
        cols = rainbow(length(vals))
        col.field = paste0(field, ".col")
        df[,col.field] = cols[match(df[,field], vals)]
        ll[[field]] = list(vals=vals, cols=cols)
    }

    # single run example
    cat(sprintf("Computing purity scores fo %d samples, k=%d\n", dim(D)[1], k))

    if (!run.recursive) {
        weights = rep(1, dim(df)[1])
        df.purity = get.purity(D=D, ids=df$id, clusters=df$cluster, weights=weights, k=k)
        df.purity = df.purity[df.purity$score < min.score,]
    } else {
        df.purity = get.purity.recursive(D=D, ids=df$id, clusters=df$cluster, k=k, min.score=min.score, max.iter=20)
    }

    df.purity$ocluster = df$cluster[match(df.purity$oneighbor, df$id)]
    aids = c(df.purity$id, df.purity$oneighbor)
    sids = sort(unique(df$cluster[match(aids,df$id)]))

    ix =  match(df$id, df.purity$id)
    df$score = ifelse(!is.na(ix), df.purity$score[ix], 1)

    if (plot.all || dim(D)[1] < 10) {
        df.plot = df
        D.plot = D
    } else {
        ix = is.element(df$cluster, sids)
        df.plot = df[ix,]
        D.plot = D[ix,ix]
    }

    if (use.df.xy) {
        if (!is.element("x", colnames(df)) || !is.element("y", colnames(df)))
            stop("when use.df.xy is TRUE fields 'x' and 'y' must be supplied in the df")
    } else {
        cat(sprintf("Arranging samples using 2D t-SNE, with perplexity=k\n"))
        rtsne = Rtsne(X=D.plot, is_distance=T, perplexity=k)
        df.plot$x = rtsne$Y[,1]
        df.plot$y = rtsne$Y[,2]
    }


    result = list()

    result$df.purity = df.purity
    result$df.plot = df.plot
    result$df = df

    extend.range=function(range, f) {
        dd = diff(range)*f
        range[1] = range[1] - dd
        range[2] = range[2] + dd
        range
    }

    result$xlim.max = extend.range(range(df.plot$x), 0.08)
    result$ylim.max = extend.range(range(df.plot$y), 0.08)

    result$title = paste0("K=", k, ", total N=", dim(D)[1], ", plotted N=", dim(df.plot)[1])

    # matrix
    result$D = D

    # max items in legend
    result$max.legend = max.items.in.legend

    result$NN = get.nn(D, df$id, k)

    # color and label fields
    result$fields = fields
    result$legend = ll

    result$init.field.col = init.field.col
    result$init.field.label = init.field.label

    result$k = k

    cat(sprintf("knnview.init() done, number of non-pure samples: %d\n", sum(df.purity$score<1)))
    result
}

# wrapper function that support caching and prepares shiny app
knnview.init=function(use.cache=F, df, D, ...)
{
    key = digest(paste(unlist(list(...)), collapse="_"))
    if (!use.cache || !exists(".knnview") || .knnview$key != key) {
        .knnview <<- knnview.cluster(df=df, D=D, ...)
        .knnview$key <<- key
    } else {
        cat(sprintf("Reloading shiny app using cached data\n"))
    }
    wdir = Sys.getenv("KNNVIEW_DIR")
    if (wdir != "") wdir = paste0(wdir, "/")
    source(paste0(wdir, "knnview_ui.r"), local=T)
    source(paste0(wdir, "knnview_server.r"), loca=T)
    .knnview$ui <<- ui
    .knnview$server <<- server

    .knnview$df.purity
}

# helper function to reload
rl=function() {
    shinyApp(.knnview$ui, .knnview$server)
}
