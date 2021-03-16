library(tidyverse)
library(dplyr)
library(readxl)

path <- "C:/Users/balas/OneDrive/Documents/Harris/Data_and_Programming_II/Homework/final_project/"

etana <- read_excel(paste0(path, "Etana EIA Results - Updated.xlsx"), skip = 2)

etana <- etana %>%
  mutate(construction_status = case_when(`Sample date` > "2014-10-16" & `Sample date` < "2014-12-21" ~ "Demo",
                                         `Sample date` > "2014-12-21" & `Sample date` < "2015-04-06" ~ "No Construction",
                                         `Sample date` > "2015-04-05" & `Sample date` < "2015-11-30" ~ "Active Construction"),
         name = "etana") %>%
  select(everything(), -`Sample #`)

sabrena <- read_excel(paste0(path, "Sabrena EIA Results - Updated.xlsx"), skip = 2)

sabrena <- sabrena %>%
  mutate(construction_status = case_when(`Sample date` > "2014-10-16" & `Sample date` < "2014-12-21" ~ "Demo",
                                         `Sample date` > "2014-12-21" & `Sample date` < "2015-04-06" ~ "No Construction",
                                         `Sample date` > "2015-04-05" & `Sample date` < "2015-11-30" ~ "Active Construction"),
         name = "sabrena") %>%
  select(everything(), -`Sample #`)

df <- full_join(sabrena, etana, by = c(colnames(etana)))

colnames(etana)
# scatter plots 
etana %>%
  ggplot(aes(x = `Sample date`, y = `CC (pg/well)`, color = construction_status)) +
    geom_point() +
    stat_smooth(method = "lm")

etana %>%
  ggplot(aes(x = `Sample date`, y = `CC (pg/ml)`)) +
  geom_point()

etana %>%
  ggplot(aes(x = `Sample date`, y = Amount)) +
  geom_point()

# line graphs
etana %>%
  ggplot(aes(x = `Sample date`, y = `CC (pg/well)`)) +
  geom_line()

etana %>%
  ggplot(aes(x = `Sample date`, y = `CC (pg/ml)`)) +
  geom_line()

etana %>%
  ggplot(aes(x = `Sample date`, y = Amount)) +
  geom_line()

# lm by construction status
etana %>%
  ggplot(aes(x = `Sample date`, y = `CC (ng/g)`, color = construction_status)) +
  geom_point() +
  stat_smooth(method = "lm")

df %>%
  ggplot(aes(x = `Sample date`, y = `CC (ng/g)`, color = construction_status)) +
  geom_point() +
  stat_smooth(method = "lm")

# histograms
etana %>%
  ggplot(aes(x = `CC (ng/g)`)) +
  geom_histogram(bins = 80)

etana %>%
  filter(construction_status == "Demo") %>%
  ggplot(aes(x = `CC (ng/g)`)) +
    geom_histogram(bins = 10)

df %>%
  ggplot(aes(x = `CC (ng/g)`)) +
  geom_histogram(bins = 50)

df %>%
  filter(construction_status == "Demo") %>%
  ggplot(aes(x = `CC (ng/g)`)) +
  geom_histogram(bins = 30)
