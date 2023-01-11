# install.packages("C:/Program Files/R/R-4.2.2/library/epimdr_0.6-5.tar.gz")
library(epimdr)

data(peru)
head(peru)

# cumulative incidence 누적 계산
peru$cumulative = cumsum(peru$incidence)

# Define denominator
peru$n = sum(peru$incidence)
par(mar = c(5, 5, 2, 5)) # Make room for two axes and plot

# Plot
plot(peru$incidence ~ peru$age, type = 'b', xlab = 'Age', ylab = 'Incidence')
par(new = T)
plot(peru$cumulative~peru$age, type = 'l', col = 'red', axes = FALSE, xlab = NA, ylab = NA)
axis(side = 4)
mtext(side = 4, line = 4, 'Cumulative')
legend('right', legend = c('Incidence', 'Cumulative'), lty = c(1,1), col = c('black', 'red'))

peru
