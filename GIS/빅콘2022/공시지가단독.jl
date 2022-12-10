using CSV, DataFrames, Plots, StatsPlots, GeoStats

cd(@__DIR__); pwd()

cost = CSV.read("../01_data/end.csv", DataFrame)
unique!(cost, :위도)
select!(cost, [:경도, :위도, :공시지가])
rename!(cost, [:lon, :lat, :price])

default()
histogram(cost.price)
histogram(log10.(cost.price))

cost.price = log10.(cost.price)
cost[!,:residue] = (cost.price .- mean(cost.price))
default(size = (600,600), msw = 0, xlim = (127, 127.5), ylim = (37, 37.5))
scatter(cost.lon, cost.lat, zcolor = cost.price, label = :none)

# https://github.com/JuliaEarth/KrigingEstimators.jl/blob/master/test/estimators.jl
givenset = PointSet([cost.lon cost.lat]')
new_location =
[
    127.25  127.118  127.40
     37.25   37.224   37.13
]
prdctset = PointSet(new_location)
data = georef((z=cost.price,), givenset)


# https://juliaearth.github.io/GeoStats.jl/stable/kriging.html

# γ = EmpiricalVariogram(data, :z)
# plot(γ)
γ = GaussianVariogram(sill=1., range=1., nugget=0.)

simkrig = SimpleKriging(data, γ, mean(data[:z]))
SKestimate, SKvar = predict(simkrig, :z, givenset[1])
SKestimate, SKvar = predict(simkrig, :z, givenset[2])
SKestimate, SKvar = predict(simkrig, :z, givenset[3])
cost.price[1:3]

z1 = predict(simkrig, :z, prdctset[1])[1]
z2 = predict(simkrig, :z, prdctset[2])[1]
z3 = predict(simkrig, :z, prdctset[3])[1]

scatter(cost.lon, cost.lat, zcolor = cost.price, label = "data")
scatter!(eachrow(new_location)..., zcolor = [z1, z2, z3], markershape = :rect, label = "new location")