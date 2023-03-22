using DataFrames, Statistics, PyPlot
using GLM


aq = [10.0   8.04  10.0  9.14  10.0   7.46   8.0   6.58
       8.0   6.95   8.0  8.14   8.0   6.77   8.0   5.76
      13.0   7.58  13.0  8.74  13.0  12.74   8.0   7.71
       9.0   8.81   9.0  8.77   9.0   7.11   8.0   8.84
      11.0   8.33  11.0  9.26  11.0   7.81   8.0   8.47
      14.0   9.96  14.0  8.1   14.0   8.84   8.0   7.04
       6.0   7.24   6.0  6.13   6.0   6.08   8.0   5.25
       4.0   4.26   4.0  3.1    4.0   5.39  19.0  12.50 
      12.0  10.84  12.0  9.13  12.0   8.15   8.0   5.56
       7.0   4.82   7.0  7.26   7.0   6.42   8.0   7.91
       5.0   5.68   5.0  4.74   5.0   5.73   8.0   6.89]

df = DataFrame(aq, :auto)

# 두 문자열을 합침
newnames = vec(string.(["x", "y"], [1 2 3 4]))

# 열 이름을 변경
rename!(df, newnames)

DataFrame(aq, [:x1, :y1, :x2, :y2, :x3, :y3, :x4, :y4])

df.y1
df."y1"

@time df[:, :y1]
@time df[!, :y1]

select!(df, r"x", :) # x로 시작하는 열 먼저 선택
describe(df, mean => :mean, std => :std)

df.id = 1:nrow(df);df
ncol(df)
select(df, "id", :) # id 열을 맨 앞으로 옮김
Matrix(df)

# extrema : 최대값과 최소값을 구함
xlims = collect(extrema(Matrix(select(df, r"x"))) .+ (-1, 1))
ylims = collect(extrema(Matrix(select(df, r"y"))) .+ (-1, 1))

pygui(true)
fig, axes = plt.subplots(2, 2)
fig.tight_layout(pad = 4.0)
for i in 1:4
       x = Symbol("x", i)
       y = Symbol("y", i)
       model = lm(term(y) ~ term(x), df)
       axes[i].plot(xlims, predict(model, DataFrame(x => xlims)), color = "orange")
       axes[i].scatter(df[:, x], df[:, y])
       axes[i].set_xlim(xlims)
       axes[i].set_ylim(ylims)
       axes[i].set_xlabel("x$i")
       axes[i].set_ylabel("y$i")
       a, b = round.(coef(model), digits = 2)
       c = round(100 * r2(model), digits = 2)
       axes[i].set_title("y$i = $a x$i + $b, R² = $c%")
end

x = :var1
y = :var2
xc = 1:3
yc = 4:6
DataFrame(x => xc, y => yc)

DataFrame(var1=xc, var2=yc)

using Pkg
Pkg.add("Arrow")
using CSV, Arrow

download("https://archive.ics.uci.edu/ml/machine-learning-databases/auto-mpg/auto-mpg.data-original",
         "auto.txt")
readlines("auto.txt")

raw_str = read("auto.txt", String)
str_no_tab = replace(raw_str, "\t" => " ")
io = IOBuffer(str_no_tab)

df1 = CSV.File(io,
       delim = ' ',
       ignorerepeated = true,
       header = [:mpg, :cylinders, :displacement, :horsepower,
                 :weight, :acceleration, :model_year, :origin, :name],
       missingstring = "NA") |> DataFrame

df_raw = CSV.File("auto.txt", header = [:metrics, :name]) |> DataFrame
str_metrics = split.(df_raw.metrics)
df1_2 = DataFrame([col => Float64[] for col in names(df1)])
allowmissing!(df1_2, [:mpg, :horsepower])

for row in str_metrics
       push!(df1_2, [v == "NA" ? missing : parse(Float64, v) for v in row])
end

sum(count(ismissing, df1) for col in eachcol(df1))
count(ismissing, Matrix(df1))
count(ismissing, Iterators.flatten(eachcol(df1)))
mapcols(x -> count(ismissing, x), df1)

# 결측값이 있는 행들만 확인
filter(row -> any(ismissing, row), df1)

df1.brand = unique.(first.(split.(df1.name)))
dropmissing(df1)
#############################
using CSV
df = CSV.File("auto2.csv") |> DataFrame

using Arrow
@time df2 = Arrow.Table("auto2.arrow") |> DataFrame
# Arrow로 저장하는 게 더 빠름
df == df2

df2.mpg
df3 = copy(df2)
df3.mpg

gdf = groupby(df, :brand)
gdf[("ford", )]
brand_mpg = combine(gdf, :mpg => mean)
brand_mpg = combine(gdf, :mpg => mean => :mean_mpg)

sort!(brand_mpg, :mean_mpg, rev = true)

using FreqTables
freqtable(df, :brand, :origin, :mpg)

using Pipe
orig_brand = @pipe df |>
       groupby(_, :brand) |>
       combine(_, :origin => (x -> length(unique(x))) => :n_orig)


origin_brand2 = @pipe df |>
       groupby(_, [:origin, :brand]) |>
       combine(_, nrow)

origin_vs_brand = unstack(origin_brand2, :brand, :origin, :nrow)
coalesce.(origin_vs_brand, 0)

origin_brand3 = @pipe df |>
       groupby(_, :origin) |>
       combine(_, :brand => x -> Ref(unique(x)))

flatten(origin_brand3, :brand_function)
