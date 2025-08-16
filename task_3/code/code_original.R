# 可読性：誰が読んでも理解しやすい構造
# 保守性：後任者が簡単に修正や追加ができる設計
# パフォーマンス：処理の無駄を減らし、効率的な実装
# 再利用性：他の用途でも使えるような関数設計


# Read Data
df_pop_raw <- read_csv(here("assignment23_data", "raw", "population_raw.csv")) |>
  separate(
    municipality_name,
    into = c("prefecture_name_copy", "municipality_name"),
    sep = "-") |>
  select(-prefecture_name_copy) |>
  mutate(year = str_remove(year, "year_")) |>
  mutate(year = as.numeric(year)) |>
  mutate(municipality_id = stringr::str_sub(municipality_id, start = 1, end = -2)) |>
  mutate(across(c(municipality_name), ~na_if(., "-"))) |>
  mutate(across(c(municipality_name), ~na_if(., "\u001f"))) |>
  tidyr::drop_na(municipality_name) |>
  mutate(across(-any_of(c("prefecture_name", "municipality_name")), as.numeric))


# Merge Data
adjust_df <- readxl::read_xlsx(
  here::here(
    "assignment23_data", "raw",
    "municipality_converter_jp.xlsx"))

df_municipality_id_2020 <- adjust_df |>
  distinct(id_muni2020) |>
  rename(
    municipality_id = id_muni2020
    )

list_2020_id <- df_municipality_id_2020 |>
  pull(municipality_id)

df_name_id <- df_pop_raw |>
  select(
    municipality_id,
    municipality_name,
    prefecture_name,
    year
    ) |>
  dplyr::filter(year == 2020) |>
  dplyr::filter(municipality_id %in% list_2020_id) |>
  distinct() |>
  select(-year)

adjust_municipality_id <- function(id_n, df_pop_raw, adjust_df){
  print(id_n)
  list_id <- adjust_df |>
    dplyr::filter(id_muni2020 == id_n) |>
    select(seq(2,10)) |>
    tidyr::pivot_longer(
      cols = everything(),
      names_to = "year",
      values_to = "id"
      ) |>
    distinct(id) |>
    drop_na() |>
    pull()
  
df_id_n <- df_pop_raw |>
  dplyr::filter(municipality_id %in% list_id) |>
  mutate(
    municipality_id = as.character(municipality_id)
    )

city_data <- df_pop_raw |>
  dplyr::filter(year == 2020,
                municipality_id == id_n) |>
  select(municipality_id, municipality_name, prefecture_name)

municipality_id_n <- city_data |>
  pull(municipality_id)

municipality_name_n <- city_data |>
  pull(municipality_name)

prefecture_name_n <- city_data |>
  pull(prefecture_name)

list_vars <- c(
"male",
"female",
"total",
"household",
"moving_in",
"birth",
"increase_total",
"moving_out",
"mortality",
"decrease_total",
"change",
"natural",
"social"
)

output_data <- df_id_n |>
  reframe(
    across(any_of(list_vars), ~sum(., na.rm = TRUE)),
    .by = year
    ) |>
  mutate(
    municipality_id = municipality_id_n
    )

return(output_data)
}

df_pop <- purrr::map(list_2020_id, adjust_municipality_id, df_pop_raw, adjust_df) |>
  bind_rows()

df_population_adjusted <- df_pop |>
  left_join(df_name_id, by = "municipality_id") |>
  select(
    municipality_id, municipality_name, prefecture_name, year, everything()
    )

# write_csv(df_population_adjusted, here("assignment23_data", "raw", "output", "population_adjust