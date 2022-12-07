# file 3 of 3 - Shiny Wordclouds
library(tidyverse)
library(wordcloud2)
library(shiny)
library(plotly)
library(scales)

articles <- c("New York Times - 2020", 
              "ASPCA - 2020",
              "DVM360 - 2021",
              "ASPCA - 2021",
              "Scientific American - 2021",
              "Washington Post - 2022",
              "Pet Food Industry - 2022")

server <- function(input, output) {
  data_source <- reactive({
    if (input$art == "New York Times - 2020") {
      data <- read_csv("nyt2020_nrc.csv")
    } else if (input$art == "ASPCA - 2020") {
      data <- read_csv("aspca2020_nrc.csv")
    } else if (input$art == "DVM360 - 2021") {
      data <- read_csv("dvm2021_nrc.csv")
    } else if (input$art == "ASPCA - 2021") {
      data <- read_csv("aspca2021_nrc.csv")
    } else if (input$art == "Scientific American - 2021") {
      data <- read_csv("sa2021_nrc.csv")
    } else if (input$art == "Washington Post - 2022") {
      data <- read_csv("wapo2022_nrc.csv")
    } else if (input$art == "Pet Food Industry - 2022") {
      data <- read_csv("pfi2022_nrc.csv")
    }
  })
  output$cloud <- renderWordcloud2({
    wordcloud2(data_source(), 
               fontFamily = "sans",
               color = brewer.pal(11, "Spectral"))
  })
}

ui <- fluidPage(
  titlePanel("Word Cloud"),
  
  sidebarLayout(
    sidebarPanel(
      selectInput(inputId = "art",
                  label = "Choose an article:",
                  choices = articles),
      hr(),
      h5("Links to Each Article:"), 
      tags$a(href = "https://www.nytimes.com/2020/05/06/smarter-living/a-guide-for-first-time-pet-owners-during-the-pandemic.html?searchResultPosition=4", 
             "New York Times – “A Guide for First Time Pet Owners During the Pandemic”"),
    ),
    mainPanel(
      wordcloud2Output("cloud")
    )
  )
)

shinyApp(ui = ui, server = server)