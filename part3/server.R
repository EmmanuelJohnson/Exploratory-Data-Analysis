library(shiny)
library(ggplot2)
library(plyr)
library(plotly)
library(ggmap)


function(input, output, session) {


    displayFlag <- reactiveValues(data = 0)
    csvFileName <- reactiveValues(data = "finalStatesCheck.csv")

    observeEvent(input$twtrBtn, {
        updateCheckboxInput(session, "cmprChk", value = F)
        displayFlag$data <- 0
    })

    observeEvent(input$cdcBtn, {
        updateCheckboxInput(session, "cmprChk", value = F)
        displayFlag$data <- 1
    }) 

    observeEvent(input$cmprChk, {
        if (input$cmprChk == FALSE){
            if(displayFlag$data == 2)
                displayFlag$data <- 0
            displayFlag$data <- displayFlag$data
            return (NULL)
        }
        displayFlag$data <- 2
    })

    observeEvent(input$filter, {
        filterVal <- input$filter
        if (filterVal == "0")
            csvFileName$data <- "finalStatesCheck.csv"
        else
            csvFileName$data <- "fluStates.csv"

    })

    plotHeatMap <- function(fileName, titleName="2018-19 Flu Season Heatmap Using Twitter Data"){
        read <- read.csv(fileName, header=F)
        state_code <- state.abb[match(read$V1, state.name)]
        plotData <- count(state_code)
        usaLayout <- list(scope = 'usa', projection = list(type = 'albers usa'), showlakes = FALSE, bgcolor="#2B3E50")
        p <- plot_geo(plotData, locationmode = 'USA-states') %>%
            add_trace(
            z = ~plotData$freq, locations = ~plotData$x,
            color = ~plotData$freq, colors=c("#5BF700", "#8CF700", "#BAF700", "#E0F500", "#F7DF00", "#FCB100", "#FC8200", "#FA4F00", "#CC0000")
            ) %>%
            config(displayModeBar = F, staticPlot = F) %>% 
            colorbar(title = "ILI Activity Level - Twitter") %>%
            layout(title = titleName, geo = usaLayout, paper_bgcolor="#2B3E50", plot_bgcolor="#2B3E50", font=list(color='#EBEBEB'))

        return (p)
    }

    plotCDCMap <- function(fileName, titleName="2018-19 Flu Season Heatmap Using CDC Data"){
        read <- read.csv(fileName, header=F, skip=1)
        temp <- read
        for (i in 0:10) {
            search <- paste(c("Level", i), collapse = " ")
            temp$V4 <- gsub(search, i, temp$V4)
        }
        states <- NULL
        levels <- NULL
        read <- temp
        for (i in 0:nrow(read)) {
            states <- append(states,state.abb[match(read[i,]$V1, state.name)])
            levels <- append(levels,as.numeric(read[i,]$V4))
        }
        plotData <- data.frame(
            loc = states,
            intensity = levels
        )
        usaLayout <- list(scope = 'usa', projection = list(type = 'albers usa'), showlakes = FALSE, bgcolor="#2B3E50")
        p <- plot_geo(read, locationmode = 'USA-states') %>%
        add_trace(
            z = ~plotData$intensity, locations = ~plotData$loc,
            color = ~plotData$intensity, colors=c("#FFFFFF", "#00C200", "#5BF700", "#8CF700", "#BAF700", "#E0F500", "#F7DF00", "#FCB100", "#FC8200", "#FA4F00", "#CC0000")
        ) %>%
        config(displayModeBar = F, staticPlot = F) %>% 
        colorbar(title = "ILI Activity Level - CDC") %>%
        layout(title = titleName, geo = usaLayout, paper_bgcolor="#2B3E50", plot_bgcolor="#2B3E50", font=list(color='#EBEBEB'))
        return (p)
    }

    output$heatmap <- renderPlotly({

    if (displayFlag$data == 0)
        plotMap <- plotHeatMap(csvFileName$data)
    else if (displayFlag$data == 1)
        plotMap <- plotCDCMap("cdc_week.csv")
    else if (displayFlag$data == 2){
        p1 <- plotHeatMap(csvFileName$data, title="2018-19 Flu Season Heatmap Comparison : Twitter Vs CDC")
        p2 <- plotCDCMap("cdc_week.csv", title="2018-19 Flu Season Heatmap Comparison : Twitter Vs CDC")
        subplot(p1, p2, nrows=2)
    }

    })

}