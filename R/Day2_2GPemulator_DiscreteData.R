rm(list=ls())
library(deSolve)

T <- 50
N <- 1000

# SIR model
SIR <- function(t, s, theta) {
  
  with(as.list(c(s, theta)), {
    dS <- -beta*S*I
    dI <-  beta*S*I-gamma*I
    dR <-                 gamma*I
    return(list(c(dS,dI,dR)))
  })
}

### initial state
##  Susceptible 1, Infected 1, Recovered 0
init       <- c(S = 1, I = 0.001, R = 0)
## time steps
times <- seq(0,T-1,by = 1)

##Creating design points for input parameters
library(lhs)
param_original <- maximinLHS(200,2)
param_mat <- cbind(param_original[,1]*0.8+0.2,
                   param_original[,2]*0.8+0.2)

colnames(param_mat) <- c('beta','gamma')
##Creating perturbed physics ensemble
mat_Y <- matrix(NA,200,T)
for(i in 1:200)
{
  mat_Y[i,] <- N*ode(y = init, times=times, func=SIR, parms=param_mat[i,])[,3]
}


#Finding Generalized PCs 
library(PoissonPCA)

PCA_results <- Poisson_Corrected_PCA(mat_Y,k=3,transformation='log')

plot(mat_Y,exp(matrix(PCA_results$center,200,50,byrow=TRUE)+PCA_results$scores%*%t(PCA_results$loadings)))

#Emulating PC scores
library(GPfit)
m1 <- GP_fit(param_mat,PCA_results$scores[,1])
m2 <- GP_fit(param_mat,PCA_results$scores[,2])
m3 <- GP_fit(param_mat,PCA_results$scores[,3])

#Making predictions
theta_new <- c(beta = 0.6, gamma = 0.28)

Hc <- PCA_results$loadings

Y_true <- N*ode(y = init, times=times, func=SIR, parms=theta_new)[,3]

pred1 <- predict(m1,matrix(theta_new,1,2))
pred2 <- predict(m2,matrix(theta_new,1,2))
pred3 <- predict(m3,matrix(theta_new,1,2))

plot(exp(PCA_results$center+Hc%*%c(pred1$Y_hat,pred2$Y_hat,pred3$Y_hat)),ylim=c(0,230));lines(Y_true,col=2)


