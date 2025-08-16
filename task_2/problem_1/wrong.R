df <- tibble(
  col1 = sample(c(NA, 1), size = 100, replace = TRUE)
) |>
  mutate(
    is_na = if_else(col1 == NA, TRUE, FALSE)
  )