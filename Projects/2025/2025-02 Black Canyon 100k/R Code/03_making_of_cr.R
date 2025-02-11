library(ggplot2)
library(dplyr)
library(readr)
library(tidyr)
library(lubridate)
library(fs)
library(stringr)

splits <- read_csv("Projects/2025/2025-02 Black Canyon 100k/black_canyon_2025_split_data.csv")

all_splits <- c("Antelope Mesa", "Hidden Treasure", "Bumble Bee", "Gloriana Mine", "Deep Canyon Ranch", "Black Canyon City",
                "Cottonwood Gulch", "Table Mesa", "Doe Spring", "Finish")


## Get the average paces for each split
format_pace <- function(x) {
  mins <- floor(x)
  seconds <- round((x - mins) * 60)
  str_c(mins, ":", seconds)
}

test <- splits %>%
  mutate(
    Distance = parse_number(Distance),
    time = hms(paste(Hours, Minutes, Seconds, sep = ":"))
  ) %>%
  group_by(`First Name`, `Last Name`, `Bib`, `Gender Pos`) %>%
  arrange(Distance) %>%
  mutate(
    gap_dist = Distance - lag(Distance),
    gap_time = time - lag(time)
  ) %>%
  ungroup() %>%
  mutate(pace = (as.numeric(as.duration(gap_time)) / gap_dist) / 60,
         pace = format_pace(pace))

test %>%
  filter(`First Name` == "Riley", `Last Name` == "Brady") %>%
  select(`Split Name`, `Hours`, `Minutes`, Seconds, pace)

test %>%
  filter(`First Name` == "Seth", `Last Name` == "Ruhling") %>%
  select(`Split Name`, `Hours`, `Minutes`, Seconds, pace)



test %>%
  mutate(
    gender = substr(`Gender Pos`, 1, 1),
    time_formatted = paste(Hours, Minutes, Seconds, sep = ":"),
    time_num = hms(time_formatted) %>% as.duration() %>% as.numeric()
  ) %>%
  filter(`Split Name` != "Start") %>%
  group_by(`Split Name`, gender) %>%
  arrange(time_num, `Last Name`) %>%
  mutate(gender_place = row_number()) %>%
  filter(`First Name` == "Seth", `Last Name` == "Ruhling") %>%
  select(`Split Name`, `Hours`, `Minutes`, Seconds, pace, gender_place)


test %>%
  mutate(
    gender = substr(`Gender Pos`, 1, 1),
    time_formatted = paste(Hours, Minutes, Seconds, sep = ":"),
    time_num = hms(time_formatted) %>% as.duration() %>% as.numeric()
  ) %>%
  filter(`Split Name` != "Start") %>%
  group_by(`Split Name`, gender) %>%
  arrange(time_num, `Last Name`) %>%
  mutate(gender_place = row_number()) %>%
  filter(`First Name` == "Riley", `Last Name` == "Brady") %>%
  select(`Split Name`, `Hours`, `Minutes`, Seconds, pace, gender_place)


test %>%
  mutate(
    gender = substr(`Gender Pos`, 1, 1),
    time_formatted = paste(Hours, Minutes, Seconds, sep = ":"),
    time_num = hms(time_formatted) %>% as.duration() %>% as.numeric()
  ) %>%
  filter(`Split Name` != "Start") %>%
  group_by(`Split Name`, gender) %>%
  arrange(time_num, `Last Name`) %>%
  mutate(gender_place = row_number()) %>%
  filter(gender == "F", gender_place %in% 1:10) %>%
  View()




