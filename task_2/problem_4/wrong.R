set.seed(111)
df <- tibble(
  col_1 = seq(1, 10),
  col_2 = seq(11, 20) + rnorm(n = 10, 0, 1),
  col_3 = seq(30, 21) + rnorm(n = 10, 0, 1),
)
plot_col_12 <- ggplot(df, aes(x = col_1, y = col_2)) +
  geom_point() +
  theme_minimal()
plot_col_13 <- ggplot(df, aes(x = col_1, y = col_3)) +
  geom_point() +
  theme_minimal()
plot_col_23 <- ggplot(df, aes(x = col_2, y = col_3)) +
  geom_point() +
  theme_minimal()
plot_col_12
