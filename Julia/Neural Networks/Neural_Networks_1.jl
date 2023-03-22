using Flux, Flux.Data.MNIST
using Flux: onehotbatch, argmax, crossentropy, throttle
using Base.Iterators: repeated
using Images


using MLDatasets

x_train, y_train = MNIST.traindata()
hcat(x_train...) |> gpu

y_train = onehotbatch(y_train, 0:9)

m = Chain(
    Dense(28^2, 32, relu),
    Dense(32, 10),
    softmax)

loss(x, y) = Flux.crossentropy(m(x), y)
accuracy(x, y) = mean(argmax(m(x)) .== argmax(y))

datasetx = repeated((x_train, y_train), 100)
C = collect(datasetx);

evalcv = () -> @show(loss(x_train, y_train))

ps = Flux.params(m)

opt = ADAM()
Flux.train!(loss, ps, datasetx, opt, cb = throttle(evalcv, 10))

size(x_train)
x_train = reshape(x_train, 784, 60000)
size(x_train)
