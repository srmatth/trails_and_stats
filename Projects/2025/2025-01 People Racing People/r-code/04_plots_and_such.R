## Plots and such

library(ggplot2)
library(dplyr)
library(maps)
library(readr)


df <- read_csv("data/race-info.csv")

# Get world map data
world_map <- map_data("world")

# Plot the world map with race locations
ggplot() +
  geom_polygon(data = world_map, aes(x = long, y = lat, group = group), fill = "white", color = "grey") +
  geom_point(data = df, aes(x = longitude, y = latitude), color = "red", alpha = 0.6, size = 2) +
  coord_fixed(1.4) +
  theme_void()

# Get North America map data
north_america_map <- map_data("state")

# Plot only North America
ggplot() +
  geom_polygon(data = north_america_map, aes(x = long, y = lat, group = group), fill = "white", color = "grey") +
  geom_point(data = df, aes(x = longitude, y = latitude), color = "red", alpha = 0.6, size = 2) +
  coord_fixed(1.4) +
  xlim(-128, -65) + ylim(25, 50) + # Zooming in on North America
  theme_void()
