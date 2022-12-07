#File 1 of 3 - data sources and wrangling, static plots, and regression analysis
library(tidyverse)
library(lubridate)
library(rvest)
library(tidycensus)
library(tidytext)
library(nametagger)
library(udpipe)
library(stargazer)

# code sources: for splitting date column: https://stackoverflow.com/questions/4078502/split-date-data-m-d-y-into-3-separate-columns
# for updating state column IDs: https://stackoverflow.com/questions/53639594/how-to-use-mutate-to-add-column-with-state-names-based-on-the-state-abbreviation
adopt <- read_csv("sac_aggregate_dataset_2019_2021.csv")
covid <- read_csv("us-states-new.csv")
covid$date <- as.Date(covid$date)
covid <- covid %>% mutate(
  year = as.numeric(format(date, format = "%Y")),
  month = as.numeric(format(date, format = "%m")),
  day = as.numeric(format(date, format = "%d")))
covid_yr <- covid %>% group_by(state, year) %>% summarise(cases = sum(cases))
url <- "https://en.wikipedia.org/wiki/U.S._state_and_local_government_responses_to_the_COVID-19_pandemic"
request <- read_html(url)
table <- html_table(request, fill = TRUE)
View(table[[3]])
lockdowns <- table[[3]]
colnames(lockdowns) <- c('State_del',
                         'State',
                         'Emergency_Declared', 
                         'Stay_At_Home_Ordered', 
                         'Stay_At_Home_Lifted',
                         'Masks_Required',
                         'Gatherings',
                         'Travel_Restrictions',
                         'Closures_School',
                         'Closures_Daycare',
                         'Closures_Restaurants',
                         'Closures_Retail',
                         'Sources')
lockdowns <- lockdowns %>% select(!c(State_del, 
                                     Gatherings, 
                                     Travel_Restrictions, 
                                     Closures_School,
                                     Closures_Daycare,
                                     Closures_Restaurants,
                                     Closures_Retail,
                                     Sources))
lockdowns <- lockdowns %>% mutate(SAH = ifelse(Stay_At_Home_Ordered == 'No', 0, 1))
lockdowns = lockdowns[-1,]
lockdowns <- lockdowns %>% separate(Stay_At_Home_Ordered, c("Start_Month", "Start_Day")) 
lockdowns <- lockdowns %>% separate(Stay_At_Home_Lifted, c("End_Month", "End_Day"))
lockdowns$Start_Month <- na_if(lockdowns$Start_Month, "No")
lockdowns$End_Month <- na_if(lockdowns$End_Month, "No")
lockdowns$End_Month <- na_if(lockdowns$End_Month, "N")
lockdowns$End_Day <- na_if(lockdowns$End_Day, "a")
lockdowns$End_Day <- na_if(lockdowns$End_Day, "advisory")
lockdowns$year <- 2020
lockdowns$Start_Date <- as.Date(paste(lockdowns$year, lockdowns$Start_Month, lockdowns$Start_Day, sep = "-"),"%Y-%b-%d")
lockdowns$End_Date <- as.Date(paste(lockdowns$year, lockdowns$End_Month, lockdowns$End_Day, sep = "-"),"%Y-%b-%d")
lockdowns$SAH_Duration <- lockdowns$End_Date - lockdowns$Start_Date
lockdown_clean <- lockdowns %>% select(c(State, SAH, Start_Date, End_Date, SAH_Duration))

feline_intake <- c("Intake - Relinquished By Owner Total-Feline", 
                   "Intake - Stray At Large Total-Feline", 
                   "Intake - Transferred In Total-Feline", 
                   "Intake - Owner Intended Euthanasia Total-Feline")
canine_intake <- c("Intake - Relinquished By Owner Total-Canine",
                   "Intake - Stray At Large Total-Canine",
                   "Intake - Transferred In Total-Canine", 
                   "Intake - Owner Intended Euthanasia Total-Canine",
                   "Intakes - Other Intakes Total-Canine")

