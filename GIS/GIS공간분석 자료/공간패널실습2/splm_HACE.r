rm(list=ls(all=TRUE))

library(pscl)

library(MASS)
library(splm)
library(plm)

source("F:/GIS 공간자료분석/공간패널실습2/impacts.splm.r")
source("F:/GIS 공간자료분석/공간패널실습2/spfeml.r")
source("F:/GIS 공간자료분석/공간패널실습2/splaglm.r")
source("F:/GIS 공간자료분석/공간패널실습2/sperrorlm.r")


######################### 종속변수  

####### 소비자 물가지수 

data0 <- read.table("F:/GIS 공간자료분석/공간패널실습2/dataset/Pindex.txt",sep="",header=F)
year0 <- c(1985:2013)

######## 소비자물가지수  

st3 <- 1  

row.ids <- seq(st3,dim(data0)[1],7)
col.ids <- c(1:(dim(data0)[2]-1))

tmp.set <- data0[row.ids,col.ids]
new.set0 <- matrix(0,dim(tmp.set)[1],dim(tmp.set)[2])

for(i in 1:dim(tmp.set)[1]){
for(j in 1:dim(tmp.set)[2]){
new.set0[i,j] <- as.numeric(tmp.set[i,j])
}
}

###### 가계최종소비지출 (민간최종소비지출 st <- 3) 
#### 전국, 서울, 부산, 대구, 인천, 광주, 대전, 울산, 경기, 강원, 충북, 충남, 전북, 전남, 경북, 경남, 제주  

data1 <- read.csv("F:/GIS 공간자료분석/공간패널실습2/dataset/GRDP.csv",sep=",",header=F)
year1 <- c(1995:2013)


###### 가계최종소비지출 

st1 <- 4

col.ids <- seq(2,dim(data1)[2],2)
row.ids <- seq(st1,dim(data1)[1],9)
tmp.set <- data1[row.ids,col.ids]

new.set1 <- matrix(0,dim(tmp.set)[1],dim(tmp.set)[2])

for(i in 1:dim(tmp.set)[1]){
for(j in 1:dim(tmp.set)[2]){
new.set1[i,j] <- as.numeric(tmp.set[i,j])
}
}

########## 단위 10억 
new.set1 <- new.set1/1000

ids <- c((length(new.set1[1,])-9):length(new.set1[1,]))
new.set1 <- new.set1[c(2:17),ids]



####### 1인당 개인소득 (1인당 민간소비 st2 <- 4) 
#### 전국, 서울, 부산, 대구, 인천, 광주, 대전, 울산, 경기, 강원, 충북, 충남, 전북, 전남, 경북, 경남, 제주  

data2 <- read.csv("F:/GIS 공간자료분석/공간패널실습2/dataset/GRDP2.csv",sep=",",header=F)
data2[data2=='-'] <- NA

###### 1인당 지역내총생산 

year2 <- c(2000:2013)
 
st2 <- 1

row.ids <- seq(st2,dim(data2)[1],4)
col.ids <- c(16:dim(data2)[2])
tmp.set <- data2[row.ids,col.ids]

new.set2 <- matrix(0,dim(tmp.set)[1],dim(tmp.set)[2])
for(i in 1:dim(tmp.set)[1]){
for(j in 1:dim(tmp.set)[2]){
new.set2[i,j] <- as.numeric(tmp.set[i,j])/new.set0[i,j+15]
}
}

ids <- c((length(new.set2[1,])-9):length(new.set2[1,]))
new.set2 <- new.set2[c(2:17),ids]


##################################### 설명변수 

data3 <- read.csv("F:/GIS 공간자료분석/공간패널실습2/dataset/피용자보수.csv",sep=",",header=F)
data3[data3=='-'] <- NA

###### 1인당 피용자보수(임금소득) 

year3 <- c(2000:2013)

new.set3 <- matrix(0,dim(data3)[1],dim(data3)[2])

for(i in 1:dim(new.set3)[1]){
for(j in 1:dim(new.set3)[2]){
new.set3[i,j] <- as.numeric(data3[i,j])/new.set0[i,j+15]
}
}

ids <- c((length(new.set3[1,])-9):length(new.set3[1,]))
new.set3 <- new.set3[c(2:17),ids]



