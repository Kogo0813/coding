rm(list=ls())
library(GPfit)
## 2D Example: GoldPrice Function
computer_simulator <- function(x) {
  x1 = 4 * x[, 1] - 2
  x2 = 4 * x[, 2] - 2
  t1 = 1 + (x1 + x2 + 1)^2 * (19 - 14 * x1 + 3 * x1^2 - 14 * x2 +
                                6 * x1 *x2 + 3 * x2^2)
  t2 = 30 + (2 * x1 - 3 * x2)^2 * (18 - 32 * x1 + 12 * x1^2 + 48 * x2 -
                                     36 * x1 * x2 + 27 * x2^2)
  y = t1 * t2
  return(y)
}
n = 100
d = 2

set.seed(1)
library(lhs)
x = maximinLHS(n, d) #Sampling from LHS
y = computer_simulator(x) #Compute model output for x
GPmodel = GP_fit(x, y,  corr = list(type = "matern", nu
                                    = 3/2)) #Fitting GP
print(GPmodel) #Show model fitting results

x_new=expand.grid(seq(0,1,0.01),seq(0,1,0.01)) #Grid for prediction
par(mfrow=c(1,1))
plot(x_new)
Y_predict=predict(GPmodel,x_new) #Prediction surface
Y_true=computer_simulator(x_new) #True surface

###Plotting the results###########
library(fields)
par(mfrow=c(1,3))
quilt.plot(x_new,Y_true,main='True Surface') 
quilt.plot(x,y,main='Sampled Locations')
quilt.plot(x_new,Y_predict$complete_data[,3],main='Prediction')


