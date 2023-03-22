using Pkg

using RDatasets, Statistics, DataFrames, Plots

# 데이터 로드하기
iris = dataset("datasets", "iris")
iris[end-4 : end, :] # 마지막 5개 행 출력

# 데이터 요약
describe(iris)

# 데이터 시각화

scatter(iris[!, :SepalLength], iris[!, :PetalLength], group = iris[!, :Species],
    xlabel = "Sepal Length", ylabel = "Petal Length", title = "Iris Data",
    legend = :topleft, markersize = 5, markershape = :circle,
    markercolor = [:red :green :blue], markerstrokewidth = 0)

histogram(iris[!, :SepalLength], group = iris[!, :Species],
    xlabel = "Sepal Length", ylabel = "Count", title = "Iris Data",
    legend = :topleft,
    markercolor = [:red :green :blue], markerstrokewidth = 0)

iris

# 로지스틱 회귀분석
Pkg.add("GLM")
using GLM

# 종속변수와 독립변수 분리
# virginica인지 아닌지를 분류하는 모델을 만들자

iris.y = iris.Species .== "virginica"
iris

# 모델 생성
model = glm(@formula(y ~ SepalLength + SepalWidth + PetalLength + PetalWidth), iris, Binomial(), LogitLink())
summary(model)

# 데이터 분리
using Random, StatsBase
Random.seed!(1234)


selected_rows = StatsBase.sample(1:Int(nrow(iris)), Int(0.7 * nrow(iris)), replace = false)
train = iris[selected_rows, :]
test = iris[setdiff(1:nrow(iris), selected_rows), :] # setdiff: 겹치지 않는 값 추출

# 사이킷런
Pkg.add("ScikitLearn")
using ScikitLearn: fit!, predict
using ScikitLearn
@sk_import linear_model : LogisticRegression

model = LogisticRegression(fit_intercept = true)
ScikitLearn.fit!(model, train[!, 1:4], train[!, 6])


# MLJ.jl
Pkg.add("MLJ")
using MLJ
@time selectrows(iris, 1:5)
@time iris[1:5, :] |> pretty

MLJ.schema(iris)


X = iris[!, 1:4]
y = iris[!, 6]
models(matching(X, y))

train, test = partition(eachindex(y), 0.7, shuffle = true)

# 의사결정나무 모델 생성
Pkg.add("DecisionTree")
doc("DecisionTreeClassifier", pkg="DecisionTree")

using DecisionTree 
Tree = DecisionTreeClassifier(max_depth = 2)

model = LogisticRegression(fit_intercept=true)
train_X = float.(train[!, 1:4])
train_y = string.(train[!, 5])

test_X = test[!, 1:4]
test_y = string.(test[!, 5])


ScikitLearn.fit!(model, train_X, train_y)
describe(train_X)

train_X = Matrix(train_X)
train_y = Vector(train_y)
test_X = Matrix(test_X)
test_y = Vector(test_y)

# fit!에 넣을때 Matrix로 바꿔줘야함
model = DecisionTreeClassifier(max_depth = 2)
classifier = fit!(model, train_X, train_y)

print_tree(model, 5)
predict(classifier, test_X)
predict_proba(classifier, test_X)
println(get_classes(model))

using ScikitLearn.CrossValidation: cross_val_score
accuracy = cross_val_score(classifier, test_X, test_y, cv = 5)
mean(accuracy)