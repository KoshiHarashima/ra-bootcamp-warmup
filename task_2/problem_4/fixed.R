set.seed(111)
df <- tibble(
  col_1 = seq(1, 10),
  col_2 = seq(11, 20) + rnorm(n = 10, 0, 1),
  col_3 = seq(30, 21) + rnorm(n = 10, 0, 1),
)

plot <- function(data, x, y) {
  ggplot(data, aes(x = {{ x }}, y = {{ y }})) +
    geom_point() +
    theme_minimal()
}

plot_col_12 <- plot(df, col_1, col_2)
plot_col_13 <- plot(df, col_1, col_3)
plot_col_23 <- plot(df, col_2, col_3) 
