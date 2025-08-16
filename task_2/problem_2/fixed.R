df_population <- readr::read_csv(here::here("assignment23_data", "raw","population_ps2.csv"))
df_population %>% dplyr::select(tidyselect::contains("name"))
