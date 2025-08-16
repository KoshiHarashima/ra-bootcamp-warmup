df_population <- readr::read_csv(here::here("assignment23_data", "raw","population_ps2.csv"))

df_lm <- df_population |>
  arrange(city_id, year) |>
  group_by(city_id) |>
  mutate(
    pop_t0 = dplyr::lag(population, n = 20),                 # 初期人口（例：1995）
    log_growth = log(population) - log(pop_t0)               # = log(pop/pop_t0)
  ) |>
  ungroup() |>
  filter(year == 2015, is.finite(log_growth), is.finite(pop_t0), pop_t0 > 0)

# log-log 回帰：対数成長率 ~ 初期人口の対数
fit <- lm(log_growth ~ log(pop_t0), data = df_lm)
summary(fit)
