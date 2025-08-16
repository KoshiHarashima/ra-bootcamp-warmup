df <- tibble(
  col1 = sample(c(NA, 1), size = 100, replace = TRUE)
) |>
  mutate(
    is_na = is.na(col1)        # TRUE/FALSE のダミー
    # is_na = as.integer(is.na(col1))  # 0/1 が欲しければこちら
  )
