library(tidyverse)
library(dplyr)
library(readxl)
library(tidytext)
library(wordcloud)
library(ggthemes)
library(tm)
library(wordcloud2)

path <- "C:/Users/balas/OneDrive/Documents/Harris/Data_and_Programming_II/Homework/final_project/"

# read in evaluations a and b
evaluation_a <- read_excel(paste0(path, "_Evaluation A and B Text Responses ONLY.xlsx"), 
                           sheet = "Evauluation A Text Responses ON")
evaluation_b <- read_excel(paste0(path, "_Evaluation A and B Text Responses ONLY.xlsx"), 
                           sheet = "Evalution B Text Responses ONLY")

#https://stackoverflow.com/questions/34092237/applying-dplyrs-rename-to-all-columns-while-using-pipe-operator/56304086

###################################################################################################
# Evaluation a clean-up
###################################################################################################

# rename columns adding question from row 1 and then delete row 1
evaluation_a <- evaluation_a %>% 
  rename_all(funs(str_c(colnames(evaluation_a), evaluation_a[1,], sep = ": "))) %>%
  slice(-c(1))

###################################################################################################
# Evaluation b clean-up
###################################################################################################

# rename columns adding question from row 1 and then delete row 1
evaluation_b <- evaluation_b %>% 
  rename_all(funs(str_c(colnames(evaluation_b), evaluation_b[1,], sep = ": "))) %>%
  slice(-c(1))

# split evaluation b into 2 dataframes of survey results and survey data analysis
evaluation_b_poll <- slice(evaluation_b, (15:23))
evaluation_b_responses <- slice(evaluation_b, (1:13))
# https://dplyr.tidyverse.org/reference/slice.html  


# unnest one column 
killers_4 <- evaluation_b_responses %>% select(`Killers w/ hooves 4`)
# https://stackoverflow.com/questions/20854615/r-merge-multiple-rows-of-text-data-frame-into-one-cell

killers_4 <- paste(unlist(killers_4), collapse = " ")

killers_4 <- tibble(text = killers_4)

unnest_tokens(killers_4, word_tokens, 
              text, token = "words")


paste(unlist(evaluation_b_responses), collapse = " ")

# unnest all columns
output <- list(ncol(evaluation_b_responses))
for (i in seq_along(evaluation_b_responses)) {
  output[[i]] <- paste(unlist(evaluation_b_responses[[i]]), collapse = " ")
}

output <- tibble(text = output)

output <- output %>%
  mutate(question = c(1, 2, 3, 4, 5, 6, 7, 8, 9))

all_b <- unnest_tokens(output, word_tokens, text, token = "words")

# sentiments

for (s in c("nrc", "afinn", "bing")) {
  all_b <- all_b %>%
    left_join(get_sentiments(s), by = c("word_tokens" = "word")) %>%
    plyr::rename(replace = c(sentiment = s, value = s), warn_missing = FALSE)
}

ggplot(data = filter(all_b, !is.na(nrc))) +
  geom_histogram(aes(nrc), stat = "count") +
  scale_x_discrete(guide = guide_axis(angle = 45)) +
  labs(title = "Evaluation B Responses NRC Sentiments")

ggplot(data = filter(all_b, !is.na(bing))) +
  geom_histogram(aes(bing), stat = "count") +
  scale_x_discrete(guide = guide_axis(angle = 45)) +
  labs(title = "Evaluation B Responses BING Sentiments")

ggplot(data = filter(all_b, !is.na(afinn))) +
  geom_histogram(aes(afinn), stat = "count") +
  scale_x_continuous(n.breaks = 7) +
  labs(title = "Evaluation B Responses AFINN Sentiments")

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

q1 <- no_sw_all_b %>%
  filter(question == 1) %>%
  count(word_tokens) %>%
  rename(word = "word_tokens",
         freq = "n") %>%
  arrange(desc(freq))

wordcloud2(q1)
#https://cran.r-project.org/web/packages/wordcloud2/vignettes/wordcloud.html

