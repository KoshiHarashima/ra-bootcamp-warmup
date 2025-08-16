df <- tibble(
  a = seq(1, 10)
)

add_column <- function(df, is_name) {
  nm <- as.character(is_name)
  df[[nm]] <- df$a > 5   
  return(df)
}

add_column(df, "higher") |>
  dplyr::filter(higher == TRUE)
