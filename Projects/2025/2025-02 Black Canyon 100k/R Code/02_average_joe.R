library(ggplot2)
library(dplyr)
library(readr)
library(tidyr)
library(lubridate)
library(fs)

splits <- read_csv("Projects/2025/2025-02 Black Canyon 100k/black_canyon_2025_split_data.csv")

all_splits <- c("Antelope Mesa", "Hidden Treasure", "Bumble Bee", "Gloriana Mine", "Deep Canyon Ranch", "Black Canyon City",
                "Cottonwood Gulch", "Table Mesa", "Doe Spring", "Finish")


## Get the average paces for each split

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
  mutate(pace = (as.numeric(as.duration(gap_time)) / gap_dist) / 60)


test %>%
  filter(`Split Name` != "Start", pace < 35) %>%
  mutate(split = factor(`Split Name`, levels = all_splits, ordered = TRUE)) %>%
  ggplot() +
  aes(x = pace) +
  geom_boxplot()+
  facet_wrap(~split, scales = "free_y") +
  theme_bw() +
  theme(
    strip.text = element_blank(),
    panel.grid = element_blank(),
    axis.text.y = element_blank(),
    axis.ticks.y = element_blank()
  )

format_pace <- function(x) {
  mins <- floor(x)
  seconds <- round((x - mins) * 60)
  str_c(mins, ":", seconds)
}


test %>%
  filter(`Split Name` != "Start", pace < 35) %>%
  mutate(split = factor(`Split Name`, levels = all_splits, ordered = TRUE),
         gender = substr(`Gender Pos`, 1, 1))  %>%
  filter(gender != "X") %>%
  group_by(split, gender) %>%
  summarize(
    min = min(pace) %>% format_pace(),
    median = median(pace) %>% format_pace(),
    avg = mean(pace) %>% format_pace(),
    max = max(pace) %>% format_pace()
  )

test %>%
  filter(`Split Name` != "Start", pace < 35) %>%
  mutate(split = factor(`Split Name`, levels = all_splits, ordered = TRUE),
         gender = substr(`Gender Pos`, 1, 1))  %>%
  filter(gender != "X") %>%
  group_by(split) %>%
  summarize(
    min = min(pace) %>% format_pace(),
    median = median(pace) %>% format_pace(),
    avg = mean(pace) %>% format_pace(),
    max = max(pace) %>% format_pace()
  )

test%>%
  select(`Split Name`, gap_dist) %>%distinct()


## Two new records code

