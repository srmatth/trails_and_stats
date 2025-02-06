## Create Big Ranking Data ----

## Setup ----

# Load libraries
library(readr)
library(fs)
library(dplyr)
library(stringr)

# Read in race info
race_info <- read_csv("data/race-info.csv")

# list race datasets
race_files <- dir_ls("data/race_results")

# mapping of which race files are in which formats
race_mapping <- read_csv("data/race-data-map.csv")


## Race File Logic ----

# The goal is to get a file with the following columns:
# race name, race date, participant name, gender place
res <- data.frame()
failed <- c()
for (file in race_files) {
  tmp_dat <- read_csv(file)
  race_name <- path_file(file) %>%
    stringr::str_remove("\\.csv$")
  race_type <- race_mapping %>%
    filter(race == race_name) %>%
    pull(type)
  if (race_type == "ultrasignup") {
    file_res <- tmp_dat %>%
      mutate(
        name = str_c(tolower(`First Name`), tolower(`Last Name`), sep = " "),
        race_name = race_name,
        Position = ifelse(Position == 0, max(Position) + 1, Position) # dealing with DNFs and DNSs
      ) %>%
      group_by(Gender) %>%
      mutate(
        gender_position = dense_rank(Position)
      ) %>%
      ungroup() %>%
      select(
        race_name,
        name,
        gender = Gender,
        gender_position
      )
  } else if (race_type == "itra") {
    file_res <- tmp_dat %>%
      tidyr::separate(Runner, into = c("LastName", "FirstName"), sep = " ", extra = "merge") %>%
      mutate(
        name = paste(tolower(FirstName), tolower(LastName)),
        race_name = race_name,
        did_dnf = ifelse(Place %in% c("DNF", "DNS") , 1, 0),
        Place = as.numeric(Place),
        Place = ifelse(did_dnf, max(Place, na.rm = TRUE) + 1, Place)
      ) %>%
      group_by(Gender) %>%
      mutate(
        gender_position = dense_rank(Place)
      ) %>%
      ungroup() %>%
      select(
        race_name,
        name,
        gender = Gender,
        gender_position
      )
  } else if (race_type %in% c("runsignup", "ultrarunning")) {
    file_res <- tmp_dat %>%
      mutate(
        name = tolower(Name),
        race_name = race_name,
        did_dnf = ifelse(Place %in% c("DNF", "DNS") , 1, 0),
        Place = as.numeric(Place),
        Place = ifelse(did_dnf, max(Place, na.rm = TRUE) + 1, Place)
      ) %>%
      group_by(Gender) %>%
      mutate(
        gender_position = dense_rank(Place)
      ) %>%
      ungroup() %>%
      select(
        race_name,
        name,
        gender = Gender,
        gender_position
      )
  } else if (race_type == "pacific") {
    file_res <- tmp_dat %>%
      tidyr::separate(Name, into = c("LastName", "FirstName"), sep = ", ", extra = "merge") %>%
      mutate(
        name = paste(tolower(FirstName), tolower(LastName)),
        race_name = race_name,
        Gender = str_sub(AG, 1, 1),
        did_dnf = ifelse(Place %in% c("DNF", "DNS") , 1, 0),
        Place = as.numeric(Place),
        Place = ifelse(did_dnf, max(Place, na.rm = TRUE) + 1, Place)
      ) %>%
      group_by(Gender) %>%
      mutate(
        gender_position = dense_rank(Place)
      ) %>%
      ungroup() %>%
      select(
        race_name,
        name,
        gender = Gender,
        gender_position
      )
  } else if (race_name == "Comrades (South Africa)") {
    file_res <- tmp_dat %>%
      mutate(
        name = tolower(Name),
        race_name = race_name,
        Gender = str_sub(Gender, 1, 1)
      ) %>%
      group_by(Gender) %>%
      mutate(
        gender_position = dense_rank(Place)
      ) %>%
      ungroup() %>%
      select(
        race_name,
        name,
        gender = Gender,
        gender_position
      )
  } else if (race_name %in% c("Barkley", "Lululemon Further", "Snowdrop Ultra")) {
    file_res <- tmp_dat %>%
      mutate(
        name = tolower(Runner),
        race_name = race_name,
        did_dnf = ifelse(Place %in% c("DNF", "DNS") , 1, 0),
        Place = as.numeric(Place),
        Place = ifelse(did_dnf, max(Place, na.rm = TRUE) + 1, Place)
      ) %>%
      group_by(Gender) %>%
      mutate(
        gender_position = dense_rank(Place)
      ) %>%
      ungroup() %>%
      select(
        race_name,
        name,
        gender = Gender,
        gender_position
      )
  } else if (race_name %in% c("IAU World Championships (Men)", "IAU World Championships (Women)")) {
    file_res <- tmp_dat %>%
      mutate(
        name = tolower(Name),
        race_name = race_name,
        Gender = str_sub(Gender, 1, 1)
      ) %>%
      group_by(Gender) %>%
      mutate(
        gender_position = dense_rank(`Pos`)
      ) %>%
      ungroup() %>%
      select(
        race_name,
        name,
        gender = Gender,
        gender_position
      )
  } else {
   failed <- append(failed, race_name)
  }
  res <- rbind(res, file_res)
}


## Join with Race Information ----

