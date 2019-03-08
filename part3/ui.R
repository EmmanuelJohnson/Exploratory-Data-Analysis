library(shiny)
library(shinythemes)
library(ggplot2)
library(plotly)
library(ggmap)


fluidPage(
    theme = shinytheme("superhero"),
    tags$head(
        tags$style(HTML("#twtrBtn,#cdcBtn{background-color:#DF691A;}
            button#twtrBtn:focus,button#twtrBtn:active,button#cdcBtn:focus,button#cdcBtn:active{background-color:#b15315;}
            h2{text-align:center;margin-bottom:50px;}
            form{margin-top: 25vh;}"))
    ),
    column(6,offset = 3, titlePanel("2018-19 Flu View Heat Map of USA")),
    sidebarPanel(
        actionButton("twtrBtn", "Twitter USA Heat Map"),
        actionButton("cdcBtn", "CDC USA Heat Map"),
        checkboxInput("cmprChk", "Compare Both Maps", FALSE),
        selectInput("filter", "Filter By Keywords", c("All"="0", "Flu"="1")),
        p("egnanach and venktesh")
    ),
    mainPanel(
        plotlyOutput("heatmap", heigh="88vh")
    )
)