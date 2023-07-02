library(logisticPCA)
library(RobustGaSP)
rm(list=ls())
load('binary_example.Rdata')

#Leave the test data out
true_Y <- mat.Y[393,]
mat.Y <- mat.Y[-393,]
theta_new <- param[393,]
mat_param <- param[-393,]

#Run logisticPCA if 'PCA_results.Rdata' does not exist 
if(!file.exists('PCA_results.Rdata')){
  PCA_results <- logisticPCA(mat.Y,k=10)
  save(file='PCA_results.Rdata',PCA_results)
} else
{
  load('PCA_results.Rdata',PCA_results)
}

m1<- rgasp(design = mat_param, response = PCA_results$PCs[,1])
m2<- rgasp(design = mat_param, response = PCA_results$PCs[,2])
m3<- rgasp(design = mat_param, response = PCA_results$PCs[,3])
m4<- rgasp(design = mat_param, response = PCA_results$PCs[,4])
m5<- rgasp(design = mat_param, response = PCA_results$PCs[,5])
m6<- rgasp(design = mat_param, response = PCA_results$PCs[,6])
m7<- rgasp(design = mat_param, response = PCA_results$PCs[,7])
m8<- rgasp(design = mat_param, response = PCA_results$PCs[,8])
m9<- rgasp(design = mat_param, response = PCA_results$PCs[,9])
m10<- rgasp(design = mat_param, response = PCA_results$PCs[,10])

#Prediction for PC scores
testing_input <- matrix(theta_new,1,length(theta_new))
colnames(testing_input) <- paste('V',1:10,sep="")
  
pred1 <- predict(m1,theta_new)
pred2 <- predict(m2,theta_new)
pred3 <- predict(m3,theta_new)
pred4 <- predict(m4,theta_new)
pred5 <- predict(m5,theta_new)
pred6 <- predict(m6,theta_new)
pred7 <- predict(m7,theta_new)
pred8 <- predict(m8,theta_new)
pred9 <- predict(m9,theta_new)
pred10 <- predict(m10,theta_new)

Hc <- PCA_results$U

predicted_logit <- PCA_results$mu+Hc%*%c(pred1$mean,pred2$mean,pred3$mean,pred4$mean,pred5$mean,pred6$mean,pred7$mean,pred8$mean,pred9$mean,pred10$mean)

par(mfrow=c(1,2))
image(matrix(predicted_logit>0,86,37))
image(matrix(true_Y,86,37))
