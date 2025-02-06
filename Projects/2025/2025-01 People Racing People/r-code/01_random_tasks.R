## Random small tasks needed during the analysis

## Setup ----

# Load Libraries
library(readr)
library(dplyr)
library(ggplot2)

## Read in the UROY Data
uroy <- read_csv("data/uroy-results.csv")


## Races ----

# Get the unique Races
unique_races <- unique(uroy$Race) %>% sort()
print(unique_races)

# save them to a .csv (to be added to)
unique_race_files <- fs::dir_ls("data/race_results") %>% fs::path_file() %>%
  stringr::str_remove("\\.csv$")
write_csv(data.frame(race = unique_race_files), "data/race-info.csv")

# number of times races were run by UROY top 10
uroy %>%
  group_by(Race) %>%
  summarize(n = n()) %>%
  arrange(desc(n)) %>%
  View()

uroy %>%
  filter(Race == "Tunnel Hill")







