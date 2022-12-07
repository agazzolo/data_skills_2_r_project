# File 2 of 3 - text analysis
library(tidyverse)
library(rvest)
library(tidytext)
library(nametagger)
library(udpipe)
library(wordcloud2)
library(shiny)
library(plotly)
library(scales)

sentiment_nrc <-   
  get_sentiments("nrc") %>%
  rename(nrc = sentiment)

analyze_text <- function(url, css) {
  request <- read_html(url)
  article <- html_nodes(request, css)
  text_list <- html_text(article)
  text <- paste(text_list, collapse = "") %>% tibble(text = text_list)
  word_tokens_url <-     unnest_tokens(text, word_tokens,  text, token = "words")
  no_sw_df <- anti_join(word_tokens_url, stop_words, by = c("word_tokens" = "word"))
  no_sw_df_sent <- no_sw_df %>%
    left_join(sentiment_nrc, by = c("word_tokens" = "word"))
  return(no_sw_df_sent)
}

i2020_aspca <- analyze_text("https://www.aspcapro.org/news/2020/06/10/over-570-groups-complete-7300-adoptions-during-aspca-national-adoption-weekend", ".post__body")
m2020_nyt <- analyze_text("https://www.nytimes.com/2020/05/06/smarter-living/a-guide-for-first-time-pet-owners-during-the-pandemic.html?searchResultPosition=4",".StoryBodyCompanionColumn")
i2021_dvm <- analyze_text("https://www.dvm360.com/view/making-dermatology-cases-more-efficient-in-general-practice", ".mt-3")
i2021_aspca <- analyze_text("https://www.aspcapro.org/resource/new-aspca-survey-vast-majority-dogs-and-cats-acquired-during-pandemic-still-their-homes", ".paragraph--copy")
m2021_sa <- analyze_text("https://www.scientificamerican.com/article/home-alone-the-fate-of-postpandemic-dogs/", "#sa_body > div.opinion-article__wrapper > section.flex-container.container.flex-direction--column-tablet > article")
m2022_wapo <- analyze_text("https://www.washingtonpost.com/business/2022/01/07/covid-dogs-return-to-work/",".font-copy")
# I was not able to scrape this site so I pulled the text instead
#i2022_pfi <- analyze_text("https://www.petfoodindustry.com/articles/11748-pandemic-new-pet-boom-myth-busted-adoptions-lower-2021-22", "/html/body/div[5]/div[2]/div[1]/div[4]/div[1]")
i2022_pfi <- read_file("petfoodindustry2022.txt")
i2022_pfi_word <- tibble(text = i2022_pfi)
i2022_pfi_word <-  unnest_tokens(i2022_pfi_word, word_tokens,  text, token = "words") 
i2022_pfi <- anti_join(i2022_pfi_word, stop_words, by = c("word_tokens" = "word"))
i2022_pfi <- i2022_pfi %>% left_join(sentiment_nrc, by = c("word_tokens" = "word"))

# I attempted to write a function and loop to create the word count dfs but failed
#df_count <- function(df, column) {
#  count(df, column, sort = TRUE)
#}
#df_list <- c("m2020_nyt", "i2020_aspca", "i2021_dvm", "i2021_aspca", "m2021_sa", "m2022_wapo", "i2022_pfi")
#for (i in df_list) {            
#output <- df_count(i, nrc)      
#}

m2020_nyt_nrc <- count(m2020_nyt, nrc, sort = TRUE) %>% drop_na()
i2020_aspca_nrc <- count(i2020_aspca, nrc, sort = TRUE) %>% drop_na()
i2021_dvm_nrc <- count(i2021_dvm, nrc, sort = TRUE) %>% drop_na()
i2021_aspca_nrc <- count(i2021_aspca, nrc, sort = TRUE) %>% drop_na()
m2021_sa_nrc <- count(m2021_sa, nrc, sort = TRUE) %>% drop_na()
m2022_wapo_nrc <- count(m2022_wapo, nrc, sort = TRUE) %>% drop_na()
i2022_pfi_nrc <- count(i2022_pfi, nrc, sort = TRUE) %>% drop_na()

write.csv(m2020_nyt_nrc, "~/Documents/Data & Programming II/data_skills_2_r_project/Data/nyt2020_nrc.csv", row.names = FALSE)
write.csv(i2020_aspca_nrc, "~/Documents/Data & Programming II/data_skills_2_r_project/Data/aspca2020_nrc.csv", row.names = FALSE)
write.csv(i2021_dvm_nrc, "~/Documents/Data & Programming II/data_skills_2_r_project/Data/dvm2021_nrc.csv", row.names = FALSE)
write.csv(i2021_aspca_nrc, "~/Documents/Data & Programming II/data_skills_2_r_project/Data/aspca2021_nrc.csv", row.names = FALSE)
write.csv(m2021_sa_nrc, "~/Documents/Data & Programming II/data_skills_2_r_project/Data/sa2021_nrc.csv", row.names = FALSE)
write.csv(m2022_wapo_nrc, "~/Documents/Data & Programming II/data_skills_2_r_project/Data/wapo2022_nrc.csv", row.names = FALSE)
write.csv(i2022_pfi_nrc, "~/Documents/Data & Programming II/data_skills_2_r_project/Data/pfi2022_nrc.csv", row.names = FALSE)

# at first, I thought I would create one df with all the articles, but I struggled to make this work in Shiny, so I decided to stick to separate files
nrc_wordcloud_data <- m2020_nyt_nrc %>% full_join(i2020_aspca_nrc, by = "nrc", suffix = c("_20nyt", "_20aspca")) %>%
  full_join(i2021_dvm_nrc, by = "nrc", suffix = c("", "_21dvm")) %>%
  full_join(i2021_aspca_nrc, by = "nrc", suffix = c("", "_21aspca")) %>%
  full_join(m2021_sa_nrc, by = "nrc", suffix = c("", "_21sa")) %>%
  full_join(m2022_wapo_nrc, by = "nrc", suffix = c("", "_22wapo")) %>%
  full_join(i2022_pfi_nrc, by = "nrc", suffix = c("", "_22pfi"))

nrc_wordcloud_data <- nrc_wordcloud_data %>% rename(n_21dvm = n)

#experimenting with wordclouds before taking it to shiny
# sources I used for wordclouds: https://cran.r-project.org/web/packages/wordcloud2/vignettes/wordcloud.html
# https://statsandr.com/blog/draw-a-word-cloud-with-a-shiny-app/
# https://shiny.rstudio.com/gallery/word-cloud.html
# https://towardsdatascience.com/create-a-word-cloud-with-r-bde3e7422e8a
wordcloud(words = nrc_wordcloud_data$nrc, freq = nrc_wordcloud_data$n_20nyt, 
          min.freq = 1,           
          max.words = 200, 
          random.order = FALSE, 
          random.color = FALSE,
          rot.per = 0,            
          colors = brewer.pal(11, "Spectral"))

wordcloud2(nrc_wordcloud_data, 
           fontFamily = "sans",
           color = brewer.pal(11, "Spectral"))