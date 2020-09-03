ui = fluidPage(
    fluidRow(
        column(width = 12, class = "well",
               h4(.knnview$title),
               fluidRow(
                   column(width = 2,
                          fluidRow(
                              sliderInput("nn.barplot.count", "NN count (barplot)",min=10, max=1000, value=50),
                              sliderInput("nn.edge.count", "NN count (edges)",min=1, max=.knnview$k, value=.knnview$k),
                              textInput("nn.edge.count", "NN count (edges)", .knnview$k),
                              checkboxInput("nn.only.cluster", "Show only cluster NN", F),
                              checkboxInput("show.labels", "Show labels", F),
                              checkboxInput("show.legend", "Show legend", T),
                              selectInput("label.field", label="Label field",
                                          choices=.knnview$fields, selected=.knnview$init.field.label),
                              selectInput("col.field", label="Color field",
                                          choices=.knnview$fields, selected=.knnview$init.field.col),
                              textInput("plot.cex", "Plot circle size", "2"),
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