results_dat <- res %>%
  left_join(
    race_info %>%
      select(race, race_date = date, race_lat = latitude, race_lon = longitude),
    by = c("race_name" = "race")
  )

## Save the Data ----

write_csv(results_dat, "data/all-results-w-dnfs.csv")


## Some checking ----
results_dat %>%
  filter(name == "jim walmsley")
results_dat %>%
  filter(name == "hayden hawks")





##########################
## Same thing but excluding DNF and DNS
##########################



# The goal is to get a file with the following columns:
# race name, race date, participant name, gender place
res <- data.frame()
failed <- c()
for (file in race_files) {
  tmp_dat <- read_csv(file)
  race_name <- path_file(file) %>%
    stringr::str_remove("\\.csv$")
  race_type <- race_mapping %>%
    filter(race == race_name) %>%
    pull(type)
  if (race_type == "ultrasignup") {
    file_res <- tmp_dat %>%
      filter(Position != 0) %>%
      mutate(
        name = str_c(tolower(`First Name`), tolower(`Last Name`), sep = " "),
        race_name = race_name,
        Position = as.numeric(Position)
      ) %>%
      group_by(Gender) %>%
      mutate(
        gender_position = dense_rank(Position)
      ) %>%
      ungroup() %>%
      select(
        race_name,
        name,
        gender = Gender,
        gender_position
      )
  } else if (race_type == "itra") {
    file_res <- tmp_dat %>%
      filter(!(Place %in% c("DNF", "DNS"))) %>%
      tidyr::separate(Runner, into = c("LastName", "FirstName"), sep = " ", extra = "merge") %>%
      mutate(
        name = paste(tolower(FirstName), tolower(LastName)),
        race_name = race_name,
        Place = as.numeric(Place)
      ) %>%
      group_by(Gender) %>%
      mutate(
        gender_position = dense_rank(Place)
      ) %>%
      ungroup() %>%
      select(
        race_name,
        name,
        gender = Gender,
        gender_position
      )
  } else if (race_type %in% c("runsignup", "ultrarunning")) {
    file_res <- tmp_dat %>%
      filter(!(Place %in% c("DNF", "DNS"))) %>%
      mutate(
        name = tolower(Name),
        race_name = race_name,
        Place = as.numeric(Place)
      ) %>%
      group_by(Gender) %>%
      mutate(
        gender_position = dense_rank(Place)
      ) %>%
      ungroup() %>%
      select(
        race_name,
        name,
        gender = Gender,
        gender_position
      )
  } else if (race_type == "pacific") {
    file_res <- tmp_dat %>%
      tidyr::separate(Name, into = c("LastName", "FirstName"), sep = ", ", extra = "merge") %>%
      mutate(
        name = paste(tolower(FirstName), tolower(LastName)),
        race_name = race_name,
        Gender = str_sub(AG, 1, 1),
        Place = as.numeric(Place)
      ) %>%
      group_by(Gender) %>%
      mutate(
        gender_position = dense_rank(Place)
      ) %>%
      ungroup() %>%
      select(
        race_name,
        name,
        gender = Gender,
        gender_position
      )
  } else if (race_name == "Comrades (South Africa)") {
    file_res <- tmp_dat %>%
      mutate(
        name = tolower(Name),
        race_name = race_name,
        Gender = str_sub(Gender, 1, 1),
        Place = as.numeric(Place)
      ) %>%
      group_by(Gender) %>%
      mutate(
        gender_position = dense_rank(Place)
      ) %>%
      ungroup() %>%
      select(
        race_name,
        name,
        gender = Gender,
        gender_position
      )
  } else if (race_name %in% c("Barkley", "Lululemon Further", "Snowdrop Ultra")) {
    file_res <- tmp_dat %>%
      filter(!(Place %in% c("DNF", "DNS"))) %>%
      mutate(
        name = tolower(Runner),
        race_name = race_name,
        Place = as.numeric(Place)
      ) %>%
      group_by(Gender) %>%
      mutate(
        gender_position = dense_rank(Place)
      ) %>%
      ungroup() %>%
      select(
        race_name,
        name,
        gender = Gender,
        gender_position
      )
  } else if (race_name %in% c("IAU World Championships (Men)", "IAU World Championships (Women)")) {
    file_res <- tmp_dat %>%
      mutate(
        name = tolower(Name),
        race_name = race_name,
        Gender = str_sub(Gender, 1, 1)
      ) %>%
      group_by(Gender) %>%
      mutate(
        gender_position = dense_rank(`Pos`)
      ) %>%
      ungroup() %>%
      select(
        race_name,
        name,
        gender = Gender,
        gender_position
      )
  } else {
    failed <- append(failed, race_name)
  }
  res <- rbind(res, file_res)
}


## Join with Race Information ----

results_dat <- res %>%
  left_join(
    race_info %>%
      select(race, race_date = date, race_lat = latitude, race_lon = longitude),
    by = c("race_name" = "race")
  )

## Save the Data ----

write_csv(results_dat, "data/all-results-no-dnfs.csv")


## Some checking ----
results_dat %>%
  filter(name == "jim walmsley")

results_dat %>%
  filter(name == "hayden hawks")

results_dat %>%
  filter(name == "megan eckert")

results_dat %>%
  filter(name == "caleb olson")

