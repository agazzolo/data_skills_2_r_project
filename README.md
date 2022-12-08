Data & Programming 2 Final Project
Alexandra Gazzolo (cnet/gitid agazzolo)
COVID-19 Pet Adoption Boom: Fact or Fiction? 

# Introduction/Research Question
## There are three files with my code - wrangle_plot_analyze.r ; text_analysis.r ; and app.r
I remember reading many articles about the “pet adoption boom” during the early days of the pandemic and have many friends that adopted “pandemic puppies” and cats. I decided to examine whether there was such a boom, and how pet adoption trended with public health data. Simply put: was the pet adoption boom fact or fiction?

Initially I knew I needed to focus on shelter adoptions rather than pets acquired through other means (breeders, strays, community transfers, etc.) because this is the only data available. On Shelter Animals Count, I was lured in by a beautiful Tableau dashboard until I realized that I could not download the dashboard source data.  The only freely available data was by year rather than by month. I reached out to get monthly data to use for this project but even as a student, the organization requested a fee of $500. Because of this, I decided to shift my scope to consider length of stay-at-home orders rather than just covid cases and examine year-over-year trends from 2019-2021 rather than monthly trends from March 2020-March 2021. My expectation was that states with longer stay at home orders saw fewer adoptions because shelters were closed, but higher adoption rates as people wanted companions. 

# Data sources – four data sources, 1 retrieved through API key, 1 via web scraping. 
1.	Shelter Adoptions – Shelter Animals Count. This was the best available shelter data, though the free data was limited as I discussed above. 
https://www.shelteranimalscount.org/about-the-data/
2.	COVID-19 Cases - NYT data via github. There are many different sources of COVID-19 case data but the NYT data was already cleaned and aggregated to my needs, significantly simplifying the cleaning I needed to do. 
https://www.nytimes.com/article/coronavirus-county-data-us.html
3.	Lockdowns/Stay-At-Home Orders - Wikipedia had the most succinct data for SAH orders so I used webscraping to pull that table. 
https://en.wikipedia.org/wiki/U.S._state_and_local_government_responses_to_the_COVID-19_pandemic
4.	Population – Looking at the rest of this data loses a lot of meaning without considering the relative populations of US states. I used TidyCensus and an API key to get 2020 Census data on state populations. 

# Data Wrangling 
	I tried out several different data sets before settling on the four listed above. While other data sets (e.g. through the CDC, PetWatch, and others) had interesting info, the data was aggregated in such a way that made it incredibly difficult to clean and join to my other datasets. Once I settled on these four, I was able to clean each separately, standardizing state names, reformatting dates, and adding columns for rates. I was then able to join all the data sets into one. 

# Trends and Plots 
I created 6 static plots showing pet adoption trends, and a shiny app that showed word clouds for six different articles. 
In fact, total pet adoptions were lower in 2020 and 2021 than in 2019. However, this was because there were fewer pets coming to shelters and the pet adoption rate did in fact increase. 

# Analysis
First, a disclaimer that these results are virtually meaningless given the limits of the data. While this was already a narrow look at a complex problem, it was further constrained when I was not able to access extensive month-level data for 2020. I chose to focus on two variables and their relationship with pet adoptions: COVID-19 cases and the duration of stay-at-home-orders. I chose to use a basic OLS model to look at the data with an added control for population. I considered adding in additional controls for median household income and population density but in my initial data exploration I did not find that these controls dramatically changed the results so I left them out. If such data was available, I would be interested in adding a control for the existing pets in a given state to see how numbers of current pet owners impacted the number of new adoptions. 

In short, none of the regressions showed a statistically significant relationship. 

# Text Analysis – 7 articles, Interactive Shiny Visualization
When I started this project, I planned to look at how news articles reported on the pet adoption boom during the height of lockdown and through different variant outbreaks, vaccine development, and now. However, as I read various articles, I realized there appeared to be a significantly different tone in the articles in mainstream news sources (New York Times, Washington Post, CNN, etc.) and “industry” publications (ASPCA, Veterinary Associations, trade publications, etc.). Generally, the industry sources seemed to be more positive while mainstream news appeared to sensationalize or attempt to predict future issues (this is not very surprising). Because of this, I decided to take a deeper look at the text across time and also compare the sentiments in mainstream sources vs. industry sources. Initially, I looked at NRC, AFINN, and Bing, but there were very few words with AFINN and Bing rankings so I decided to concentrate on NRC. 

2020: New York Times – “A Guide for First Time Pet Owners During the Pandemic”
https://www.nytimes.com/2020/05/06/smarter-living/a-guide-for-first-time-pet-owners-during-the-pandemic.html?searchResultPosition=4
2020: ASPCA – “Over 570 Groups Complete 7,300 Adoptions During ASPCA National Adoption Weekend”
 https://www.aspcapro.org/news/2020/06/10/over-570-groups-complete-7300-adoptions-during-aspca-national-adoption-weekend
2021: DVM360 – “The COVID-19 Pet Adoption Boom: Did it Really Happen?”
https://www.dvm360.com/view/the-covid-19-pet-adoption-boom-did-it-really-happen-
2021: ASPCA – “New ASPCA Survey: Vast Majority of Dogs and Cats Acquired During Pandemic Still in Their Homes”
https://www.aspcapro.org/resource/new-aspca-survey-vast-majority-dogs-and-cats-acquired-during-pandemic-still-their-homes
2021: Scientific American: “Home Alone: The Fate of Postpandemic Dogs”
https://www.scientificamerican.com/article/home-alone-the-fate-of-postpandemic-dogs/
2022: Pet Food Industry - “Pandemic new pet boom myth busted; Adoptions lower 2021-22”
https://www.petfoodindustry.com/articles/11748-pandemic-new-pet-boom-myth-busted-adoptions-lower-2021-22
 2022: Washington Post – “Americans adopted millions of dogs during the pandemic. Now what do we do with them?”
https://www.washingtonpost.com/business/2022/01/07/covid-dogs-return-to-work/

My initial reactions were correct: industry sources tended to be more positive than mainstream news. In 2020, both the New York Times and the ASPCA both appeared very positive about the apparent increase in pet adoptions. In 2021, industry news like the DVM 360 and ASPCA are still positive, though slightly more tempered. In contrast, the mainstream source (Scientific American) is split across positive and negative words, but with a significant jump in words tied to fear and sadness. In 2022, the mainstream source (Washington Post) continues to be incredibly split: the top four NRC sentiments found are: positive, trust, negative, and fear. Interestingly, the industry source in 2022 trends negative. In reading this article, it appears most focused on debunking the boom myth. 

# A note on Shiny: 
Considering that there was not a significant relationship between pet adoption and either COVID-19 cases or staty at home orders, I decided to focus my Shiny plots on the text analysis. I initially used the wordcloud package to explore this data, but I was not able to get it working with Shiny. Instead, I used wordcloud2 which worked much better but seemed to offer fewer opportunities for customization. Also, while my shiny app was working well initially, in my final testing I started getting errors with the working directory so I saved the shiny app file in the data folder along with the data sets I used. 

Here is a link to the Shiny web app I published: https://agazzolo.shinyapps.io/Final_Project_Pet_Adoption_Text_Analysis/



