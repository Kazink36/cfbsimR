## code to prepare `divisions` dataset goes here
library(tidyverse)
teams <- cfbfastR::cfbd_team_info()

divisions <- teams %>%
  left_join(cfbfastR::cfbd_conf_types_df,
            by = c("conference" = "name"),suffix = c("","_conf")) %>%
  transmute(
    team = school,
    conf = abbreviation_conf,
    division = ifelse(
      is.na(division),
      conf,
      division
    ),
    sdiv = ifelse(
      is.na(division),
      abbreviation_conf,
      paste0(abbreviation_conf,str_extract(division,"."))
    )
  ) %>%
  mutate(division = case_when(conf == "PAC" ~ "PAC",TRUE ~ division),
         sdiv = case_when(conf == "PAC" ~ "PAC1",TRUE ~ sdiv)) %>%
  as_tibble() #%>%
  #add_row(team = "FCS",conf = "FCS",division = "FCS",sdiv = "FCS")

usethis::use_data(divisions, overwrite = TRUE)
