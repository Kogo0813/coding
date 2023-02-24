# Groupby and Combine
using DataFrames, CategoricalArrays




function grades_2020()
    name = ["Sally", "Bob", "Alice", "Hank"]
    grade_2020 = [1, 5, 8.5, 4]
    DataFrame(; name, grade_2020)
end

function grades_2021()
    name = ["Bob 2", "Sally", "Hank"]
    grade_2021 = [9.5, 9.5, 6.0]
    DataFrame(; name, grade_2021)
end

function all_grades()
    df1 = grades_2020()
    df1 = select(df1, :name, :grade_2020 => :grade)
    df2 = grades_2021()
    df2 = select(df2, :name, :grade_2021 => :grade)
    rename_bob2(data_col) = replace.(data_col, "Bob 2" => "Bob")
    df2 = transform(df2, :name => rename_bob2 => :name)
    return vcat(df1, df2)
end
all_grades()

grades_2021()
grades_2020()

groupby(all_grades(), :name)'

using Statistics

gdf = groupby(all_grades(), :name)
combine(gdf, :grade => mean => :grade)

# i want to apply function to multiple columns
group = [:A, :A, :B, :B]
X = 1:4
Y = 5:8
df = DataFrame(; group, X, Y)

gdf = groupby(df, :group)
combine(gdf, [:X, :Y] .=> mean; renamecols = true)
gdf

gdf = groupby(df, :group)
rounded_mean(data_col) = round(Int, mean(data_col))
combine(gdf, [:X, :Y] .=> rounded_mean; renamecols = false)


function responses()
id = [1, 2]
q1 = [28, 61]
q2 = [:us, :fr]
q3 = ["F", "B"]
q4 = ["B", "C"]
q5 = ["A", "E"]
DataFrame(; id, q1, q2, q3, q4, q5)
end

# bang(!) operator의 메모리 할당 비교
# : 새로운 데이터프레임을 생성하는 게 아니라 업데이트의 의미
@allocated select(responses(), :id, :q1)
@allocated select!(responses(), :id, :q1)

df = responses()
@allocated select(df, :id, :q1)

df = responses()
@allocated select!(df, :id, :q1)

df = responses()
@allocated col = df[:, :id]

df = responses()
@allocated col = df[!, :id]

df = responses()
@allocated col = df.id

# CSV 파일 로드에서 효율적인 방법
using CSV

@allocated df = CSV.read("grades.csv", DataFrame)

@allocated df = DataFrame(CSV.File("grades.csv"))

@allocated df = CSV.File("grades.csv") |> DataFrame

files = filter(endswith(".csv"), readdir())
readdir()

df = reduce(vcat, CSV.read(file, DataFrame) for file in files)

# CategoricalArrays.jl
typeof(categorical(["A", "B", "C"]))
typeof(categorical(["A", "B", "C"]; compress = true)) # 메모리가 적은 type으로 저장

using Random
one_mi_vec = rand(["A", "B", "C", "D"], 1_000_000)
Base.summarysize(categorical(one_mi_vec))
Base.summarysize(categorical(one_mi_vec; compress = true))

