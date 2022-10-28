using Pkg
using CSV, DataFrames


# 변수이름을 칼럼명으로 가지는 데이터프레임 만들기
mycol1 = rand(5); B = 1:5;
DataFrame(; mycol1, B)

df = DataFrame(rand(100000,5), :auto)
nrow(df)
ncol(df)
size(df)

@time for i in 1:10^6
    nrow(df)
end

@time for i in 1:10^6
    size(df)
end

Pkg.add("RDatasets")
using RDatasets
iris = dataset("datasets", "iris")
describe(iris)

using Plots
plot(iris[!, :SepalLength], iris[!, :SepalWidth], seriestype = :scatter)

# 데이터프레임 특정 값 변경하는 법
WJSN = DataFrame(
    member = ["다영","다원","루다","소정","수빈","연정","주연","지연","진숙","현정"],
    birth = [99,97,97,95,96,99,98,95,99,94],
    height = [161,167,157,166,159,165,172,163,162,165],
    unit = ["쪼꼬미","메보즈","쪼꼬미","더블랙","쪼꼬미","메보즈","더블랙","더블랙","쪼꼬미","더블랙"]
)

replace!(WJSN.member, "진숙" => "여름");WJSN

# NAN 값 제거하는 방법
df = DataFrame(rand(1:9, 3, 3), :auto) ./ DataFrame(rand(0:1, 3, 3), :auto)
ifelse.(isinf.(df), 0, df)
