using Pkg, Plots, DataFrames, CSV
pwd()

# load Data
data = CSV.read("./titanic/train.csv", DataFrame)

# EDA
describe(data)

# data preprocessing
Pkg.add("Missings")
using Statistics, Missings

using Missings

# fill missing values
data.Age = coalesce.(data.Age, mean(skipmissing(data.Age)))
data.Embarked = coalesce.(data.Embarked, "S")

# remove unnecessary columns
data = select(data, Not([:PassengerId, :Name, :Ticket, :Cabin]))
describe(data)

# one-hot-encoding
Pkg.add("ScikitLearn")
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

value_counts(daf, col) = combine(groupby(df, col), nrow)
using StatsBase
StatsBase.countmap(df.Survived)


bar(countmap(df.Pclass))
xlabel!("Pclass")
ylabel!("Count")
title!("Pclass/count")


describe(df)

using CategoricalArrays
df.Pclass = categorical(df.Pclass)
df.Parch = categorical(df.Parch)

df
describe(df)

# xgboost를 적용해보자
Pkg.add("XGBoost")
using XGBoost

# split Data
Pkg.add("MLDataUtils")
using MLDataUtils

y = df.Survived
X = select(df, Not([:Survived]))

Xs, ys = shuffleobs((X, y))
(X_train, y_train), (X_test, y_test) = splitobs((Xs, ys); at = 0.7)
X_train
y_train

Pkg.add("DecisionTree")
using DecisionTree

model = RandomForestClassifier()
DecisionTree.fit!(model, X_train, y_train)