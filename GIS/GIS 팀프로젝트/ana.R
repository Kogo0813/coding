library(dplyr)
library(car)

# Load data
df <- read.csv('integrated.csv')
df


lm_model <- lm(Y ~ lon + lat + I(sqrt(IC)) + sqrt(HAR) + RPC, data = df)
lm_model %>% summary
vif(lm_model)
par(mfrow = c(2,2))
plot(lm_model)

attach(df)
plot(IC, log10(Y))
plot(HAR, log10(Y))
plot(RPC, log10(Y))
par(mfrow = c(1,1))
Y = log10(Y)
library(mlbench)
step(lm_model) %>% summary

df['Y'] <- log10(df['Y'])

install.packages('gvlma')
library(gvlma)
gvlma(lm_model) %>% summary
shapiro.test(lm_model$residuals)
df
sqrt(lon) %>% hist
sqrt(lat) %>% hist
plot(IC, Y)
avPlots(lm_model)
HAR %>% hist
log10(IC) %>% hist
df

install.packages('robustbase')
library(robustbase)

lmrob(log10(Y) ~ lon + lat + I(RPC/IC) + sqrt(HAR) + square, data = df)%>% summary

ratio <- RPC/IC
plot(ratio, Y)


FM <- lm(log10(Y) ~ lon + lat + I(RPC/IC) + sqrt(HAR) + square, data = df)
FM %>% summary
df['square'] <- 10^df['square']

attach(df)
square %>% hist

library(gvlma)
gvlma(FM) %>% summary
shapiro.test(FM$residuals)
par(mfrow = c(2,2))
plot(FM)


lmrob(log10(Y) ~ lon + lat + sqrt(I(RPC/IC)) + sqrt(HAR) + square, data = df)%>% summary
RPC/IC %>% hist
ratio <- RPC/IC
sqrt(ratio) %>% hist
















