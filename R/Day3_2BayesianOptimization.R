#Example from https://rpubs.com/Argaadya/bayesian-optimization
library(tidyverse)

#True function to maximize
f <- function(x) {
  f <- (2 * x - 50)^2 * sin(32 * x-3.8)
  return(f)
}

#Design Points
x <- c(0, 1/3, 1/2, 2/3, 1)

eval <- data.frame(x = x, y = f(x)) %>% as.matrix()
eval

#Fit GP to the existing data points
fit <- GP_fit(X = eval[ , "x"], 
              Y = eval[ , "y"], 
              corr = list(type = "exponential", power = 1.95))

#GP Prediction
x_new <- seq(0, 1, length.out = 100)
pred <- predict.GP(fit, xnew = data.frame(x = x_new))
mu <- pred$Y_hat
sigma <- sqrt(pred$MSE)

ggplot(as.data.frame(eval))+
  geom_line(data = data.frame(x = x_new, y = mu),
            aes(x = x, y = y), color = "red", linetype = "dashed")+
  geom_ribbon(data = data.frame(x = x_new, y_up = mu + sigma, y_low = mu - sigma), 
              aes(x = x_new, ymax = y_up, ymin = y_low), fill = "skyblue", alpha = 0.5) +
  geom_point(aes(x,y), size = 2)+
  theme_minimal() +
  labs(title = "Gaussian Process Posterior of f(x)",
       subtitle = "Blue area indicate the credible intervals",
       y = "f(x)")



y_best <- max(eval[,2])

eps <- 500
ei_calc <- function(m, s) {
  if (s == 0) {
    return(0)
  }
  Z <- (m - y_best + eps)/s
  expected_imp <- (m - y_best + eps) * pnorm(Z) + s * dnorm(Z)
  return(expected_imp)
}

expected_improvement <- numeric()
for (i in 1:length(mu)) {
  expected_improvement[i] <- ei_calc(m = mu[i],s =  sigma[i])
}

exp_imp <- data.frame(x = x_new,
                      y = expected_improvement)

exp_best <- exp_imp %>% filter(y == max(y))


ggplot(exp_imp, aes(x, y))+
  geom_line()+
  geom_ribbon(aes(ymin = 0, ymax = y), fill = "skyblue", alpha = 0.5, color = "white")+ 
  geom_vline(xintercept = exp_best$x, linetype = "dashed", color = "red")+
  geom_point(data = exp_best, size = 2)+
  theme_minimal() +
  theme(panel.grid = element_blank())+
  scale_x_continuous(breaks = c(seq(0,1,0.25), round(exp_best$x,2)))+
  labs(title = "Expected Improvement",
       subtitle = "x with the highest expected improvement will be evaluated",
       y = "Expected Improvement")

