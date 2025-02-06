# Load necessary libraries
library(dplyr)
library(lubridate)
library(future)
library(furrr)

results_dat <- readr::read_csv("data/all-results-no-dnfs.csv")
df <- results_dat %>%
  select(race_name, runner_name = name, gender, gender_position, race_date) %>%
  filter(
    gender_position <= 75#,
    # gender == "M"
    # race_name %in% c(
    #   # "Crown King Scramble",
    #   # # "Moab 240",
    #   # # "Cocodona",
    #   # "Leadville Silver Rush",
    #   # "Leadville",
    #   # "Javelina Jundred"# ,
    #   # # "Western States",
    #   # # "Black Canyon 100K"
    #   "Dead Horse",
    #   "Courmayeur-Champex-Chamonix (CCC) (Italy)",
    #   "Red Mountain",
    #   "Moab Red Hot",
    #   "Arches",
    #   "Behind the Rocks",
    #   "Madeira Island Ultra Trail (Portugal)",
    #   "Western States"
    # )
  ) %>%
  mutate(
    runner_name = ifelse(runner_name == "hannah allgood", "hannah osowski", runner_name)
  )

# ELO parameters
BASE_K <- 10  # Base K-factor for ELO updates
INITIAL_RATING <- 400

# Function to calculate ELO probability
elo_prob <- function(rating_a, rating_b) {
  return(1 / (1 + 10^((rating_b - rating_a) / 400)))
}

# Normalize K-factor based on race size (inversely proportional)
normalize_k <- function(base_k, num_competitors) {
  # matchups <- choose(num_competitors, 2)
  return(base_k)
}

# Initialize ELO ratings
initialize_elo <- function(df) {
  df %>%
    select(runner_name, gender) %>%
    filter(gender != "X") %>%
    distinct() %>%
    mutate(elo = INITIAL_RATING)
}

# # Process races sequentially with a given order
# process_races <- function(df, elo_ratings) {
#   for (race in unique(df$race_name)) {
#     cat(race,"\n")
#     race_results <- df %>%
#       filter(race_name == race) %>%
#       arrange(gender, gender_position)
#
#     for (gender in unique(race_results$gender)) {
#       gender_results <- race_results %>% filter(gender == !!gender)
#
#       # Compute normalized K for this race
#       num_competitors <- nrow(gender_results)
#       K <- normalize_k(BASE_K, num_competitors)
#
#       # Skip if there are fewer than 2 competitors
#       if (nrow(gender_results) < 2) next
#       if (gender == "X") next
#
#       for (i in 1:(nrow(gender_results) - 1)) {
#         winner <- gender_results$runner_name[i]
#         rating_winner <- elo_ratings$elo[elo_ratings$runner_name == winner]
#
#         # Compare winner to everyone beneath them
#         for (j in (i + 1):nrow(gender_results)) {
#           loser <- gender_results$runner_name[j]
#           rating_loser <- elo_ratings$elo[elo_ratings$runner_name == loser]
#
#           # Compute ELO probabilities
#           expected_winner <- elo_prob(rating_winner, rating_loser)
#           expected_loser <- elo_prob(rating_loser, rating_winner)
#
#           if (length(elo_ratings$elo[elo_ratings$runner_name == loser]) > 1) print(loser)
#
#           # Update ratings
#           elo_ratings$elo[elo_ratings$runner_name == winner] <- max(0, rating_winner + K * (1 - expected_winner))
#           elo_ratings$elo[elo_ratings$runner_name == loser] <- rating_loser + K * (0 - expected_loser)
#         }
#       }
#     }
#   }
#   return(elo_ratings)
# }

