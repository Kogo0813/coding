using Pkg, Plots, DataFrames, CSV
pwd()

# load Data
data = CSV.read("titanic/train.csv", DataFrame)

# EDA
describe(data)

# data preprocessing

using Statistics, Missings

using Missings

# fill missing values
data.Age = coalesce.(data.Age, mean(skipmissing(data.Age)))
data.Embarked = coalesce.(data.Embarked, "S")

# remove unnecessary columns
data = select(data, Not([:PassengerId, :Name, :Ticket, :Cabin]))
describe(data)

# one-hot-encoding
using ScikitLearn
@sk_import preprocessing: OneHotEncoder

encoder = OneHotEncoder()
Sex = data.Sex
Embarked = data.Embarked

bit_Sex = transpose(unique(data.Sex) .== permutedims(data.Sex))
bit_Embarked = transpose(unique(data.Embarked) .== permutedims(data.Embarked))

male = Matrix(bit_Sex)[:, 1]
female = Matrix(bit_Sex)[:, 2]

S = Matrix(bit_Embarked)[:, 1]
C = Matrix(bit_Embarked)[:, 2]
Q = Matrix(bit_Embarked)[:, 3]

encode_df = DataFrame(male = male, female = female, S = S, C = C, Q = Q)
df = hcat(data, encode_df)

describe(df)

# EDA
using StatsPlots

histogram(data.Survived, label = "Survived", xlabel = "Survived", ylabel = "Count")
select!(df, Not([:Sex, :Embarked]))

histogram(df.Age, label = "Age", xlabel = "Age", ylabel = "Count")
boxplot(df.Age, label = "Age")
boxplot!(df.Fare, label = "Fare")

using Statistics

println("Survived: ", mean(df.Survived))

value_counts(df, col) = combine(groupby(df, col), nrow)
using StatsBase
StatsBase.countmap(df.Survived)

using PlotlyJS
PlotlyBase.bar(countmap(df.Pclass))
xlabel!("Pclass")
ylabel!("Count")
title!("Pclass/count")


describe(df)

using CategoricalArrays
df.Pclass = categorical(df.Pclass)
df.Parch = categorical(df.Parch)

Pkg.add("PyCall")
Pkg.add("PyPlot")
using PyPlot, PyCall

PyPlot.matplotlib.use("TkAgg")