######################### 주택매매가격지수 
#### 전국, 서울, 부산, 대구, 인천, 광주, 대전, 울산, 경기, 강원, 충북, 충남, 전북, 전남, 경북, 경남, 제주  

data4 <- read.csv("F:/GIS 공간자료분석/공간패널실습2/dataset/주택매매가격지수.csv",sep=",",header=F)
data4[data4=='-'] <- NA
year4 <- c(2004:2013)

new.set4 <- matrix(0,17,10)
for(i in 1:17){
for(j in 1:10){
new.set4[i,j] <- mean(as.numeric(data4[i,c(((j-1)*12+1):(j*12))]))
}
}

ids <- c((length(new.set4[1,])-9):length(new.set4[1,]))
new.set4 <- new.set4[c(2:17),ids]


######################### 주택전세가격지수 
#### 전국, 서울, 부산, 대구, 인천, 광주, 대전, 울산, 경기, 강원, 충북, 충남, 전북, 전남, 경북, 경남, 제주  

data5 <- read.csv("F:/GIS 공간자료분석/공간패널실습2/dataset/주택전세가격지수.csv",sep=",",header=F)
data5[data5=='-'] <- NA
year5 <- c(2004:2013)

new.set5 <- matrix(0,17,10)
for(i in 1:17){
for(j in 1:10){
new.set5[i,j] <- mean(as.numeric(data5[i,c(((j-1)*12+1):(j*12))]))
}
}

ids <- c((length(new.set5[1,])-9):length(new.set5[1,]))
new.set5 <- new.set5[c(2:17),ids]



######################### 실질금리 
#### 전국, 서울, 부산, 대구, 인천, 광주, 대전, 울산, 경기, 강원, 충북, 충남, 전북, 전남, 경북, 경남, 제주  

########### 기준금리  
 
new.set61 <- c(4.75,5.25,4.00,4.25,3.75,3.25,3.75,4.50,5.00,3.00,2.00,2.50,3.25,2.75,2.50)
year6 <- c(1999:2013)

new.set6 <- matrix(0,17,length(year6))

for(i in 1:dim(new.set6)[1]){
for(j in 1:dim(new.set6)[2]){
new.set6[i,j] <- new.set61[j]/new.set0[i,j+14]
}
} 

ids <- c((length(new.set6[1,])-9):length(new.set6[1,]))
new.set6 <- new.set6[c(2:17),ids]



##################################################################################
#################### 고용률
#### 전국, 서울, 부산, 대구, 인천, 광주, 대전, 울산, 경기, 강원, 충북, 충남, 전북, 전남, 경북, 경남, 제주  

 
data7 <- read.csv("F:/GIS 공간자료분석/공간패널실습2/dataset/HIRE.csv",sep=",",header=F)
year7 <- c(2003:2014)

tmp.set <- data7

new.set7 <- matrix(0,dim(tmp.set)[1],dim(tmp.set)[2])

for(i in 1:dim(tmp.set)[1]){
for(j in 1:dim(tmp.set)[2]){
new.set7[i,j] <- as.numeric(tmp.set[i,j])
}
}

ids <- c((length(new.set7[1,])-9):length(new.set7[1,]))
new.set7 <- new.set7[c(2:17),ids]




#######################################################
############## Weights matrix

########### KTX Neighbor

W <- diag(1,16)

#W <- matrix(0,16,16)

#### 서울, 부산, 대구, 인천, 광주, 대전, 울산, 경기, 강원, 충북, 충남, 전북, 전남, 경북, 경남, 제주  

W[1,2] <- W[2,1] <- W[1,3] <- W[3,1] <- W[1,6] <- W[6,1] <- 1
W[2,3] <- W[3,2] <- W[2,6] <- W[6,2] <- W[3,6] <- W[6,3] <- 1
 

for(i in 1:16){
W[i,] <- W[i,]/sum(W[i,])
}

#apply(W,2,sum)




########################################
######################### Analysis 1

timing <- proc.time()[3]



years <- rep(c(2004:2013),16)
regions <- as.factor(rep(c("서울","부산","대구","인천","광주","대전","울산"," 경기"," 강원", "충북", "충남", "전북", "전남", "경북", "경남"," 제주"),each=c(2013-2004+1)))


