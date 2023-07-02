rm(list=ls())
library(deSolve)
library(RobustGaSP)
T=50
n=200

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
## beta: infection parameter; gamma: recovery parameter
theta <- c(beta = 0.92, gamma = 0.42)
## time steps
times <- seq(0,T-1,by = 1)



##Creating design points for input parameters
library(lhs)
param_original <- maximinLHS(n,2)
param_mat <- cbind(param_original[,1]*1+0.2,
                   param_original[,2]*1+0.2)

colnames(param_mat) <- c('beta','gamma')

##Creating perturbed physics ensemble
mat_Y <- matrix(NA,n,T)
for(i in 1:n)
{
  mat_Y[i,] <- ode(y = init, times=times, func=SIR, parms=param_mat[i,])[,3]
}

mat_Y <- mat_Y[,2:T]

#Fitting Partial Parallel GP emulator
library(RobustGaSP)
data(humanity_model)
m.ppgasp=ppgasp(design=param_mat,response=mat_Y,nugget.est= TRUE)
show(m.ppgasp)

#Fitting PCA-based emulator
PCA_results <- princomp(mat_Y)
  
plot(mat_Y,matrix(PCA_results$center,n,T-1,byrow=TRUE)+PCA_results$scores%*%t(PCA_results$loadings))

m1<- rgasp(design = param_mat, response = PCA_results$scores[,1])
m2<- rgasp(design = param_mat, response = PCA_results$scores[,2])
m3<- rgasp(design = param_mat, response = PCA_results$scores[,3])
m4<- rgasp(design = param_mat, response = PCA_results$scores[,4])
m5<- rgasp(design = param_mat, response = PCA_results$scores[,5])
m6<- rgasp(design = param_mat, response = PCA_results$scores[,6])



#Prediction for beta=0.9 and gamma=0.4
theta_new = c(beta=0.9,gamma=0.4)

#True model output
true_Y <- ode(y = init, times=times, func=SIR, parms=theta_new)[2:T,3]

#Prediction for PPGP
testing_input <- matrix(theta_new,1,2)
m_pred.ppgasp <- predict(m.ppgasp,testing_input)

#Prediction for PCA-based
pred1 <- predict(m1,testing_input)
pred2 <- predict(m2,testing_input)
pred3 <- predict(m3,testing_input)
pred4 <- predict(m4,testing_input)
pred5 <- predict(m5,testing_input)
pred6 <- predict(m6,testing_input)

Hc <- PCA_results$loadings[,1:6]
prediction_PCA <- PCA_results$center+Hc%*%c(pred1$mean,pred2$mean,pred3$mean,pred4$mean,pred5$mean,pred6$mean)

#Plotting for comparison
plot(true_Y,lwd=4,ylab='# of Infected',col=1,type='l')
lines(prediction_PCA,lwd=4,col=4)
lines(c(m_pred.ppgasp$mean),lwd=4,col=2)




