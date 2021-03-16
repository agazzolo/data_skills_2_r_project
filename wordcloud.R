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

path <- "C:/Users/balas/OneDrive/Documents/Harris/Data_and_Programming_II/Homework/final_project/data_skills_2_r_project/"

# read in evaluations a and b
evaluation_a <- read_excel(paste0(path, "_Evaluation A and B Text Responses ONLY.xlsx"), 
                           sheet = "Evauluation A Text Responses ON")
evaluation_b <- read_excel(paste0(path, "_Evaluation A and B Text Responses ONLY.xlsx"), 
                           sheet = "Evalution B Text Responses ONLY")

#https://stackoverflow.com/questions/34092237/applying-dplyrs-rename-to-all-columns-while-using-pipe-operator/56304086

###################################################################################################
# Evaluation A clean-up
###################################################################################################

# rename columns adding question from row 1 and then delete row 1
evaluation_a <- evaluation_a %>% 
  rename_all(funs(str_c(colnames(evaluation_a), evaluation_a[1,], sep = ": "))) %>%
  slice(-c(1)) %>%
  slice(c(1:70))

all_cols_a <- list(ncol(evaluation_a))
for (i in seq_along(evaluation_a)) {
  all_cols_a[[i]] <- paste(unlist(evaluation_a[[i]]), collapse = " ")
}

all_cols_a <- tibble(text = all_cols_a)

questions_a <- tibble(colnames(evaluation_a)) %>%
  rename(questions = "colnames(evaluation_a)")

all_cols_a <- all_cols_a %>%
  mutate(question = questions_a$questions,
         evaluation = "Evaluation A")

all_a <- unnest_tokens(all_cols_a, word_tokens, text, token = "words")
###################################################################################################
# Evaluation B clean-up
###################################################################################################

# rename columns adding question from row 1 and then delete row 1
evaluation_b <- evaluation_b %>% 
  rename_all(funs(str_c(colnames(evaluation_b), evaluation_b[1,], sep = ": "))) %>%
  slice(-c(1)) %>%
  slice(c(1:13))

# unnest all columns
all_cols <- list(ncol(evaluation_b))
for (i in seq_along(evaluation_b)) {
  all_cols[[i]] <- paste(unlist(evaluation_b[[i]]), collapse = " ")
}

all_cols <- tibble(text = all_cols)

questions_b <- tibble(colnames(evaluation_b)) %>%
  rename(questions = "colnames(evaluation_b)")

all_cols <- all_cols %>%
  mutate(question = questions_b$questions,
         evaluation = "Evaluation B")

all_b <- unnest_tokens(all_cols, word_tokens, text, token = "words")

###################################################################################################
# Wordcloud Evaluation A and B
###################################################################################################

merged <- full_join(all_a, all_b)

evaluations <- anti_join(merged, stop_words, by = c("word_tokens" = "word")) %>%
  filter(word_tokens != "na")

evaluations_count_grouped <- evaluations %>%
  group_by(evaluation, question) %>%
  count(word_tokens) %>%
  rename(word = "word_tokens",
         freq = "n") %>%
  ungroup() %>%
  select(word, freq) %>%
  arrange(desc(freq))

evaluations_count <- evaluations %>%
  count(word_tokens) %>%
  rename(word = "word_tokens",
         freq = "n") %>%
  select(word, freq) %>%
  arrange(desc(freq))

eval_a_questions <- evaluations %>%
  filter(evaluation == "Evaluation A") %>%
  distinct(question)

eval_b_questions <- evaluations %>%
  filter(evaluation == "Evaluation B") %>%
  distinct(question)

ui <- 
  
  navbarPage("Research",
    
    #titlePanel(title = "Neeti's Work"),         
    
    tabPanel("Home"),
                        
    tabPanel("Peabody",
             fluidRow(column(width = 12, 
                             tags$h2("Word Cloud: Evaluations A and B Combined", align = "center"),
                             tags$hr()
                             )
                      ),
             fluidRow(wordcloud2Output("all")), 
             fluidRow(column(width = 12,
                             tags$h2("Word Cloud: Individual Questions", align = "center")
                             )
                      ),
             fluidRow(selectInput(inputId = "q",
                         label = "Choose a question",
                         list(
                           "Evaluation A" = eval_a_questions$question,
                           "Evaluation B" = eval_b_questions$question)
                         )
                      ),
             fluidRow(wordcloud2Output("ques")),
              ),
    
    tabPanel("Lincoln Park Zoo")
        
                
           
)  
#multiphttps://community.rstudio.com/t/shiny-app-composed-of-many-many-pages/7698
#https://github.com/daattali/advanced-shiny/blob/master/dropdown-groups/app.R

server <- function(input, output) {
  
  filtered <- reactive({
    wrdcloud <- evaluations %>% 
      filter(question == input$q) %>%
      count(word_tokens) %>%
      rename(word = "word_tokens",
             freq = "n") %>%
      arrange(desc(freq))
  })  
  
  output$all <- renderWordcloud2({
    wordcloud2(evaluations_count)
  })
  
  output$ques <- renderWordcloud2({
    wordcloud2(filtered())
  })  
  #https://cran.r-project.org/web/packages/wordcloud2/vignettes/wordcloud.html
  
}

shinyApp(ui = ui, server = server)
