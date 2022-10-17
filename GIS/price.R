########## 패키지 설치
rm(list = ls())

suppressPackageStartupMessages({
  library(MASS)
  library(plyr)
  library(pscl)
  library(splines2) 
  library(ggmap)
  library(sp)
  library(gstat)
  library(gridExtra)
  library(akima)
  library(maps)
  library(car)
  library(dplyr) # for "glimpse"
  library(ggplot2)
  library(scales) # for "comma"
  library(magrittr)
  library(lmtest)
  library(UsingR)
  library(RgoogleMaps)
  
})
library(rgdal)
#####################
## 작업 디렉토리 설정
setwd('../01_data/')
train= read.csv('end.csv')

train = as.data.frame(train)
train <- train[,c(4,6,7)]
names(train)[c(1,2,3)] <- c('y', 'lat', 'lon')
train$y = log(train$y, base = 10)




#####################
## 구글 키 등록
mykey = "AIzaSyBkSxXE-FGR1NPpZ_Ok1dQvjKAfXfPl-qw"
mkey = "AIzaSyCw5UoHnbPvP-HC_isxPtj7Zek3DNv87Ws"
register_google(key = mykey)
register_google(key = mkey)


## 구글맵 불러오기
install.packages('ggmap')
library(ggmap)
mymap <- get_googlemap('용인', maptype = 'roadmap', zoom = 11)

####################
## 지도 그리기
traindat <- as.data.frame(train)

coordinates(train) <- ~ lon + lat
ggmap(mymap)+ geom_point(aes(x = lon, y = lat,colour = y), 
                        data = traindat, alpha = .5, size=5) + coord_equal() + 
  scale_colour_gradient(low = "red",high="blue") + coord_equal() + theme_bw() + 
  ggtitle("Original centrality") + theme(plot.title = element_text(hjust = 0.5))


###################
## 회귀분석

fit <- lm(y ~ 1, data = traindat)
summary(fit)

## 평균 : 5.37853
## traindat에 잔차 추가
traindat$resid <- fit$residuals

## variogram작성
train_df <- as.data.frame(traindat)
coordinates(train_df) <- ~ lon + lat
dvgm <- variogram(resid ~ 1, data = train_df)

#######
## variogram 그림
plot(dvgm)
dfit <- fit.variogram(dvgm, model = vgm('Exp'))
plot(dvgm, model = dfit)


######### test_data 생성
matrix <- read.csv('gaussian_predict.csv')
# matrix <- read.csv('scenario.csv')
head(matrix)
test_data <- matrix




testdat <- as.data.frame(test_data)
###########
## krige
coordinates(testdat) <- ~ lon + lat
trainj = SpatialPointsDataFrame(jitter(coordinates(train_df),factor=0.2), train_df@data)
testj = SpatialPointsDataFrame(jitter(coordinates(testdat),factor=0.2), testdat@data)

dkrige <- krige(resid ~ 1, trainj, testj, model = dfit)

dkrige_df <- as.data.frame(dkrige)


pred.y <- dkrige_df$var1.pred + 5.37853
pred.y
testj

testdat2 <- cbind(test_data, pred.y)

#######################
ggmap(mymap)+geom_point(aes(x = lon, y = lat,colour = pred.y), 
                              data = testdat2, alpha = .5, size=2) + coord_equal() + 
  scale_colour_gradient(low = "red",high="blue") + coord_equal() + theme_bw() + 
  ggtitle("Predicted residuals by using Kriging") + theme(plot.title = element_text(hjust = 0.5))


View(testdat2)
write.csv(testdat2, '공시지가 예측.csv')

#write.csv(testdat2, 'krige_simul.csv')
#











