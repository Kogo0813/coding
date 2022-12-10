library(dplyr)
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


mykey = "AIzaSyBkSxXE-FGR1NPpZ_Ok1dQvjKAfXfPl-qw"
mkey = "AIzaSyCw5UoHnbPvP-HC_isxPtj7Zek3DNv87Ws"
register_google(key = mykey)
register_google(key = mkey)

[[126.73155314  36.49030365]
 [127.13280098  36.87569448]
 [127.00272619  36.2738885 ]
 [126.67984947  36.13878243]
 [126.58517477  36.82209541]
 [126.3588116   36.73353194]]

lon <- c(126.73155314, 127.13280098, 127.00272619, 126.67984947, 126.58517477, 126.3588116)
lat <- c(36.49030365, 36.87569448, 36.2738885, 36.13878243, 36.82209541, 36.73353194)
data <- cbind(lon, lat)
data <- data.frame(data)
data

RPC <- read.csv('충남_integrated.csv', fileEncoding = 'cp949');RPC
RPC <- RPC[, c('X', 'Y')]
DSC <- read.csv('pred_test.csv')
DSC %>% head
*마커로 위치 표시하고 위치 이름 넣기
mymap <- get_googlemap('충청남도', maptype = 'roadmap', zoom = 9)
ggmap(mymap)+geom_point(aes(x = X, y = Y), 
                        data = RPC, alpha = 1, size=8, col = 'blue') +
    scale_colour_gradient(low = "red",high="blue") + coord_equal() + theme_bw() + 
  ggtitle("Predicted residuals by using Kriging") + theme(plot.title = element_text(hjust = 0.5))
geom_circle(aes(x0 = lon, y0 = lat, r = 0.15), inherit.aes = FALSE, data = data)

# 127.016042	36.924276
# 127.13280098,  36.87569448
# 127.130687	36.928993
# 126.706900	36.034965
# 126.757764	36.054379
# 126.725002	36.749460
# 126.545880	36.703520
# 126.536719	36.757211
# 126.691520	36.793728
# 126.408515	36.723079
# 126.252220	36.783993
# 126.289632	36.725815 
# 126.600952	36.910349 127.168458	36.214471 127.210461	36.765604 126.953137	36.890449

long <- c(126.953137, 126.856604, 127.066841, 127.103875,126.73155314 ,  126.600952,127.016042, 127.13280098,  126.706900, 126.757764,  126.545880, 126.536719, 126.691520, 126.408515, 126.252220, 126.289632)
latg <- c(36.890449, 36.269592, 36.134360, 36.239235,36.49030365,  36.910349,36.924276, 36.87569448,  36.034965, 36.054379, 36.703520, 36.757211, 36.793728, 36.723079, 36.783993, 36.725815)
df <- cbind(long, latg)
df <- data.frame(df)
df
mymap <- get_googlemap('충청남도', maptype = 'roadmap', zoom = 9, markers = df)
ggmap(mymap)+ ggtitle("제안하는 RPC 통합 위치") + theme(plot.title = element_text(hjust = 0.5))
