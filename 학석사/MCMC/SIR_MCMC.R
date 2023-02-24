rm(list=ls())
library(deSolve)
library(invgamma)

T=300

# SIR model
SIR <- function(t, s, theta) {
  
  with(as.list(c(s, theta)), {
    dS <- birth - beta*I*S - vaccination*S - death*S
    dI <- beta*I*S - recovery*I - death*I
    dR <- recovery*I + vaccination*S - death*R
    return(list(c(dS,dI,dR)))
  })
}

### initial state
##  Susceptible 1, Infected 1, Recovered 0
init       <- c(S = 1, I = 0.001, R = 0)
## beta: infection parameter; gamma: recovery parameter
theta <- c(beta = 0.62, recovery = 0.018, death = 0.002, birth = 0.002, vaccination = 0.08)
## time steps
times <- seq(0,T-1,by = 1)

## Solve using ode function
out <- ode(y = init, times=times, func=SIR, parms=theta)

##Creating observational data
set.seed(2022)
Z <- out[,3] + rnorm(T,0,0.002)

## Plotting underlying true process
library(tidyverse)
out <- as.tibble(out)
out %>% ggplot() + geom_line(aes(y=S,x=time,color="S"),size=2) +
  geom_line(aes(y=I,x=time,color="I"),color='blue',size=2) + 
  geom_line(aes(y=R,x=time,color="R"),color='red',size=2) +
  scale_color_manual(name='',values = c("S"="black","I"="blue","R"="red"))

##Forward model function
model <- function(param)
{
  theta <- c(beta = param[1], recovery = param[2], death = param[3], birth = param[4], vaccination = param[5])
  out <- ode(y = init, times=times, func=SIR, parms=theta)
  return(out)
}

##Log posterior density
posterior <- function(all_param)
{
  n <- length(Z)
  sigma2 <- all_param[6]
  Y_theta <- model(all_param[1:5]) 
  
  within_01 <- prod(Y_theta[,2]>=0)*prod(Y_theta[,3]>=0)*prod(Y_theta[,4]>=0)*
    prod(Y_theta[,2]<=1)*prod(Y_theta[,3]<=1)*prod(Y_theta[,4]<=1)
  
  if(prod(all_param>0)==1&prod(all_param<1)==1&within_01==1)
  {
    log_p <- -0.5*sum((Z-Y_theta[,3])^2)/sigma2 -
      0.5*n*log(sigma2) + 
      dinvgamma(sigma2,0.1,0.1,log=TRUE)
  } else
  {
    log_p <- -Inf
  }
  
  return(log_p)
}

#Running MCMC
# init.time=proc.time()
# library(mcmc)
# mcmc.sample=metrop(posterior,c(0.59,0.013,0.0025,0.003,0.05,0.0006),scale=c(0.01,0.001,0.0001,0.001,0.01,0.00001),nbatch=300000)$batch
# proc.time()-init.time
#  
# ##Checking the generated chain
# plot(mcmc.sample[,3]) 
#  
# mcmc.sample <- as.tibble(mcmc.sample)
# colnames(mcmc.sample) <- c('beta','recovery','death','birth','vaccination','sigma2')
#  
# saveRDS(mcmc.sample,file='mcmc_sample.rds')
mcmc.sample <- readRDS('mcmc_sample.rds')
plot(mcmc.sample[[1]]) 

# Density plot
mcmc.sample[5000:300000,] %>% ggplot(aes(x=beta))+
  geom_density(color="darkblue", fill="lightblue")

# Hexbin chart 
mcmc.sample[5000:300000,] %>% ggplot(aes(x=beta, y=vaccination) ) +
  geom_hex(bins = 15) +
  scale_fill_continuous(type = "viridis") +
  theme_bw()

##Run the model for an example chain member
i=300000
theta <- c(mcmc.sample[i,1], mcmc.sample[i,2], mcmc.sample[i,3], mcmc.sample[i,4], mcmc.sample[i,5])
out <- ode(y = init, times=times, func=SIR, parms=theta)

plot(mcmc.sample[1:50000,c(1,4)],type='l')

library(tidyverse)
out <- as.tibble(out)
out %>% ggplot() + geom_line(aes(y=S,x=time,color="S"),size=2) +
  geom_line(aes(y=I,x=time,color="I"),color='blue',size=2) + 
  geom_line(aes(y=R,x=time,color="R"),color='red',size=2) +
  scale_color_manual(name='',values = c("S"="black","I"="blue","R"="red"))

##Calibrated runs based on MCMC sample
# out.mat <- array(NA,dim=c(T,4,300000))
# for(i in 1:300000)
# {
#   theta <- c(mcmc.sample[i,1], mcmc.sample[i,2], mcmc.sample[i,3], mcmc.sample[i,4], mcmc.sample[i,5])
#   out.mat[,,i] <- ode(y = init, times=times, func=SIR, parms=theta)
# }

# saveRDS(out.mat,file='out_mat.rds')
out.mat <- readRDS('out_mat.rds')

##Plotting S 
time.mat.S <- out.mat[,1,1]
mean.mat.S <- apply(out.mat[,2,],1,mean)
lower.mat.S <- apply(out.mat[,2,],1,quantile,probs=0.025)
upper.mat.S <- apply(out.mat[,2,],1,quantile,probs=0.975)
mat.S <- tibble(time=time.mat.S,mean=mean.mat.S,lower=lower.mat.S,upper=upper.mat.S)

mat.S %>% ggplot() + geom_line(aes(y=mean,x=time),color='blue',size=2) +
  geom_line(aes(y=lower,x=time),color='blue',alpha=0.5,size=2) + 
  geom_line(aes(y=upper,x=time),color='blue',alpha=0.5,size=2) 

##Plotting I
time.mat.I <- out.mat[,1,1]
mean.mat.I <- apply(out.mat[,3,],1,mean)
lower.mat.I <- apply(out.mat[,3,],1,quantile,probs=0.025)
upper.mat.I <- apply(out.mat[,3,],1,quantile,probs=0.975)
mat.I <- tibble(time=time.mat.I,mean=mean.mat.I,lower=lower.mat.I,upper=upper.mat.I,Z=Z)

mat.I %>% ggplot() + geom_line(aes(y=mean,x=time),color='blue',size=2) +
  geom_line(aes(y=lower,x=time),color='blue',alpha=0.5,size=2) + 
  geom_line(aes(y=upper,x=time),color='blue',alpha=0.5,size=2) +
  geom_line(aes(y=Z,x=time),color='black',size=2) 

 