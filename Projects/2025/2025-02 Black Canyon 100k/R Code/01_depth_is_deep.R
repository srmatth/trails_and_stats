library(dplyr)
library(ggplot2)
library(readr)
library(fs)
library(stringr)
library(lubridate)

race_files <- fs::dir_ls("Projects/2025/2025-02 Black Canyon 100k/data")

all_results <- data.frame()
for (race in race_files) {
  year <- path_file(race) %>%
    str_remove("\\.csv") %>%
    str_split("_") %>%
    `[[`(1) %>%
    `[`(length(.))
  tmp <- read_csv(race, col_types = "dccccdcdc") %>%
    mutate(year = year)
  all_results <- all_results %>%
    bind_rows(tmp)
}

finishers <- all_results %>%
  filter(!is.na(`First Name`), Position != 0) %>%
  mutate(time_format = as.duration(hms(Time)), year = as.numeric(year)) %>%
  group_by(year, Gender) %>%
  arrange(time_format) %>%
  mutate(
    gender_place = row_number()
  )

finishers %>%
  filter(Gender == "M", gender_place %in% c(1, 10, 20, 40, 60, 80, 100)) %>%
  mutate(time_format = time_format / 3600) %>%
  ggplot() +
  aes(x = year, y = time_format, group = as.factor(gender_place)) +
  geom_line() +
  geom_point()

# Let's make this plot a lot fancier

points <- finishers %>%
  filter(Gender == "M", gender_place <= 100) %>%
  mutate(time_format = time_format / 3600)
bold_points <- finishers %>%
  filter(Gender == "M", gender_place %in% c(1, 10, 20, 40, 60, 80, 100)) %>%
  mutate(time_format = time_format / 3600)
lines <- finishers %>%
  filter(Gender == "M", gender_place <= 100, year != 2019) %>%
  mutate(time_format = time_format / 3600)
bold_lines <- finishers %>%
  filter(Gender == "M", gender_place %in% c(1, 10, 20, 40, 60, 80, 100), year != 2019) %>%
  mutate(time_format = time_format / 3600)

p_m <- ggplot() +
  geom_line(
    data = lines %>% filter(year < 2019),
    aes(x = year, y = time_format, group = gender_place, color = gender_place),
    lwd = 0.5, alpha = 0.25
  ) +
  geom_line(
    data = bold_lines %>% filter(year < 2019),
    aes(x = year, y = time_format, group = gender_place, color = gender_place),
    lwd = 1
  ) +
  geom_line(
    data = lines %>% filter(year > 2019),
    aes(x = year, y = time_format, group = gender_place, color = gender_place),
    lwd = 0.5, alpha = 0.25
  ) +
  geom_line(
    data = bold_lines %>% filter(year > 2019),
    aes(x = year, y = time_format, group = gender_place, color = gender_place),
    lwd = 1
  ) +
  geom_line(
    data = bold_lines %>% filter(year %in% c(2018, 2020)),
    aes(x = year, y = time_format, group = gender_place, color = gender_place),
    lwd = 1, lty = "dashed"
  ) +
  # geom_line(
  #   data = lines %>% filter(year %in% c(2018, 2020)),
  #   aes(x = year, y = time_format, group = gender_place),
  #   lwd = 0.5, alpha = 0.25, lty = "dashed"
  # ) +
  geom_point(
    data = points,
    aes(x = year, y = time_format, color = gender_place),
    size = 1,
    alpha = 0.25
  ) +
  geom_point(
    data = bold_points,
    aes(x = year, y = time_format, color = gender_place),
    size = 3
  ) +
  theme_bw() +
  scale_color_gradient2(high = "#453F3C", low = "#E55934", mid = "#CE8D66", midpoint = 50) +
  theme(
    legend.position = "None",
    text = element_text(family = "Times"),
    axis.line = element_blank(),
    axis.ticks.y = element_blank(),
    panel.grid.major.x = element_blank(),
    axis.text.x = element_text(size = 16)
  ) +
  scale_x_continuous(breaks = 2014:2025, minor_breaks = NULL) +
  scale_y_continuous(breaks = seq(8, 20, by = 2), minor_breaks = NULL) +
  xlab("") +
  ylab("")
