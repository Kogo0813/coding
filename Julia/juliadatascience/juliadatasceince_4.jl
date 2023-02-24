# 4. DataFrames.jl

using DataFrames

function grades_array()
    name = ["Bob", "Sally", "Alice", "Hank"]
    age = [17, 18, 19, 20]
    grade_2020 = [5.0, 1.0, 8.5, 4.0]
    (; name, age, grade_2020)
end

function second_row()
    name, age, grade_2020 = grades_array()
    i = 2
    row = (name[i], age[i], grade_2020[i])
end

second_row()

# name에 Alice가 있는 행의 인덱스를 반환하는 함수
function row_alice()
    names = grades_array().name
    i = findfirst(names .== "Alice")
end

row_alice()

# DataFrames.jl 이용해서 DataFrame 만들기

names = ["Sally", "Bob", "Alice", "Hank"]
grades = [1, 5, 8.5, 4]
df = DataFrame(; name = names, grade = grades) # name, grade의 인자를 생략하고 값만 써도됨

df = DataFrame(name = ["Malice"], grade_2020 = ["10"])

function grades_2020()
    name = ["Sally", "Bob", "Alice", "Hank"]
    grade_2020 = [1, 5, 8.5, 4]
    DataFrame(; name, grade_2020)
end

df = grades_2020()

using CSV
grades_2020()

# CSV 파일로 저장하기
function write_grades_csv()
    path = "grades.csv"
    CSV.write(path, grades_2020())
end

path = write_grades_csv()
read(path, String)

CSV.read(path, DataFrame)

# Excel

my_data = """
a,b,c,d,e
Kim,2018−02−03,3,4.0,2018−02−03T10:00
"""
path = "my_data.csv"
write(path, my_data)
df = CSV.read(path, DataFrame)

using XLSX:
    eachtablerow,
    readxlsx,
    writetable

function write_xlsx(name, df::DataFrame)
    path = "$name.xlsx"
    data = collect(eachcol(df))
    cols = propertynames(df)
    writetable(path, data, cols)
end

function write_grades_xlsx()
    path = "grades"
    write_xlsx(path, grades_2020())
    "$path.xlsx"
end

path = write_grades_xlsx()

xf = readxlsx(path)
sheet = xf["Sheet1"]
eachtablerow(sheet) |> DataFrame


df.name
df.grade_2020
df[!, :name]
df[:, :name]
df[!, [:name, :grade_2020]]
df[!, [:name]]

df = DataFrame(id = [1])
@edit df.name

df = grades_2020()
df[2, :]

df[2::Int, :]
df[1:2, :name]

dic = Dict(zip(df.name, df.grade_2020))
keys(dic)
values(dic)

collect(zip(df.name, df.grade_2020))

filter(:name => ==("Alice"), df)
filter(:name => n -> n == "Alice", df)

# complex_filter
function complex_filter(name, grade)::Bool
    interesting_name = startswith(name, "A") || startswith(name, "B")
    interesting_grade = grade > 6
    interesting_name && interesting_grade
end

filter([:name, :grade_2020] => complex_filter, df)

# 4.3.2
using DataFrames
df = grades_2020()

equals_alice(name::String) = name == "Alice"
subset(grades_2020(), :name => ByRow(equals_alice))
subset(grades_2020(), :name => ByRow(name -> name == "Alice"))
subset(grades_2020(), :name => ByRow(==("Alice")))


function salaries()
names = ["John", "Hank", "Karen", "Zed"]
salary = [1_900, 2_800, 2_800, missing]
DataFrame(; names, salary)
end
salaries()

filter(:salary => >(2_000), salaries())
subset(salaries(), :salary => ByRow(>(2_000)); skipmissing = true)

# 4.4 Select
function responses()
    id = [1, 2]
    q1 = [28, 61]
    q2 = [:us, :fr]
    q3 = ["F", "B"]
    q4 = ["B", "C"]
    q5 = ["A", "E"]
    DataFrame(; id, q1, q2, q3, q4, q5)
end
responses()

select(responses(), :q1)
select(responses(), :id, :q1)

select(responses(), Not(:q5))
select(responses(), :q5, Not(:q5))

select(responses(), 1 => "participant", :q1 => "age", :q2 => "nationality")

renames = (1 => "particant", :q1 => "age", :q2 => "nationality")
select(responses(), renames...)

# 4.5 Types and Missing Data
function wrong_types()
    id = 1:4
    date = ["28−01−2018", "03−04−2019", "01−08−2018", "22−11−2020"]
    age = ["adolescent", "adult", "infant", "adult"]
    DataFrame(; id, date, age)
    end
wrong_types()

sort(wrong_types(), :date)

# 범주형 데이터 생성
using Pkg
Pkg.add("CategoricalArrays")
using CategoricalArrays

function fix_age_column(df)
    levels = ["infant", "adolescent", "adult"]
    ages = categorical(df[!, :age]; levels, ordered = true)
    df[!, :age] = ages
    df
end

fix_age_column(wrong_types())

df = fix_age_column(wrong_types())
sort(df, :age)

# 4. 6 Join
grades_2020()

function grades_2021()
    name = ["Bob 2", "Sally", "Hank"]
    grade_2021 = [9.5, 9.5, 6.0]
    DataFrame(; name, grade_2021)
end
grades_2021()

innerjoin(grades_2020(), grades_2021(), on = :name)
leftjoin(grades_2020(), grades_2021(), on = :name)

crossjoin(grades_2020(), grades_2021(); on = :name)

crossjoin(grades_2020(), grades_2021(); makeunique = true)

# semijoin and antijoin
semijoin(grades_2020(), grades_2021(), on = :name) # 왼쪽에서 겹치는 것만
antijoin(grades_2020(), grades_2021(), on = :name) # 왼쪽에서 겹치지 않는 것만

plus_one(grades) = grades .+ 1
transform(grades_2020(), :grade_2020 => plus_one)
transform(grades_2020(), :grade_2020 => plus_one => :grade_2020)

transform(grades_2020(), :grade_2020 => plus_one; renamecols=false)

df = grades_2020()
df.grade_2020 = plus_one.(df.grade_2020)
df