process_races <- function(df, elo_ratings) {
  for (race in unique(df$race_name)) {
    cat(race,"\n")
    race_results <- df %>%
      filter(race_name == race) %>%
      arrange(gender, gender_position)


    for (gender in unique(race_results$gender)) {
      gender_results <- race_results %>% filter(gender == !!gender)

      # Skip if there are fewer than 2 competitors
      if (nrow(gender_results) < 2) next
      if (gender == "X") next


      num_competitors <- nrow(gender_results)  # Total competitors in the race
      # Compute normalized K for this race
      K <- normalize_k(BASE_K, num_competitors)

      # Initialize a change vector for all runners
      elo_changes <- setNames(rep(0, nrow(gender_results)), gender_results$runner_name)

      for (i in 1:(nrow(gender_results) - 1)) {
        # print(i)
        winner <- gender_results$runner_name[i]
        rating_winner <- elo_ratings$elo[elo_ratings$runner_name == winner]

        # Compare winner to everyone beneath them
        for (j in (i + 1):nrow(gender_results)) {
          loser <- gender_results$runner_name[j]
          rating_loser <- elo_ratings$elo[elo_ratings$runner_name == loser]

          # Compute ELO probabilities
          expected_winner <- elo_prob(rating_winner, rating_loser)
          expected_loser <- 1 - expected_winner  # Complementary probability

          # Compute individual ELO updates
          winner_change <- K * (1 - expected_winner)
          loser_change <- K * (0 - expected_loser)

          # Accumulate changes
          # print(winner)
          elo_changes[winner] <- elo_changes[winner] + winner_change
          elo_changes[loser] <- elo_changes[loser] + loser_change
        }
      }

      # Apply summed changes after processing the race
      for (runner in names(elo_changes)) {
        elo_ratings$elo[elo_ratings$runner_name == runner] <-
          elo_ratings$elo[elo_ratings$runner_name == runner] + elo_changes[runner]
      }
    }
  }
  return(elo_ratings)
}

to_map_over <- function(df, start_date) {
  cat("\n------------------\n", as.character(start_date), "\n")

  # Find first race after the given start date
  first_race_index <- which(df$race_date >= start_date)[1]

  if (is.na(first_race_index)) {
    first_race_index <- 1  # Default to first race if no match
  }

  # Create a wrapped race order
  race_order <- rbind(df[first_race_index:nrow(df), ], df[1:(first_race_index-1), ])

  # Reset initial ratings
  elo_ratings <- initialize_elo(df)

  # Process races in wrapped order
  final_ratings <- process_races(race_order, elo_ratings)
  final_ratings %>%
    mutate(window_start = as.character(start_date))
}

# Compute ELO for each rotated start month
compute_wrapped_elo <- function(df, elo_ratings) {
  # Ensure races are sorted by date
  df <- df %>% arrange(race_date)

  # Generate all 12 iterations
  start_months <- seq(ymd("2024-01-01"), ymd("2024-12-01"), by = "month")
  all_elo <- list()
  race_dates <- df %>%
    select(race_name, race_date) %>%
    distinct() %>%
    arrange(race_date)
  num_races <- nrow(race_dates)

  plan(multisession, workers = 6)

  res <- furrr::future_map_dfr(
    .x = start_months,
    .f = to_map_over,
    df = df
  )

  # Combine results from all windows
  return(res)
}

# Initialize ELO ratings
elo_ratings <- initialize_elo(df)

# Compute wrapped ELO rankings
wrapped_elo <- compute_wrapped_elo(df, elo_ratings)

# View results
print(wrapped_elo)

final_elo <- wrapped_elo %>%
  group_by(runner_name, gender) %>%
  summarize(elo = mean(elo)) %>%
  arrange(desc(elo)) %>%
  group_by(gender) %>%
  mutate(rank = row_number())

final_elo %>%
  write_csv("data/elo-results.csv")

final_elo %>% filter(runner_name == "courtney olsen")

df %>%
  filter(runner_name == "hannah osowski")

final_elo %>%
  filter(gender %in% c("M", "F")) %>%
  arrange(rank) %>% head(n = 30) %>%
  print(n = 30)

results_dat %>%
  filter(name == "caleb olson")






