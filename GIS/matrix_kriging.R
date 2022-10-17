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
  library(rgdal)
})

install.packages('rgdal')
setwd('C:\\Users\\user\\bigcon2x\\bigcon22\\EC\\01_data/')

## 전기차 충전소 데이터 가져오기
charger <- read.csv('charger.csv')

charger <- charger[,c(2,3,4)]
charge <- read.csv('charger.csv')
## node 데이터 가져오기
node <- read.csv('central.csv')
node <- node[,c(2,3,5,6)]


## 전체 노드에서 centrality를 통해서 전기차 충전소 수 예측
## 전기차 충전소 데이터에 각 경위도에 세워져있는 전기차 충전소의 개수가 있음
library(leaflet)
install.packages('leaflet')
## 우선 그림부터 보자
map1 = leaflet(charger) %>% 
  setView(lng = 127.2226, lat = 37.293272, zoom = 11) %>% # korea, zoom 6 
  addProviderTiles('CartoDB.Positron') %>% 
  addCircles(lng = ~lng, lat = ~lat, color = '#208b00')
map1  

## 용인시 이외의 점들이 포함되어 있음
## 제거

charger <- charger[37.0876 < charger$lat ,]
charger <- charger[charger$lat < 37.370174, ]
charger <- charger[127.03221 < charger$lng, ]

charger <- charger[charger$lng < 127.42372, ]


traindat <- as.data.frame(charger)
coordinates(charger) <- ~ lng + lat

## 회귀분석

fit <- lm(cnt ~ 1, data = charger)
summary(fit)


## traindat에 잔차 추가
traindat$resid <- fit$residual



## variogram작성
train_df <- as.data.frame(traindat)
coordinates(train_df) <- ~ lng + lat
dvgm <- variogram(resid ~ 1, data = train_df)


## auto
library(automap)

dvgm_auto <- autofitVariogram(resid ~ 1, train_df)
plot(dvgm_auto)


## variogram 그림
plot(dvgm)
dfit <- fit.variogram(dvgm, model = vgm('Sph', nugget = 0, sill = 86, range = 0, kappa = 0.6))
warnings()
plot(dvgm, model = dfit)


# test_data 처리 (아마도 node데이터)
mat_charger <- read.csv('matrix_charger.csv')
mat_charger <- mat_charger[,-1]
test_data <- as.data.frame((mat_charger))
testdat <- as.data.frame(test_data)

## krige
coordinates(testdat) <- ~ long + lat
trainj = SpatialPointsDataFrame(jitter(coordinates(train_df),factor=0.2), train_df@data)
testj = SpatialPointsDataFrame(jitter(coordinates(testdat),factor=0.2), testdat@data)

dkrige <- krige(resid ~ 1, trainj, testj, model = dfit, nmax = 3)
dkrige_df <- as.data.frame(dkrige)

pred.resid <- dkrige_df$var1.pred
testdat2 <- cbind(test_data, pred.resid)
testdat2

## 잔차그림
pal <- colorFactor("viridis", testdat2$pred.resid) 

leaflet(testdat2) %>% 
  setView(lng = 127.2296, lat = 37.2271, zoom = 11) %>% # korea, zoom 6 
  addProviderTiles('CartoDB.Positron') %>% 
  addCircles(lng = ~long, lat = ~lat, color = ~pal(pred.resid))