p_m

points <- finishers %>%
  filter(Gender == "F", gender_place <= 100) %>%
  mutate(time_format = time_format / 3600)
bold_points <- finishers %>%
  filter(Gender == "F", gender_place %in% c(1, 10, 20, 40, 60, 80, 100)) %>%
  mutate(time_format = time_format / 3600)
lines <- finishers %>%
  filter(Gender == "F", gender_place <= 100, year != 2019) %>%
  mutate(time_format = time_format / 3600)
bold_lines <- finishers %>%
  filter(Gender == "F", gender_place %in% c(1, 10, 20, 40, 60, 80, 100), year != 2019) %>%
  mutate(time_format = time_format / 3600)

p_w <- ggplot() +
  geom_line(
    data = lines %>% filter(year < 2019),
    aes(x = year, y = time_format, group = gender_place, color = gender_place),
    lwd = 0.5, alpha = 0.25
  ) +
  geom_line(
    data = bold_lines %>% filter(year < 2019),
    aes(x = year, y = time_format, group = gender_place, color = gender_place),
    lwd = 1
  ) +
  geom_line(
    data = lines %>% filter(year > 2019),
    aes(x = year, y = time_format, group = gender_place, color = gender_place),
    lwd = 0.5, alpha = 0.25
  ) +
  geom_line(
    data = bold_lines %>% filter(year > 2019),
    aes(x = year, y = time_format, group = gender_place, color = gender_place),
    lwd = 1
  ) +
  geom_line(
    data = bold_lines %>% filter(year %in% c(2018, 2020)),
    aes(x = year, y = time_format, group = gender_place, color = gender_place),
    lwd = 1, lty = "dashed"
  ) +
  # geom_line(
  #   data = lines %>% filter(year %in% c(2018, 2020)),
  #   aes(x = year, y = time_format, group = gender_place),
  #   lwd = 0.5, alpha = 0.25, lty = "dashed"
  # ) +
  geom_point(
    data = points,
    aes(x = year, y = time_format, color = gender_place),
    size = 1,
    alpha = 0.25
  ) +
  geom_point(
    data = bold_points,
    aes(x = year, y = time_format, color = gender_place),
    size = 3
  ) +
  theme_bw() +
  scale_color_gradient2(high = "#453F3C", low = "#E55934", mid = "#CE8D66", midpoint = 50) +
  theme(
    legend.position = "None",
    text = element_text(family = "Times"),
    axis.line = element_blank(),
    axis.ticks.y = element_blank(),
    panel.grid.major.x = element_blank(),
    axis.text.x = element_text(size = 16)
  ) +
  scale_x_continuous(breaks = 2014:2025, minor_breaks = NULL) +
  scale_y_continuous(breaks = seq(8, 20, by = 2), minor_breaks = NULL) +
  xlab("") +
  ylab("")
p_w

library(patchwork)

p_m / p_w

finishers %>%
  group_by(year, Gender) %>%
  count()


all_results %>%
  filter(!is.na(`First Name`)) %>%
  group_by(year) %>%
  summarize(num_dnf_dns = sum(Position == 0), n = n()) %>%
  mutate(pct_dnf = num_dnf_dns / n) %>%
  ggplot() +
  aes(x = year, y = n,
      width = 0.4) +
  geom_bar(stat = "identity") +
  theme_bw() +
  theme(
    legend.position = "None",
    text = element_text(family = "Times"),
    axis.line = element_blank(),
    axis.ticks = element_blank(),
    panel.grid.major.x = element_blank(),
    axis.text.x = element_blank()
  )