adopt$feline_intake_total <- adopt$`Intake - Relinquished By Owner Total-Feline` + adopt$`Intake - Stray At Large Total-Feline` + adopt$`Intake - Transferred In Total-Feline` + adopt$`Intake - Owner Intended Euthanasia Total-Feline` + adopt$`Intakes - Other Intakes Total-Feline`
adopt$canine_intake_total <- adopt$`Intake - Relinquished By Owner Total-Canine` + adopt$`Intake - Stray At Large Total-Canine` + adopt$`Intake - Transferred In Total-Canine` + adopt$`Intake - Owner Intended Euthanasia Total-Canine` + adopt$`Intakes - Other Intakes Total-Canine`
adopt$intake_total <- adopt$feline_intake_total + adopt$canine_intake_total
adopt$adoption_total <- adopt$`Live Outcome - Adoption Total-Feline` + adopt$`Live Outcome - Adoption Total-Canine`
adopt_clean <- adopt %>% select(c(State, Year, feline_intake_total, canine_intake_total, intake_total, `Live Outcome - Adoption Total-Feline`, `Live Outcome - Adoption Total-Canine`, adoption_total))

Sys.getenv("CENSUS_API_KEY")
# variables <- load_variables(2020, "pl", cache = FALSE)
state_pop <- get_decennial(geography = "state", 
                           variables = c(population = "P1_001N"), 
                           year = 2020)
state_pop <- state_pop %>% rename(Population = value) %>%
  select(c(NAME, Population))
adopt_clean <- adopt_clean %>% 
  mutate(State = state.name[match(State, state.abb)])

data <- left_join(adopt_clean, covid_yr, by = c("State" = "state", "Year" = "year"))
data <- left_join(data, state_pop, by = c("State" = "NAME"))
data <- left_join(data, lockdown_clean, by = "State")

# dropping US Territories and adding adoption rate and adoptions per capita
data <- data %>% drop_na(State)
data$adoption_rate <- data$adoption_total/data$intake_total
data$adoption_percap <- data$adoption_total/data$Population
write.csv(data, "~/Documents/Data & Programming II/data_skills_2_r_project/Data/data_clean.csv", row.names = FALSE)

#filtered data frames to simplify plotting
data2020 <- data %>% filter(Year == 2020) %>%
  mutate(across(SAH_Duration, ~ ifelse(is.na(.), 0, .)))
data_cases <- data %>% filter(Year != 2019) %>%
  mutate(across(cases, ~ ifelse(is.na(.), 0, .)))

ggplot(data2020, aes(SAH_Duration, adoption_percap)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Duration of Stay-At-Home Orders and Adoptions Per Capita, 2020") +
  xlab("Duration of Stay-At-Home Orders, in days") +
  ylab("Pet Adoptions Per Capita")  

ggplot(data2020, aes(SAH_Duration, adoption_rate)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Duration of Stay-At-Home Orders and Pet Adoption Rate, 2020") +
  xlab("Duration of Stay-At-Home Orders, in days") +
  ylab("Pet Adoption Rate")

ggplot(data_cases, aes(cases, adoption_percap)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Number of COVID-19 Cases and Pet Adoptions Per Capita, 2020-2021") +
  xlab("Annual Number of COVID-19 Cases") +
  ylab("Pet Adoptions Per Capita")

ggplot(data_cases, aes(cases, adoption_rate)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Number of COVID-19 Cases and Pet Adoption Rate, 2020-2021") +
  xlab("Annual Number of COVID-19 Cases") +
  ylab("Pet Adoption Rate")

#source for geom_map tips: https://ggplot2.tidyverse.org/reference/geom_map.html
state <- tolower(data$State)
map <- map_data("state")
ggplot(data, aes(map_id = state)) +
  geom_map(aes(fill = adoption_rate), map = map) +
  coord_sf(
    crs = 5070, default_crs = 4326,
    xlim = c(-125, -70), ylim = c(25, 52)
  ) +
  facet_wrap(~Year) +
  labs(title = "Shelter Pet Adoption Rate in the US, 2019-2021")

ggplot(data, aes(map_id = state)) +
  geom_map(aes(fill = adoption_percap), map = map) +
  coord_sf(
    crs = 5070, default_crs = 4326,
    xlim = c(-125, -70), ylim = c(25, 52)
  ) +
  facet_wrap(~Year) +
  labs(title = "Shelter Pet Adoption Per Capita in the US, 2019-2021")


reg_adopt_cases <- lm(adoption_total ~ cases + Population, data = data_cases)
stargazer(reg_adopt_cases, type = "text")
reg_adoptrate_cases <- lm(adoption_rate ~ cases + Population, data = data_cases)
stargazer(reg_adoptrate_cases, type = "text")
reg_adopt_SAH <- lm(adoption_total ~ SAH_Duration + Population, data = data2020)
stargazer(reg_adopt_SAH, type = "text")
reg_adoptrate_SAH <- lm(adoption_rate ~ SAH_Duration + Population, data = data2020)
stargazer(reg_adoptrate_SAH, type = "text")