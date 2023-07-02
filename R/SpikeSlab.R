
rm(list=ls())

N <- 1000 # sample
P <- 10 # count of variables

## predictors
X <- matrix(NA,nrow=N,ncol=P) # 무작위로 만듬
covmat <- diag(P)
library(mvtnorm)
for(i in 1:N){
  X[i,]=rmvnorm(1,mean=rep(0,P),sigma=covmat)
}
dim(X)

## true betas
betas.true=c(0.5, -0.5, 1, -1, 0.7, 0, 0, 0, 0, 0)

## simulating "y"
set.seed(1)
Y <- rbinom(N, size=1, as.numeric(exp(X%*%betas.true)/(1+exp(X%*%betas.true))) )
hist(Y)

###### 0. glm run
res <- glm(Y~-1 + X, family="poisson")
summary(res)



###### 1. Nimble package implementation 
library(nimble)
library(coda)
model_glm <- nimbleCode({
  
  # Data Model
  for(i in 1:n){
    probability[i] <- exp(XB[i])/(1+exp(XB[i]))
    Y[i] ~ dbinom(prob = probability[i] , size = 1)
  }
  XB[1:n] <- X[1:n,1:p]%*%beta[1:p]
  
  # Spike and slab prior 
  for(i in 1:p){
    # lambda[i] = 1 indicates nonzero beta otherwise zero beta
    lambda[i] ~ dbinom(prob = 1/2 , size = 1)
    beta[i] ~ dnorm(0, var = tau[lambda[i]+1])
  }
  tau[1] ~ dgamma(1, 20)  # spike part variance for zero beta
  tau[2] ~ dinvgamma(1, 20)  # slab part varaince for nonzero beta
})


niter <- 1e4
consts <- list(n=N, p=P, X=X)
dat <- list(Y=Y)
inits <- list(beta=rep(0,P),lambda=rep(1,P),tau=c(rgamma(1,1,20),rinvgamma(1,1,20)))


# Run MCMC
pt<-proc.time()
samples_glm  <- nimbleMCMC(model_glm, data = dat, inits = inits,
                           constants=consts,
                           monitors = c("beta","lambda","tau"),
                           samplesAsCodaMCMC=TRUE,WAIC=FALSE,summary=FALSE,
                           niter = niter, nburnin = 0, thin=1, nchains = 1)   
ptFinal_glm<-proc.time()-pt
ptFinal_glm

dim(samples_glm)
head(samples_glm)


par(mfrow=c(3,4))
for(i in 1:P){ ts.plot(samples_glm[2000:niter,i]) }
ts.plot(samples_glm[2000:niter,21])
ts.plot(samples_glm[2000:niter,22])
par(mfrow=c(1,1))
par(mfrow=c(3,4))
for(i in 1:P){ hist(samples_glm[2000:niter,i]) }
hist(samples_glm[2000:niter,21])
hist(samples_glm[2000:niter,22])


for(i in 1:P){ 
  print( effectiveSize(as.mcmc(samples_glm[2000:niter,i])) )
  print( HPDinterval(as.mcmc(samples_glm[2000:niter,i])) )
}

apply(samples_glm[2000:niter,],2,mean)[1:P]
apply(samples_glm[2000:niter,],2,mean)[(P+1):(2*P)]
be