dat1 <- as.data.frame(matrix(0,length(years),9))
dat1[,1] <- years
dat1[,2] <- regions
dat1[,3] <- as.vector(t(new.set1))
dat1[,4] <- as.vector(t(new.set2))
dat1[,5] <- as.vector(t(new.set3))
dat1[,6] <- as.vector(t(new.set4))
dat1[,7] <- as.vector(t(new.set5))
dat1[,8] <- as.vector(t(new.set6))
dat1[,9] <- as.vector(t(new.set7))

n.dat <- dat1

#############################################################

years <- n.dat$V1
regions <- n.dat$V2
Y <- n.dat$V3
X1 <- n.dat$V5
X2 <- n.dat$V6
X3 <- n.dat$V7
X4 <- n.dat$V8
X5 <- n.dat$V9

WX1 <- as.vector(X1 %*% kronecker(W,diag(10)))
WX2 <- as.vector(X2 %*% kronecker(W,diag(10)))
WX3 <- as.vector(X3 %*% kronecker(W,diag(10)))
WX4 <- as.vector(X4 %*% kronecker(W,diag(10)))
WX5 <- as.vector(X5 %*% kronecker(W,diag(10)))


new.data <- data.frame(regions,years,Y,X1,X2,X3,X4,X5,WX1,WX2,WX3,WX4,WX5)


fm <- Y ~ X1 + X5

#### original model
model.0 <- spml(fm, data=new.data, listw=mat2listw(W), model="random", lag=FALSE, spatial.error="none")
summary(model.0)

summary(model.0)$rsqr
summary(model.0)$logLik

#### SDM model
model.1 <- spml(fm, data=new.data, listw=mat2listw(W), model="random", lag=TRUE, spatial.error="b")
summary(model.1)

summary(model.1)$rsqr
summary(model.1)$logLik


#### SEM model 
model.2 <- spml(fm, data=new.data, listw=mat2listw(W), model="random", lag=FALSE, spatial.error="b")
summary(model.2)

summary(model.2)$rsqr
summary(model.2)$logLik


#### SAR model 
model.3 <- spml(fm, data=new.data, listw=mat2listw(W), model="random", lag=TRUE, spatial.error="none")
summary(model.3)

summary(model.3)$rsqr
summary(model.3)$logLik


##### More model

fm <- Y ~ X1 + X2 + X3 + X4 + X5 + WX1 + WX2 + WX3 + WX4 + WX5
fm <- Y ~ X1 + X2 + X5 + WX1 + WX2 + WX5
fm <- Y ~ X1 + X2 + WX1 + WX2
fm <- Y ~ X1 + X5 + WX1 + WX5


#### Panel analysis

ols <- lm(fm, data=new.data)

fixed <- plm(fm, data=new.data, index=c("regions", "years"), model="within")

pFtest(fixed, ols)

### reject H0 means fixed is better than ols

random <- plm(fm, data=new.data, index=c("regions", "years"), model="random")

phtest(fixed, random)

### reject H0 means fixed is better than random


######### final model

summary(random)

summary(fixed)



#### Spatial Panel analysis


#### original model
model.0 <- spml(fm, data=new.data, listw=mat2listw(W), model="random", lag=FALSE, spatial.error="none")
summary(model.0)

summary(model.0)$rsqr
summary(model.0)$logLik

#### SDM model
model.1 <- spml(fm, data=new.data, listw=mat2listw(W), model="random", lag=TRUE, spatial.error="b")
summary(model.1)

summary(model.1)$rsqr
summary(model.1)$logLik

#### SEM model 
model.2 <- spml(fm, data=new.data, listw=mat2listw(W), model="random", lag=FALSE, spatial.error="b")
summary(model.2)

summary(model.2)$rsqr
summary(model.2)$logLik


#### SAR model 
model.3 <- spml(fm, data=new.data, listw=mat2listw(W), model="random", lag=TRUE, spatial.error="none")
summary(model.3)

summary(model.3)$rsqr
summary(model.3)$logLik






###################### Testing

#### test for SEM  (LM spatial error)
test.1 <- sphtest(fm,data=new.data, listw=mat2listw(W),spatial.model="error",method="GM")

#### test for SDM  (LM spatial lag)
test.2 <- sphtest(fm,data=new.data, listw=mat2listw(W),spatial.model="sarar",method="GM")

#### test for SAR  (LM spatial error)
test.3 <- sphtest(fm,data=new.data, listw=mat2listw(W),spatial.model="lag",method="GM")



