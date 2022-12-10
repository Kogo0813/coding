suppressPackageStartupMessages({
  library(tidyverse)
  library(data.table)
  library(ggmap)
  library(tmap)
  library(tmaptools)
  library(leaflet)
  library(mapview)
  library(sf)
  library(raster)
  library(magrittr)
})

a_ <- c(1,1)
point <- st_point(a_)
plot(point)

# line
b_ <- matrix(c(0,0, 3,3, 3,0, 0,0), 4, 2, byrow=TRUE)
big_triangle <- st_linestring(b_)
plot(big_triangle, col='red')

# polygon
c_ <- matrix(c(1,1, 2,2, 2,0, 1,1), 4, 2, byrow=TRUE)
outer <- b_
hole <- c_
triangle_polygon_with_hole <- st_polygon(list(outer, hole))
plot(triangle_polygon_with_hole)

wifi = fread("./서울시_공공와이파이.csv", header=T, encoding = "UTF-8")

colnames(wifi) = c("gu","type","zone","lon","lat","comp")
wifi %>% summary

wifi %<>% na.omit
wifi %>% summary

x1r = range(wifi$lon)
x2r = range(wifi$lat)
mylocation = c(x1r[1]-.02,x2r[1]-.1,x1r[2]+.1,x2r[2]-.1)

myMap <- get_map(location=mylocation, source="google", maptype="roadmap", zoom = 10) 
#myMap <- get_map(location=mylocation, source="google", maptype="hybrid",zoom=11) 
#myMap <- get_map(location=mylocation, source="google", maptype="terrain",zoom=11) 
ggmap(myMap)

ggmap(myMap)+ geom_point(aes(x = lon, y = lat, colour=gu), 
                         data = wifi, alpha = .5, size = 2) + coord_equal() 

ggmap(myMap) + stat_density_2d(aes(fill=..level..),geom="polygon", data = wifi, alpha = .2, size = 1) +
  geom_point(aes(x=lon,y=lat),data=wifi, alpha=0.4,color="black",size=0.5) +
  coord_equal() + scale_fill_continuous(low = "lightseagreen",high="tomato",name="Density")

telecom = c("KT","LGU+","SKT")
wifi2 = wifi[comp %in% telecom,]

ggmap(myMap) + stat_density_2d(aes(fill=..level..),geom="polygon", data = wifi2, alpha = .2, size = 1) +
  geom_point(aes(x=lon,y=lat),data=wifi2,alpha=0.4,color="black",size=0.5) +
  scale_fill_continuous(low = "lightseagreen",high="tomato",name="Density") + facet_wrap(~comp,ncol=3)

# creat a basic map
leaflet() %>% 
  addTiles() %>% # add default OpenStreetMap map tiles
  setView(lng=127.063, lat=37.513, zoom = 6) # korea, zoom 6

# adding Popup
popup = c("COEX", "GBC", "JamsilStadium")

leaflet() %>% 
  addTiles() %>%
  addMarkers(lng = c(127.059, 127.063, 127.073), # longitude
             lat = c(37.511, 37.512, 37.516), # latitude
             popup = popup)

library(valuemap)
head(seoul)

valuemap(seoul)

valuemap(seoul, legend.cut=c(20))

valuemap(seoul, legend.cut=c(15,17,20), show.text=FALSE)

valuemap(
  seoul, map=leaflet::providers$Stamen.Toner, palette='YlOrRd',
  text.color='blue', text.format=function(x) paste(x,'EA')
)

load(url("https://github.com/mgimond/Spatial/raw/main/Data/Sample1.RData"))

tm_shape(s.sf) + 
  tm_polygons("Income", palette = c('lightblue','khaki1', 'red3'), border.col = "white", border.alpha = 1,
              breaks = c(20000,21000,22000,23000), title = "How much is the Income?", lwd = 2, legend.hist = TRUE) + 
  tm_legend(outside = TRUE, hist.width = 2) + 
  tm_layout(legend.position = c("right","bottom"), inner.margins = c(0.06,0.10,0.10,0.08), frame = FALSE) +
  tm_compass(type = "8star", position = c("left", "top")) +
  tm_scale_bar(breaks = c(0, 100, 200), text.size = 1)

tm_shape(s.sf) + 
  tm_polygons("NAME", palette = "Pastel1", border.col = "white") + 
  tm_legend(outside = TRUE) +
  tm_shape(p.sf) +   
  tm_dots(size=  .3, col = "red") +
  tm_text("Name", just = "left", xmod = 0.5, size = 0.8)

library(spData)

urb_anim = tm_shape(world) + tm_polygons() + 
  tm_shape(urban_agglomerations) + tm_dots(size = "population_millions") +
  tm_facets(along = "year", free.coords = FALSE)

#tmap_animation(urb_anim, filename = "./animation.gif", delay = 25)

# Display all plots
knitr::include_graphics("./animation.gif")

tmap_mode("view")

tm_shape(s.sf) + 
  tm_polygons("NAME", palette = "Pastel1", border.col = "white") + 
  tm_legend(outside = TRUE) +
  tm_shape(p.sf) +   
  tm_dots(size=  .3, col = "red") +
  tm_text("Name", just = "left", xmod = 0.5, size = 0.8)

library(httr)
library(jsonlite)

trans_addre = function(addr){
  url1 = "https://dapi.kakao.com/v2/local/search/address.json"
  Kakao_key = "33c9809fd669d537ffb10c146c9e99c6"
  
  addr_trans = GET(url1, query = list(query = addr),
                   add_headers(Authorization = paste("KakaoAK", Kakao_key)))
  
  
  addr_tr = addr_trans %>% content(as = 'text') %>% fromJSON()
  #addr_tr$documents
  
  lat = as.numeric(addr_tr$documents$x)
  lon = as.numeric(addr_tr$documents$y)
  
  dat = data.frame(long = lon, lat = lat)
  return(dat)
}

trans_addre("대구광역시 북구 대학로 80")


