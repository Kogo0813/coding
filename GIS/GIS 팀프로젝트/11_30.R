library(dplyr)
library(car)
library(mlbench)

df <- read.csv('충남_integrated.csv', fileEncoding = 'cp949');df
df <- df[,c('X', 'Y', 'index')]
names(df) <- c('lon', 'lat', 'index')


df
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



leaflet(df) %>%
    addTiles() %>%
    setView(lng = 127.3674, lat = 34.61081, zoom = 11) %>%
    addProviderTiles('CartoDB.Positron') %>% 
    addCircles(lng = ~lon, lat = ~lat)

attach(df)




# kriging
traindat <- as.data.frame(df)
coordinates(traindat) <- ~ lon + lat

lm_train <- lm(index ~ 1, data = traindat)
summary(lm_train)


traindat$resid <- lm_train$residual

testdat <- read.csv('DSC_final.csv');testdat
testdat <- testdat[,c('X_X', 'X_Y')]
names(testdat) <- c('lon', 'lat')
coordinates(testdat) <- ~ lon + lat


## variogram작성
train_df <- as.data.frame(traindat)
coordinates(train_df) <- ~ lon + lat
dvgm <- variogram(resid ~ 1, data = train_df)


## auto
library(automap)
dvgm_auto <- autofitVariogram(resid ~ 1, train_df)

plot(dvgm_auto)


## variogram 그림
plot(dvgm)
dfit <- fit.variogram(dvgm, model = vgm('Exp', range = 8.3, kappa = 10))
warnings()
plot(dvgm, model = dfit)


# test_data 처리 
test_data <- as.data.frame(testdat)



## krige
coordinates(testdat) <- ~ lon + lat
trainj = SpatialPointsDataFrame(jitter(coordinates(train_df),factor=0.2), train_df@data)
testj = SpatialPointsDataFrame(jitter(coordinates(testdat),factor=0.2), testdat@data)

dkrige <- autoKrige(resid ~ 1, train_df, testdat)
plot(dkrige)
dkrige_junra <- as.data.frame(dkrige$krige_output)


dkrige_junra %>% head


## kriging 결과 plus
pred.y <- dkrige_junra$var1.pred + lm_train$coefficients
testdat2 <- cbind(test_data, pred.y)
testdat2


mykey = "AIzaSyBkSxXE-FGR1NPpZ_Ok1dQvjKAfXfPl-qw"
mkey = "AIzaSyCw5UoHnbPvP-HC_isxPtj7Zek3DNv87Ws"
register_google(key = mykey)
register_google(key = mkey)
mymap <- get_googlemap('충청남도', maptype = 'roadmap', zoom = 9)
ggmap(mymap)+geom_point(aes(x = lon, y = lat,colour = pred.y), 
                        data = testdat2, alpha = .8, size=8) + coord_equal() + 
  scale_colour_gradient(low = "red",high="blue") + coord_equal() + theme_bw() + 
  ggtitle("Predicted residuals by using Kriging") + theme(plot.title = element_text(hjust = 0.5))



pal <- colorFactor("viridis", testdat2$pred.y) 
leaflet(testdat2) %>% 
  setView(lng = 126.7672, lat = 34.6420, zoom = 10) %>% # korea, zoom 6 
  addProviderTiles('CartoDB.Positron') %>% 
  addCircles(lng = ~lon, lat = ~lat, color = ~pal(pred.y), s = 20)


testdat2 %>% sort(decreasing = TRUE)
write.csv(testdat2, 'pred_test.csv')


read.csv('pred_test.csv')

)
ggmap(mymap)+geom_point(aes(x = X, y = Y,colour = index), 
                        data = df, alpha = .8, size=8) + coord_equal() + 
  scale_colour_gradient(low = "red",high="blue") + coord_equal() + theme_bw() + 
  ggtitle("Predicted residuals by using Kriging") + theme(plot.title = element_text(hjust = 0.5))
df$index
