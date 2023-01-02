install.packages("bbmle")
install.packages("statnet")
install.packages('pacman')
library(pacman)
p_load('bbmle', 'statnet', 'dplyr', 'tidyverse', 'ggplot2')



## MLE
fit = mle2


















## 3.5 Stochastic Simulation
sim.cb = function(S0, beta, I0){
  I = I0
  S = S0
  i = 1
  while (!any(I == 0)){
    i = i + 1
    I[i] = rbinom(1, size = S[i-1], 
                  prob = 1 - exp(-beta * I[i-1]/S0))
    S[i] = S[i-1] - I[i]
  }
  out = data.frame(S = S, I = I)
  return(out)
}

plot(y, type="n", xlim=c(1,18),
     ylab="Predicted/observed", xlab="Week")
for(i in 1:100){
  sim=sim.cb(S0=floor(coef(fit)["S0"]),
             beta=coef(fit)["beta"], I0=11)
  lines(sim$I, col=grey(.5))
}
points(y, type="b", col=2)