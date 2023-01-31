using DataTables, ExcelFiles, CSVFiles, DataFrames
using XLSX
using Pkg
Pkg.add("ExcelReaders")
using ExcelReaders
using Distributions

pwd()

# Read in the data
xf = XLSX.readxlsx("../data/COVID19_variants_국내.xlsx")
sh = xf["Sheet_1"]
dt = sh[:]

# Convert to DataFrame
propertynames(dt)

col_vec = dt[1, :]

df = DataFrame(dt[2:end, :], Symbol.(col_vec))
rename!(df, :missing => :Date)
rename!(df, :- => :Other)

# 필요없는 열 제거
df = df[:, [:Date, :city, :Other, :Delta, :Omicron]]
describe(df)

using Plots
plot(df.Date, df.Delta, label="Delta")

# 줄리아 type 변경
df.Delta, df.Omicron = map(x -> convert(Array{Int32}, x), [df.Delta, df.Omicron])
df.Other = convert(Array{Int32}, df.Other)
df.city = convert(Array{String}, df.city)

groupby(df, :city)
df.total = df.Delta + df.Omicron + df.Other

Pkg.add("StatsFuns")
Pkg.add("SpecialFunctions")
using SpecialFunctions, StatsFuns
# W계산
function W(num::Int64)
    x = range(1, num, num)
    μ = 4.8
    σ = 2.3
    shape = μ^2 / σ^2
    scale = σ^2 / μ
    y = pdf.(Gamma(shape, scale), x)
    W = y
    return W
end

df[:, :W] = W(length(df.city))
# cori 함수
function cori(j, data, W)
    a = data[j]
    b = 0

    for k in 1:(j-1)
        b += data[j-k] * W[k]
    end

    if b > 0
        cori = a / b
    else
        cori = 0
    end
    return cori
end

insertcols!(df, :Cori => missings(Float64), makeunique=true)
select!(df, Not([:Cori]))
df.Cori = 1:19242
df.Cori = convert(Array{Float64}, df.Cori)
for i in 1:length(df.city)
    df.Cori[i] = cori(i, df.total, df.W)
end

using Dates
x = df.Date
df[!, :Date] = Date.(df.Date, dateformat"y-m-d")
plot(df.Date[:], df.Cori[:], label="Cori")