server = function(input, output, session) {

    ###########################################################################
    # dynamic variables
    ###########################################################################

    keyboard = reactiveValues(shift=F)
    ranges = reactiveValues(x = .knnview$xlim.max, y = .knnview$ylim.max)
    info = reactiveValues(x=NA, y=NA, sample=NA, selected.sample=NA)
    # state = reactiveValues()

    ###########################################################################
    # plot t-SNE
    ###########################################################################

    output$plot.tsne <- renderUI({
        plotOutput("server.plot.tsne", height = 800,
                   click = clickOpts(id="click"),
                   brush = brushOpts(id = "brush", resetOnNew = TRUE),
                   hover = hoverOpts(id="hover", delay=100, delayType=c("throttle"), clip=T))
    })

    output$server.plot.tsne = renderPlot({
        plot.tnse.internal(df=.knnview$df.plot, df.purity=.knnview$df.purity,
                           xlim=ranges$x, ylim=ranges$y, selected.sample=info$selected.sample,
                           col.legend=.knnview$legend, show.legend=input$show.legend,
                           col.field=input$col.field, cex=as.numeric(input$plot.cex),
                           df.NN=.knnview$NN, nn.count=as.numeric(input$nn.edge.count),
                           label.field=input$label.field, show.labels=input$show.labels)
    })

    ###########################################################################
    # plot NN
    ###########################################################################

    output$plot.nn <- renderUI({
        plotOutput("server.nn", height = 800)
    })

    output$server.nn = renderPlot({
        plot.nn(df.plot=.knnview$df.plot, df=.knnview$df, D=.knnview$D,
                selected.sample=info$selected.sample,
                col.field=input$col.field,
                label.field=input$label.field, show.labels=input$show.labels,
                col.legend=.knnview$legend, show.legend=input$show.legend,
                ksize=.knnview$k,
                only.cluster=input$nn.only.cluster, nn.count=as.numeric(input$nn.barplot.count))
    })
    ###########################################################################
    # info
    ###########################################################################

    output$info = renderPrint({
        msg = ""
        ix = match(info$sample, .knnview$df$id)
        if (!is.na(ix)) {
            for (i in 1:length(.knnview$fields)) {
                field = .knnview$fields[i]
                fmsg = sprintf("%s=%s", field, as.character(.knnview$df[ix,field]))
                if (i == 1)
                    msg = fmsg
                else
                    msg = paste0(msg, ", ", fmsg)
            }
        }
        cat(msg)
    })

    ###########################################################################
    # select
    ###########################################################################

    observeEvent(input$click, {
        if (!keyboard$shift) {
            return (NULL)
        }
        np = nearPoints(.knnview$df.plot, xvar="x", yvar="y", input$click, maxpoints=1, threshold=20)
        if (dim(np)[1] == 1)
            info$selected.sample = np$id[1]
        else
            info$selected.sample = NA
    })

    ###########################################################################
    # hover
    ###########################################################################

    observeEvent(input$hover, {
        info$x = input$hover$x
        info$y = input$hover$y
        np = nearPoints(.knnview$df.plot, xvar="x", yvar="y", input$hover, maxpoints=1, threshold=20)
        if (dim(np)[1] == 1)
            info$sample = np$id[1]
        else
            info$sample = NA
    })

    # navigation history
    ###########################################################################

    navigation.history = list()
    push.history=function(expr) {
        N = length(navigation.history)
        cat(sprintf("history push, N=%d\n", N))
        navigation.history[[N+1]] <<- expr
    }
    pop.history=function() {
        N = length(navigation.history)
        cat(sprintf("history pop, N=%d\n", N))
        if (N > 0) {
            top = navigation.history[[N]]
            navigation.history <<- navigation.history[-N]
            str(top)
            eval(top)
        }
    }

    ###########################################################################
    # navigation
    ###########################################################################

    zoomout.range=function(range) {
        dd = diff(range)
        range[1] = range[1] - dd
        range[2] = range[2] + dd
        range
    }
    zoomin.range=function(range, center) {
        dd = diff(range)/8
        range[1] = center - dd
        range[2] = center + dd
        range
    }
    center.range=function(range, center) {
        dd = diff(range)/2
        range[1] = center - dd
        range[2] = center + dd
        range
    }

    navigate.push.history=function() {
        expr = substitute({
            ranges$x[1] <<- x1
            ranges$x[2] <<- x2
            ranges$y[1] <<- y1
            ranges$y[2] <<- y2
        }, list(x1=ranges$x[1], x2=ranges$x[2], y1=ranges$y[1], y2=ranges$y[2]))
        push.history(expr)
    }
    zoom.in=function() {
        if (!is.null(input$brush)) {
            navigate.push.history()
            isolate({
                ranges$x = c(input$brush$xmin, input$brush$xmax)
                ranges$y = c(input$brush$ymin, input$brush$ymax)
            })
        } else if (!is.null(input$hover)) {
            navigate.push.history()
            isolate({
                ranges$x = zoomin.range(ranges$x, input$hover$x)
                ranges$y = zoomin.range(ranges$y, input$hover$y)
            })
        }
    }
    zoom.center=function() {
        if (!is.null(input$hover)) {
            navigate.push.history()
            isolate({
                ranges$x = center.range(ranges$x, input$hover$x)
                ranges$y = center.range(ranges$y, input$hover$y)
            })
        }
    }

    zoom.out=function() {
        navigate.push.history()
        isolate({
            ranges$x = zoomout.range(ranges$x)
            ranges$y = zoomout.range(ranges$y)
        })
    }
    zoom.all=function() {
        navigate.push.history()
        ranges$x = .knnview$xlim.max
        ranges$y = .knnview$ylim.max
    }

    labels.toggle=function() {
        updateCheckboxInput(session, "show.labels", value = !input$show.labels)
    }

    labels.cluster.NN=function() {
        updateCheckboxInput(session, "nn.only.cluster", value = !input$nn.only.cluster)
    }

    ###########################################################################
    # keyboard
    ###########################################################################

    shift.on=function() { keyboard$shift = T }
    shift.off=function() { keyboard$shift = F }
    is.shift.on=function() { keyboard$shift }

    observeEvent(input$keyup, {
        key = input$keyup[1]
        # cat(sprintf("keyup: %s\n", as.character(key)))
        if (as.character(key) == "16")
            shift.off()
    } )

    observeEvent(input$keydown, {
        key = input$keydown[1]
        cat(sprintf("keydown: %s\n", as.character(key)))
        if (as.character(key) == "16") {
            shift.on()
            return (NULL)
        }

        if (!keyboard$shift) {
            return (NULL)
        }

        switch(as.character(key),
               "8"=pop.history(),              # Shift + delete
               "61"=zoom.all(),                # +
               "173"=zoom.out(),               # _
               "187"=zoom.all(),               # _ (other mac)
               "189"=zoom.out(),               # + (other mac)
               "90"=zoom.in(),                 # Z
               "88"=zoom.center(),             # X
               "76"=labels.toggle(),           # L
               "67"=labels.cluster.NN(),       # C
               "72"=help.event(),              # H
               cat(sprintf("unknown key pressed: %s\n", as.character(key))))
        cat("keyboard event done\n")
    } )

    help.event=function() {
        result = NULL
        xcat0=function(msg) { result <<- paste0(result,msg,"<br>",collapse="")}
        xcat1=function(msg) { xcat0(paste0("&nbsp;&nbsp;&nbsp;&nbsp", msg, collapse=""))}
        xnew=function() { xcat0("")}

        xcat0("Hover mouse over sample to get info, shown on bottom panel.")
        xnew()

        xcat0("Hold the shift key while performing all action below.")
        xcat0("Keyboard keys:")
        xcat1("No key : Press mouse without keyboard to select sample. Press outside samples to cancel selection.")
        xcat1("'x'    : Center on mouse location.")
        xcat1("'z'    : Zoom in, on cursor or on marked rectangle, if selected.")
        xcat1("'-'    : Zoom out.")
        xcat1("'='    : Reset zoom.")
        xcat1("'l'    : Toggle labels.")
        xcat1("'c'    : Toggle 'show only cluster NN'.")
        xcat1("'Delete' : Undo navigation.")

        result
    }

    observeEvent(input$help, {
        showModal(modalDialog(title="Keyboard shortcuts", easyClose=T, HTML(help.event()))) })

    about.event=function() {
        result = NULL
        xcat0=function(msg) { result <<- paste0(result,msg,"<br>",collapse="")}
        xcat1=function(msg) { xcat0(paste0("&nbsp;&nbsp;&nbsp;&nbsp", msg, collapse=""))}
        xnew=function() { xcat0("")}

        xcat0("knnview 1.0, developed Eitan Yaffe (September 2020), email: eitan.yaffe@gmail.com.")
        xnew()
        xcat0("Repository: https://github.com/eitanyaffe/knnview.")
        xnew()
        xcat0("The package is subject to the terms and conditions as defined in the 'LICENSE' file.")

        result
    }

    observeEvent(input$about, {
        showModal(modalDialog(title="About", easyClose=T, HTML(about.event()))) })
}
