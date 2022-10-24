rm(list = ls())
getwd()
setwd('../01_data/')
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
library(leaflet)
library(mapview)

set.seed(0)
## EC 데이터 가져오기
ec <- read.csv('EC.csv')
ec <- ec[,c(4 ,5, 6, 7)]
names(ec) <- c('bc', 'lon', 'lat', 'class')
ec_1 <- ec[ec$class == 1,]
ec_1$bc <- log10(ec_1$bc)



ec$bc <- log10(ec$bc)


# class 1 : 수지구, class 2 : 기흥구, class 3 : 처인구




## log취하기
#charger <- read.csv('charger.csv')
#charger <- charger[,c(3,4,5)]
#charger$cnt <- log10(charger$cnt)
#charger$cnt %>% hist
# charger

# 수지구의 전기차 충전소 데이터
charger <- read.csv('charger.csv')
charger <- charger[,c(2,3,4,5)]
charger$count <- log10(charger$count)
charger_수지 <- charger[charger$gu == 1,]
charger





## 우선 그림부터 보자
pal <- colorFactor("viridis", charger_수지$count) 
map1 = leaflet(charger_수지) %>% 
  setView(lng = 127.2226, lat = 37.293272, zoom = 11) %>% # korea, zoom 6 
  addProviderTiles('CartoDB.Positron') %>% 
  addCircles(lng = ~lon, lat = ~lat, color = ~pal(charger_수지$count))
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

lm_charger <- lm(count ~ 1, data = charger)
summary(lm_charger)
lm_charger$coefficients

## traindat에 잔차 추가
traindat$resid <- lm_charger$residual



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
dfit <- fit.variogram(dvgm, model = vgm('Mat'))
warnings()
plot(dvgm, model = dfit)


# test_data 처리 
test_data <- as.data.frame(ec_1)
testdat <- as.data.frame(test_data)



## krige
coordinates(testdat) <- ~ lon + lat
trainj = SpatialPointsDataFrame(jitter(coordinates(train_df),factor=0.2), train_df@data)
testj = SpatialPointsDataFrame(jitter(coordinates(testdat),factor=0.2), testdat@data)

dkrige <- krige(resid ~ 1, trainj, testj, model = dfit)
dkrige_suji <- as.data.frame(dkrige)


## kriging 결과 plus
pred.y <- dkrige_suji$var1.pred + lm_charger$coefficients
testdat2 <- cbind(test_data, pred.y)
testdat2


pal <- colorFactor("viridis", testdat2$pred.y) 

leaflet(testdat2) %>% 
  setView(lng = 127.2296, lat = 37.2271, zoom = 11) %>% # korea, zoom 6 
  addProviderTiles('CartoDB.Positron') %>% 
  addCircles(lng = ~lon, lat = ~lat, color = ~pal(pred.y))




mykey = "AIzaSyBkSxXE-FGR1NPpZ_Ok1dQvjKAfXfPl-qw"
mkey = "AIzaSyCw5UoHnbPvP-HC_isxPtj7Zek3DNv87Ws"
register_google(key = mykey)
register_google(key = mkey)
mymap <- get_googlemap('용인', maptype = 'roadmap', zoom = 11)
ggmap(mymap)+geom_point(aes(x = lon, y = lat,colour = pred.y), 
                        data = testdat2, alpha = .5, size=1) + coord_equal() + 
  scale_colour_gradient(low = "red",high="blue") + coord_equal() + theme_bw() + 
  ggtitle("Predicted residuals by using Kriging") + theme(plot.title = element_text(hjust = 0.5))

nrow(testdat2)
testdat2 <- testdat2[!is.infinite(testdat2$bc),]
## inf 값을 어떻게 변환해야 할까


hist(testdat2$pred.y)

## 회귀분석
lm_suji <- lm(pred.y ~ bc, data = testdat2)
summary(lm_suji)

head(testdat2)

testdat2$bc %>% hist
plot(testdat2$bc, testdat2$pred.y)
abline(model)
testdat2$pred.y %>% hist



