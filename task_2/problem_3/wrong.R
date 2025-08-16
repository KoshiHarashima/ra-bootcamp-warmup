df_population <- readr::read_csv(here::here("assignment23_data", "raw","population_ps2.csv"))
df_lm <- df_population |>
  arrange(city_name, year) |>
  mutate(
    change_rate = (log(population) - dplyr::lag(log(population), n = 20)),
    .by = city_id
  ) |>
  dplyr::filter(year == 2015)
lm(log(change_rate) ~ log(population), data = df_lm)