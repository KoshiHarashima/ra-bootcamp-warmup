set.seed(111)
df <- tibble(
  y = seq(101, 200),
  x_1 = seq(1, 100) + rnorm(n = 100, 0, 1),
  x_2 = sample(c(0,1), 100, replace = TRUE),
  x_3 = seq(50, 149) + rnorm(n = 100, 0, 1)
)
linear_models <- function() {
  model_1 <- lm_robust(y ~ x_1)
  model_2 <- lm_robust(y ~ x_1 + x_2)
  model_3 <- lm_robust(y ~ x_2)
  model_4 <- lm_robust(y ~ x_1 + x_2 + x_3)
  list_output <- list(
    model_1 = model_1,
    model_2 = model_2,
    model_3 = model_3,
    model_4 = model_4
  )
  return(list_output)
}