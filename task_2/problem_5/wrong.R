df <- tibble(
  a = seq(1, 10)
)
add_column <- function(df, is_name) {
  df <- df |>
    mutate(
      is_name = if_else(a > 5, TRUE, FALSE)
    )
  return(df)
}
add_column(df, "higher") |>
  dplyr::filter(higher == TRUE)