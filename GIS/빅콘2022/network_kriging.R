rm(list = ls())
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
## 전기차 충전소 데이터 가져오기
charger <- read.csv('charger.csv')

charger <- charger[,c(2,3,4)]

## node 데이터 가져오기
node <- read.csv('central.csv')
node <- node[,c(2,3,5,6)]

## log취하기
charger$cnt <- log10(charger$cnt)
node$betweenness_centrality <- log10(node$betweenness_centrality)
## 전체 노드에서 centrality를 통해서 전기차 충전소 수 예측
## 전기차 충전소 데이터에 각 경위도에 세워져있는 전기차 충전소의 개수가 있음

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
dfit <- fit.variogram(dvgm, model = vgm('Mat'))
warnings()
plot(dvgm, model = dfit)


# test_data 처리 (아마도 node데이터)
test_data <- as.data.frame(node)
testdat <- as.data.frame(test_data)

## krige
coordinates(testdat) <- ~ long + lat
trainj = SpatialPointsDataFrame(jitter(coordinates(train_df),factor=0.2), train_df@data)
testj = SpatialPointsDataFrame(jitter(coordinates(testdat),factor=0.2), testdat@data)

dkrige <- krige(resid ~ 1, trainj, testj, model = dfit, nmax = 3)
dkrige_df <- as.data.frame(dkrige)


## kriging 결과 plus
pred.y <- dkrige_df$var1.pred
testdat2 <- cbind(test_data, pred.y)
testdat2

## 잔차그림
pal <- colorFactor("viridis", testdat2$pred.y) 

leaflet(testdat2) %>% 
  setView(lng = 127.2296, lat = 37.2271, zoom = 11) %>% # korea, zoom 6 
  addProviderTiles('CartoDB.Positron') %>% 
  addCircles(lng = ~long, lat = ~lat, color = ~pal(pred.y))



mykey = "AIzaSyBkSxXE-FGR1NPpZ_Ok1dQvjKAfXfPl-qw"
mkey = "AIzaSyCw5UoHnbPvP-HC_isxPtj7Zek3DNv87Ws"
register_google(key = mykey)
register_google(key = mkey)
mymap <- get_googlemap('용인', maptype = 'roadmap', zoom = 11)
ggmap(mymap)+geom_point(aes(x = long, y = lat,colour = pred.y), 
                        data = testdat2, alpha = .5, size=1) + coord_equal() + 
  scale_colour_gradient(low = "red",high="blue") + coord_equal() + theme_bw() + 
  ggtitle("Predicted residuals by using Kriging") + theme(plot.title = element_text(hjust = 0.5))
head(testdat2,10)


## inf 값을 어떻게 변환해야 할까?
testdat2$betweenness_centrality[is.infinite(testdat2$betweenness_centrality)] <- -6
testdat2$pred.y <- 10 * (testdat2$pred.y)
## 회귀분석
model <- lm(pred.y ~ betweenness_centrality + closeness_centrality, data = testdat2)
summary(model)


testdat2$closeness_centrality %>% hist
plot(testdat2$closeness_centrality, testdat2$pred.y)














## 15보다 큰 것 24개 제외한 후의 그림
nrow(down15)
nrow(testdat2)
down15 <- testdat2 %>% filter(pred.resid < 15)
pal <- colorFactor("viridis", down15$pred.resid) 

leaflet(down15) %>% 
  setView(lng = 127.2296, lat = 37.2271, zoom = 11) %>% # korea, zoom 6 
  addProviderTiles('CartoDB.Positron') %>% 
  addCircles(lng = ~long, lat = ~lat, color = ~pal(pred.resid))



mykey = "AIzaSyBkSxXE-FGR1NPpZ_Ok1dQvjKAfXfPl-qw"
mkey = "AIzaSyCw5UoHnbPvP-HC_isxPtj7Zek3DNv87Ws"
register_google(key = mykey)
register_google(key = mkey)
mymap <- get_googlemap('용인', maptype = 'roadmap', zoom = 10)
ggmap(mymap)+geom_point(aes(x = long, y = lat,colour = pred.resid), 
                        data = down15, alpha = .8, size=1) + coord_equal() + 
  scale_colour_gradient(low = "red",high="blue") + coord_equal() + theme_bw() + 
  ggtitle("Predicted residuals by using Kriging") + theme(plot.title = element_text(hjust = 0.5))
testdat2

down15



write.csv(testdat2, 'testdat2.csv')


sugi = read.csv('수지_기흥구.csv')
View(sugi)

model <- lm(pred.resid ~ betweenness_centrality, data = sugi)
summary(model)




