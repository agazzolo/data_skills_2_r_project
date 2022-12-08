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
    wordcloud2(data_source(), fontFamily = 'Segoe UI', color = "random-light")
  })
}

ui <- fluidPage(
  titlePanel("Attitudes Towards Pet Adoptions During the COVID-19 Pandemic"),
  p(em("Click below to see how mainstream news vs. industry and trade publications discussed pet adoption trends during the COVID-19 Pandemic as seen through the NRC Word-Emotion Association Lexicon")),
  sidebarLayout(
    sidebarPanel(
      selectInput(inputId = "art",
                  label = "Choose an article:",
                  choices = articles),
      hr(),
      h5("Links to Each Article:"), 
      tags$a(href = "https://www.nytimes.com/2020/05/06/smarter-living/a-guide-for-first-time-pet-owners-during-the-pandemic.html?searchResultPosition=4", 
             "New York Times – “A Guide for First Time Pet Owners During the Pandemic” (2020)"),
      br(),
      tags$a(href = "https://www.aspcapro.org/news/2020/06/10/over-570-groups-complete-7300-adoptions-during-aspca-national-adoption-weekend", 
             "ASPCA – “Over 570 Groups Complete 7,300 Adoptions During ASPCA National Adoption Weekend” (2020)"),
      br(),
      tags$a(href = "https://www.dvm360.com/view/the-covid-19-pet-adoption-boom-did-it-really-happen-", 
             "DVM360 – “The COVID-19 Pet Adoption Boom: Did it Really Happen?”(2021)"),
      br(),
      tags$a(href = "https://www.aspcapro.org/resource/new-aspca-survey-vast-majority-dogs-and-cats-acquired-during-pandemic-still-their-homes", 
             "ASPCA – “New ASPCA Survey: Vast Majority of Dogs and Cats Acquired During Pandemic Still in Their Homes” (2021)"),
      br(),
      tags$a(href = "https://www.scientificamerican.com/article/home-alone-the-fate-of-postpandemic-dogs/", 
             "Scientific American: “Home Alone: The Fate of Postpandemic Dogs” (2021)"),
      br(),
      tags$a(href = "https://www.petfoodindustry.com/articles/11748-pandemic-new-pet-boom-myth-busted-adoptions-lower-2021-22", 
             "Pet Food Industry - “Pandemic new pet boom myth busted; Adoptions lower 2021-22” (2022)"),
      br(),
      tags$a(href = "https://www.washingtonpost.com/business/2022/01/07/covid-dogs-return-to-work/", 
             "Washington Post – “Americans adopted millions of dogs during the pandemic. Now what do we do with them?” (2022)"),
    ),
    mainPanel(
      wordcloud2Output("cloud")
    )
  )
)

shinyApp(ui = ui, server = server)