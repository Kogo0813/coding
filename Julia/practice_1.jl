using Pkg
Pkg.add("DataFrames")
Pkg.add("CSV")
Pkg.add("Plots")
Pkg.add("Statistics")
Pkg.add("StatsPlots")

typeof(Bool)
typeof(NaN)
typeof('O')
typeof("Ohmygirl")

supertype(Int64)
supertype(Integer)
supertype(Number)
supertype(Any)

# Any는 말그대로 모든 것을 포괄하기 때문에 편리하고 생산성이 높다
x = ["o", -1, [7, 'm'], 3.0]
typeof('O')
supertype(Char)
supertype(AbstractString)

typeof(x)
x[2] = 1.2 # index하는 방식은 파이썬이랑 동일한듯
print(x)

y = [0,1,1]
typeof(y)
# index가 1부터 시작한다는 것을 알 수 있음(R에서의 index방식과 동일)
y[2] = 9


# 사용자 정의 함수
# R과 비슷한 함수 정의 방식이지만, 괄호가 없고 마지막에 end로 종료를 알림
function add1(a,b)
    return a+b
end


add1(1,2)
# float타입의 변수는 따로 지정하지 않으면 오류가 난다. default : Int
add(1,2.0)

function add2(a::Int64, b::Float64)
    return a+b
end

# 함수의 인자의 타입을 미리 결정해주는 경우
add2(1,2.0)

using Base.Threads
nthreads()

using LinearAlgebra
using Pkg

Pkg.add("Distributions")

using Plots
# 패키지를 설치하는 것 자체는 파이썬보다는 R에 더 가깝고, 사용법은 파이썬과
# 더 비슷하다. R과 마찬가지로 패키지 이름을 큰 따옴표로 묶어줘야함


# 줄리아에서 패키지 버전 확인하는 방법
# ]를 통해 Pkg모드로 들어가서 status 패키지명 입력하면 된다.

# 특정 버전으로 설치하는 방법
# 패키지 모드에서 add 패키지명@버전명 입력하면 된다.

# 줄리아에서 R에서 쓰던 내장데이터셋 불러오는 법
Pkg.add("RDatasets")
using RDatasets

iris = dataset("datasets", "iris")

# 날짜 관련 함수
Pkg.add("Dates")
using Dates

today = DateTime(2022,10,24)
typeof(today)

propertynames(today)
today.instant

myformat = DateFormat("d-m-y")
tom = Date("11-3-2022", myformat)

Dates.dayname(tom)
일주일뒤까지 = today:Day(1):DateTime(2022,10,31)
collect(일주일뒤까지)

Dates.Day(일주일뒤까지[end]) - Dates.Day(today)

# DateTime 타입
# Dates 패키지를 사용하면 날짜와 시간을 다룰 수 있다.

toay = DateTime(2022,3,10)
typeof(today)


# 줄리아에서 데이터 생략 없이 출력하는 법
foo = rand(100,2)
# 원래는 위와 같이 ⋮가 찍히지만 플레인 텍스트로 찍으면 다음과 같이 전체가 출력된다.
show(stdout, "text/plain", foo)


# 줄리아의 브로드캐스팅 문법
# 브로드캐스팅은 줄링아에서 가장 중요한 개념으로, 벡터화된 코드를 작성함
# 에 있어서 아주 편리한 문법이다. 이항연산 앞에 .을 찍거나 함수 뒤에 .을
# 찍는 식으로 사용한다.

A = rand(0:9, 3, 4) # 0부터 9까지의 숫자로 3행 4열의 행렬을 만든다.
a = rand()
A .+ a # A의 각 원소에 a를 더한다.

f(x) = x^2 - 1
f(a)

f.(A) # A의 각 원소에 f를 적용한다.


# 속도 비교
@time for x in 1:100_000
    sqrt(x)
end

@time sqrt.(1:100_000);

z = []
@time for x in 1:100_000
    push!(z, sqrt(x))
end

@time y = sqrt.(1:100_000);


😊 = 1


# 줄리아에서 16진법 RGB 코드 사용하는 법
using Plots
histogram(randn(100))

# 배경을 투명하게 지정하는 방법
plot(rand(10), background_color = :transparent)
png("example")

# 가로세로를 조절하는 방법
# - ratio = :none : 기본값으로, 그림의 사이즈에 비율이 맞춰진다.
# - ratio = :equal : 가로세로 비율을 1:1로 맞춘다.
# - ratio = Number : 가로세로 비율을 Number로 맞춘다.

x = rand(100)
y = randn(100)
plot(x, y, seriestype = :scatter, ratio = :none)
plot(x, y, seriestype = :scatter, ratio = :equal)
plot(x, y, seriestype = :scatter, ratio = :0.5)

df1 = DataFrame(x = Int64[], y = String[])
push!(df1, [3, "three"])
push!(df1, [3.14, "pi"])

df2 = DataFrame(x = [], y = String[])
push!(df2, [3, "three"])
push!(df2, [3.14, "pi"])