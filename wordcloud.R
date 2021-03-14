library(shiny)
library(plotly)
library(scales)
library(tidyverse)
library(dplyr)
library(readxl)
library(tidytext)
library(wordcloud)
library(ggthemes)
library(tm)
library(wordcloud2)

path <- "C:/Users/balas/OneDrive/Documents/Harris/Data_and_Programming_II/Homework/final_project/"

evaluation_b <- read_excel(paste0(path, "_Evaluation A and B Text Responses ONLY.xlsx"), 
                           sheet = "Evalution B Text Responses ONLY")

# rename columns adding question from row 1 and then delete row 1
evaluation_b <- evaluation_b %>% 
  rename_all(funs(str_c(colnames(evaluation_b), evaluation_b[1,], sep = ": "))) %>%
  slice(-c(1))

# split evaluation b into 2 dataframes of survey results and survey data analysis
evaluation_b_poll <- slice(evaluation_b, (15:23))
evaluation_b_responses <- slice(evaluation_b, (1:13))
# https://dplyr.tidyverse.org/reference/slice.html  

# unnest all columns
all_cols <- list(ncol(evaluation_b_responses))
for (i in seq_along(evaluation_b_responses)) {
  all_cols[[i]] <- paste(unlist(evaluation_b_responses[[i]]), collapse = " ")
}

all_cols <- tibble(text = all_cols)

all_cols <- all_cols %>%
  mutate(question = c(1, 2, 3, 4, 5, 6, 7, 8, 9))

all_b <- unnest_tokens(all_cols, word_tokens, text, token = "words")
# wordcloud

no_sw_all_b <- anti_join(all_b, stop_words, by = c("word_tokens" = "word"))

all_b_freq <- no_sw_all_b %>%
  group_by(question) %>%
  count(word_tokens)

no_sw_freq <- no_sw_all_b %>%
  count(word_tokens) %>%
  rename(word = "word_tokens",
         freq = "n") %>%
  arrange(desc(freq))

ui <- fluidPage(
  selectInput(inputId = "q",
              label = "Choose a question",
              choices = no_sw_all_b$question),
  wordcloud2Output("ques"),
  wordcloud2Output("all")
)

server <- function(input, output) {
  
  filtered <- reactive({
    wrdcloud <- no_sw_all_b %>% 
      filter(question == input$q) %>%
      count(word_tokens) %>%
      rename(word = "word_tokens",
             freq = "n") %>%
      arrange(desc(freq))
  })  
  
  output$ques <- renderWordcloud2({
    wordcloud2(filtered())
  })  
  #https://cran.r-project.org/web/packages/wordcloud2/vignettes/wordcloud.html
  
  output$all <- renderWordcloud2({
    wordcloud2(no_sw_freq)
  })
}

shinyApp(ui = ui, server = server)
