ui = fluidPage(
    fluidRow(
        column(width = 12, class = "well",
               fluidRow(
                   column(width = 2,
                          fluidRow(
                              h2("knnview"),
                              h4(.knnview$title),
                              selectInput("label.field", label="Label field",
                                          choices=.knnview$fields, selected=.knnview$init.field.label),
                              selectInput("col.field", label="Color field",
                                          choices=.knnview$fields, selected=.knnview$init.field.col),
                              hr(),
                              sliderInput("nn.barplot.count", "NN count (barplot)",min=10, max=1000, value=50),
                              sliderInput("nn.edge.count", "NN count (edges)",min=1, max=.knnview$k, value=.knnview$k),
                              sliderInput("plot.cex", "Plot circle size",min=0, max=6, value=2, step=0.5),
                              hr(),
                              checkboxInput("show.legend", "Show color legend (middle panel)", T),
                              checkboxInput("nn.only.cluster", "Show only subject samples (right panel)", F),
                              checkboxInput("show.labels", "Show sample labels", F),
                              hr(),
                              selectInput("selected.sample", label="Selected sample",
                                          choices=c("none", .knnview$df$id), selected="none"),
                              checkboxInput("center.selection", "Center on selected sample", F),
                              hr(),
                              actionButton("help", "Help"),
                              actionButton("about", "About")
                          )),
                   column(width = 5, uiOutput("plot.tsne")),
                   column(width = 4, uiOutput("plot.nn")),
                   )),
               hr(),
               verbatimTextOutput("info"),
        tags$script('
    $(document).on("keydown", function (e) {
      Shiny.onInputChange("keydown", [e.which,e.timeStamp]);
    });
	      '),
    tags$script('
    $(document).on("keyup", function (e) {
      Shiny.onInputChange("keyup", [e.which,e.timeStamp]);
    });
	      ')
    )
)
