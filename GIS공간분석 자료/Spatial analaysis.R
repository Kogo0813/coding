rm(list=ls())

suppressPackageStartupMessages({
  library(tidyverse)
  library(data.table)
  library(magrittr)
  library(ggmap)
  library(sf)
  library(raster)
  library(sp)
  library(gstat)
})

data1 = read.csv("./spatial.csv",header=T)
summary(data1)

set.seed(1)
ind = sample(x=2,nrow(data1),replace=T,prob=c(0.03,0.97))
traindata = data1[ind==1,]
testdata = data1[ind==2,]
nrow(traindata)

traindata = transform(traindata, y_log = log(y + 1))

fit = lm(y_log ~ X1+X2+X3+factor(X4), data = traindata)
summary(fit)

traindata$resid = residuals(fit)

data1$ind = ind
data1$ind = as.factor(data1$ind)

mean(traindata$LON)
mean(traindata$LAT)

library(leaflet)

map1 = leaflet(traindata) %>% 
  setView(lng = 128.1462, lat = 35.19471, zoom = 11) %>% # korea, zoom 6 
  addProviderTiles('CartoDB.Positron') %>% 
  addCircles(lng = ~LON, lat = ~LAT, color = 'darkred')

map1

map2 = leaflet(testdata) %>% 
  setView(lng = 128.1462, lat = 35.19471, zoom = 11) %>% # korea, zoom 6 
  addProviderTiles('CartoDB.Positron') %>% 
  addCircles(lng = ~LON, lat = ~LAT, color = 'darkblue')

map2

pal <- colorFactor("RdYlBu", data1$ind) #viridis #Greens #Blues

leaflet(data1) %>% 
  setView(lng = 128.1462, lat = 35.19471, zoom = 11) %>% # korea, zoom 6 
  addProviderTiles('CartoDB.Positron') %>% 
  addCircles(lng = ~LON, lat = ~LAT, color = ~pal(ind)) %>% 
  addMiniMap(tiles = "CartoDB.DarkMatter") 

library(mapview)
library(leafsync)

coordinates(traindata)= ~LON + LAT
coordinates(testdata)= ~LON + LAT
coordinates(data1)= ~LON + LAT

proj4string(traindata) <- CRS("+init=epsg:4326") #5179 #5181
proj4string(testdata) <- CRS("+init=epsg:4326")
proj4string(data1) <- CRS("+init=epsg:4326")

m1 <- mapview(traindata, burst = TRUE)
m2 <- mapview(testdata)
m3 <- mapview(data1, zcol = "ind", burst = TRUE)

sync(m1, m2)
m3

class(traindata)

dvgm <- variogram(resid~1, data=traindata)  
plot(dvgm)

library(automap)

dvgm_auto = autofitVariogram(resid ~ 1, traindata);dvgm_auto
plot(dvgm_auto)

dfit <- fit.variogram(dvgm, model=vgm(0.5, "Mat", 1, 1.5)) # vgm(psill,model,range,nugget)
dfit

plot(dvgm, dfit)


#kriging
df_kriged <- krige(resid ~ 1, traindata, testdata, model = dfit) 

df_kriged %<>% as.data.frame() %>% setDT
testdata %<>% as.data.frame() %>% setDT

testdata[,`:=`('pred_resi' = df_kriged$var1.pred)]
testdata[,`:=`('pred_ref' = predict(fit, newdata = testdata))]
testdata[,`:=`('pred' = pred_resi+pred_ref)]

library(RColorBrewer)

coordinates(testdata)= ~LON + LAT
proj4string(testdata) <- CRS("+init=epsg:4326")

mapview(testdata, zcol = "pred_resi", col.regions = brewer.pal(10, "RdYlGn"), color = "darkred", lwd = 1, layer.name = "Prediction value of residual", legend = TRUE) +
  mapview(testdata, zcol = "pred_ref", col.regions = brewer.pal(10, "RdYlGn"), color = "gold", lwd = 1, layer.name = "Prediction value of regression", legend = TRUE) +
  mapview(testdata, zcol = "pred_resi", col.regions = brewer.pal(10, "RdYlGn"), color = "black", lwd = 1, layer.name = "Prediction", legend = TRUE)


