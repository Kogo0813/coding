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
test_data <- as.data.frame(mat_charger)
testdat <- as.data.frame(test_data)

## krige
coordinates(testdat) <- ~ lon + lat
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
  addCircles(lng = ~lon, lat = ~lat, color = ~pal(pred.resid))



##  잔차적용
testdat2$pred.val = (testdat2$y_predict + testdat2$pred.resid)

pal <- colorFactor("viridis", testdat2$pred.val) 

leaflet(testdat2) %>% 
  setView(lng = 127.2296, lat = 37.2271, zoom = 11) %>% # korea, zoom 6 
  addProviderTiles('CartoDB.Positron') %>% 
  addCircles(lng = ~lon, lat = ~lat, color = ~pal(pred.val))



mykey = "AIzaSyBkSxXE-FGR1NPpZ_Ok1dQvjKAfXfPl-qw"
mkey = "AIzaSyCw5UoHnbPvP-HC_isxPtj7Zek3DNv87Ws"
register_google(key = mykey)
register_google(key = mkey)
mymap <- get_googlemap('용인', maptype = 'roadmap', zoom = 11)
ggmap(mymap)+geom_point(aes(x = long, y = lat,colour = pred.val), 
                        data = testdat2, alpha = .5, size=2) + coord_equal() + 
  scale_colour_gradient(low = "red",high="blue") + coord_equal() + theme_bw() + 
  ggtitle("Predicted residuals by using Kriging") + theme(plot.title = element_text(hjust = 0.5))
testdat2



sum(testdat2$pred.val<0)
################################################################################
mean(traindat$cnt)
# 너무 -로 된 잔차가 많아서 현재 용인시의 전기차 충전소의 합을 노드의 수만큼
# 부여하고 진행

charge <- charge[37.0876 < charge$lat ,]
charge <- charge[charge$lat < 37.370174, ]
charge <- charge[127.03221 < charge$lng, ]
charge <- charge[charge$lng < 127.42372, ]
plus <- sum(charge$cnt) / nrow(charge)
#################################################################################
2614-1902

testdat2.to

View(charge)
View(node)
write.csv(testdat2, 'predict_charger.csv')

######################################################
## 예측한 Y에 대한 중심성의 회귀분석
df = read.csv('predict_charger.csv')
df <- df[, c(-1)]
View(df)



df <- df[37.0876 < df$lat ,]
df <- df[df$lat < 37.370174, ]
df <- df[127.03221 < df$long, ]
df <- df[df$long < 127.42372, ]


## 회귀분석
model = lm(pred.val ~ betweenness_centrality, data = df)
summary(model)


## 행렬 모델 예측 결과 불러오기
mat_charger <- read.csv('matrix_charger.csv')
View(mat_charger)


## 이걸 kriging해서 잔차반영
mat_charger$resid <- mat_charger$y - mat_charger$y_predict

## variogram작성
mat_df <- as.data.frame(mat_charger)
coordinates(mat_charger) <- ~ lon + lat
dvgm_mat <- variogram(resid ~ 1, data = mat_charger)


## auto
library(automap)
dvgm_auto_mat <- autofitVariogram(resid ~ 1, mat_charger)
plot(dvgm_auto_mat)


## variogram 그림
plot(dvgm)
dfit <- fit.variogram(dvgm, model = vgm('Sph'))
warnings()
plot(dvgm, model = dfit)

trainj = SpatialPointsDataFrame(jitter(coordinates(mat_df),factor=0.2), train_df@data)

testj = SpatialPointsDataFrame(jitter(coordinates(testdat),factor=0.2), testdat@data)

dkrige <- krige(resid ~ 1, trainj, testj, model = dfit, nmax = 3)
dkrige_df <- as.data.frame(dkrige)

write.csv(testdat2, 'pred_matrix.csv')

sum(testdat2$pred.val > 0)























pred.resid <- dkrige_df$var1.pred
