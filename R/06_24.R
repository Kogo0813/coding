
library(nimble)
library(adaptMCMC)
library(coda)
library(mvtnorm)

head(admission)
Z <- admission$admit
Xmat <- cbind(1,scale(admission$gre),scale(admission$gpa))

###### 1. Nimble package implementation 

model_glm <- nimbleCode({
  
  # Data Model : 베르누이 분포의 우도를 계산
  for(i in 1:n){
    lambda[i] <- exp(XB[i])/(1+exp(XB[i])) # lambda[i] = u(X_i)
    Z[i] ~ dbinom(prob = lambda[i] , size = 1) # 베르누이 분포 모델링
  }
  XB[1:n] <- X[1:n,1:p]%*%beta[1:p]
  
  # Parameter Model
  beta[1:p] ~ dmnorm(mean=M[1:p], cov=Cov[1:p,1:p])
})


niter <- 1e4 # 10000개정도면 수렴할 것이라고 예상
consts <- list(n=dim(Xmat)[1], p=dim(Xmat)[2], X=Xmat, M=rep(0,dim(Xmat)[2]), Cov=diag(dim(Xmat)[2]))
dat <- list(Z=Z)
inits <- list(beta=rep(0,dim(Xmat)[2]))

# Run MCMC
pt<-proc.time()
samples_glm  <- nimbleMCMC(model_glm, data = dat, inits = inits,
                           constants=consts,
                           monitors = c("beta"),
                           samplesAsCodaMCMC=TRUE,WAIC=FALSE,summary=FALSE,
                           niter = niter, nburnin = 0, thin=1, nchains = 1) # thin : 매번째 샘플 모두 저장 (독립성을 띄는 것끼리 샘플이 되야함)
ptFinal_glm<-proc.time()-pt
ptFinal_glm

dim(samples_glm)

par(mfrow=c(2,3))
for(i in 1:dim(samples_glm)[2]){ ts.plot(samples_glm[,i]) }
for(i in 1:dim(samples_glm)[2]){ hist(samples_glm[,i]) }  

effectiveSize(as.mcmc(samples_glm))
HPDinterval(as.mcmc(samples_glm))

###### 2. adaptMCMC package implementation

init.pars = c(beta1=0, beta2=0, beta3=0)

logPost = function(pars) {
  with(as.list(pars), {
    beta = pars
    lambda <- exp(Xmat%*%beta)/(1+exp(Xmat%*%beta))
    # likelihood + prior 
    sum(dbinom(Z,prob = lambda , size = 1, log=TRUE)) + sum(dnorm(beta,mean=0,sd=1,log=TRUE))
  })
}

out.mcmc <- MCMC(p=logPost, n=1e4, init=init.pars, scale=c(0.1,0.1,0.1), adapt=TRUE, acc.rate=.3)

par(mfrow=c(2,3))
for(i in 1:dim(out.mcmc$samples)[2]){ ts.plot(out.mcmc$samples[,i]) }
for(i in 1:dim(out.mcmc$samples)[2]){ hist(out.mcmc$samples[,i]) }

effectiveSize(as.mcmc(out.mcmc$samples))
HPDinterval(as.mcmc(out.mcmc$samples))