## 예측한 수지구의 y를 학습셋으로 두고 다른 구의 노드들을 테스트 셋에 두고 예측
head(testdat2)
traindat2 <- testdat2


train <- as.data.frame(traindat2)
coordinates(traindat2) <- ~ lon + lat


## 회귀분석

lm_all <- lm(pred.y ~ 1, data = traindat2)
summary(lm_all)


## traindat에 잔차 추가
train$resid_2 <- lm_all$residual


## variogram작성
train_df_2 <- as.data.frame(train)
coordinates(train) <- ~ lon + lat
dvgm <- variogram(resid_2 ~ 1, data = train)



## auto
library(automap)
dvgm_auto <- autofitVariogram(resid_2 ~ 1, train)
plot(dvgm_auto)


## variogram 그림
plot(dvgm)
dfit <- fit.variogram(dvgm, model = vgm('Gau'))
warnings()
plot(dvgm, model = dfit)



# test_data 처리 
test_data_2 <- as.data.frame(ec)
testdat_2 <- as.data.frame(test_data_2)



## krige
coordinates(testdat_2) <- ~ lon + lat
trainj = SpatialPointsDataFrame(jitter(coordinates(train),factor=0.2), train@data)
testj = SpatialPointsDataFrame(jitter(coordinates(testdat_2),factor=0.2), testdat_2@data)

dkrige <- krige(resid_2 ~ 1, trainj, testj, model = dfit, nmax = 3)
dkrige_all <- as.data.frame(dkrige)

## kriging 결과 plus
predict_y <- dkrige_all$var1.pred + lm_all$coefficients
testdat3 <- cbind(test_data_2, predict_y)

predict_y %>% hist
library(leaflet)
pal <- colorFactor("viridis", testdat2$predict_y) 

leaflet(testdat3) %>% 
  setView(lng = 127.2296, lat = 37.2271, zoom = 11) %>% # korea, zoom 6 
  addProviderTiles('CartoDB.Positron') %>% 
  addCircles(lng = ~lon, lat = ~lat, color = ~pal(predict_y))



## 회귀분석
testdat3 <- testdat3[!is.infinite(testdat3$bc),]



testdat3$predict_y <-  10 ^ (testdat3$predict_y)
head(testdat3)


testdat3$bc %>% hist
plot(testdat3$bc, testdat3$predict_y)
abline(model)

testdat3$predict_y %>% hist
head(testdat3)


## 중심성으로 추정한 다른 지역들의 노드들의 충전소 대수 예측

# testdat3 <- kriging으로 보간한 용인시 노드들에 대응되는 전기차 충전소의 대수
head(testdat3)
testdat3$predict_bc <- 10^ (lm_suji$coefficients[2] * testdat3$bc + lm_suji$coefficients[1])


testdat3$predict_bc %>% hist
plot(testdat3$predict_bc, testdat3$predict_y)
testdat2$bc
## 크리깅 - 회귀분석 잔차
(testdat3$predict_y - testdat3$predict_bc) %>% plot

testdat2$pred.y <- 10 ^ testdat2$pred.y
testdat2$pred.y %>% ceil %>% sum
testdat3$predict_bc %>% round %>% sum
testdat3$predict_y %>% floor %>% sum
lm_suji$coefficients[1]
## 6555대 -> 중심성으로 예측한 용인시에 필요한 충전소의 대수
## 5870대 -> kriging으로 예측한 용인시에 필요한 충전소의 대수
## 수지구에 있는 실제 충전소의 대수 : 1558대, 예측한 충전소의 대수 : 1481대


ggsave("크리깅 - 회귀분석 잔차.png", dpi=1000, dev='png', height=4.5, width=8.5, units="in")
leaflet(testdat3) %>% 
  setView(lng = 127.2296, lat = 37.2271, zoom = 11) %>% # korea, zoom 6 
  addProviderTiles('CartoDB.Positron') %>% 
  addCircles(lng = ~lon, lat = ~lat, color = ~pal(predict_bc))
