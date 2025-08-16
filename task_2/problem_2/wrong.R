df_population <- readr::read_csv(here::here("assignment23_data", "raw","population_ps2.csv"))
list_vars <- dplyr::select_vars(vars = names(df_population), contains("name"))
df_population %>%
  select(list_vars)