println("Hello, world")
abc = "Hello"
println("$abc World!")
println("$(abc) World!")


a = 1
typeof(a)
b = Int32(2)
typeof(b)

Int32 <: Integer
Char <: Integer
Float32 <: AbstractFloat
Int64 <: Integer <: Real

## complex number 도 정의가능
z = 1.0 + 2.0 * im
typeof(z)


A = [
    1 2 3
    4 5 6
    7 8 9
]
v = [1 2 3 4]
v[1] # Python과 다르게 1부터 시작
A[2,2]

v = collect(1:10) # 1부터 10까지 벡터 생성
v[2:5]
v[end-1 : end]

## julia는 일반적으로 행렬, 벡터로 처리를 하고 Python에서는 리스트로 처리를 한다.

[x * 10 for x in 1:10]

using SparseArrays
SparseVector <: AbstractVector
λ = 1.0

## 유니코드를 지원한다.
## 이모티콘도 지원한다.

🍎 = 10
🍉 = 20
🍌 = 30

Γ = [1, 2, 3, 6, 23, 6, 78, 3]
for γ ∈ Γ
    println(γ)
end

## 함수 정의
function f(x)
    return x ^ 2 + 10
end

f(x) = x^2 + 10
f(2)

using Pkg
Pkg.add("Calculus")
using Calculus

f(x) = x^2 + 10
df = Calculus.derivative(f)
df(1)

Pkg.add("ForwardDiff")
using ForwardDiff

## lambda function과 같은 방법
w = x -> x^2

ForwardDiff.derivative(w, 1)
dw = x -> ForwardDiff.derivative(w, 1)
dw(4)

rand(10)
rand(3, 5)
randn(2,3) # normal distribution
rand(1: 10, 5)
rand(Int, 5)

Pkg.add("Distributions")
using Distributions # 여러가지 분포에 대한 패키지

v = [1,2,3]
push!(v, 4) # 벡터를 변형시킬 때 !를 쓰는 게 약속

pop!(v)
v

f(x) = x^2 + 10
v = [4, 6 ,8]
f.(v) # 벡터에 대한 연산을 한번에 처리

w = [4, 5, 2]
v' * w

using LinearAlgebra
dot(v, w)

s = ["adda", "ddd", "eee"]
www(x) = x * "hi julia"
www.(s)

nothing
a = nothing
a 

@show v
function foo(x)
    println("x = ", x)
end

v = 20
foo(v)

ex = :(v = 20)
typeof(ex)
ex.args
ex.head
+(1, 2, 3)
@show v;

macro bar(x) # python에서의 decorator와 같은 역할
    :(println($(string(x)), "=", $x))
end

@bar v

f(x::Float64) = x^3 + 1000
f(1.0)
f(2)

function add2(x::T, y::T) where T <: Number
    x + y
end

@code_lowered add2(1,2)
@code_typed add2(1, 2) # 타입을 인지하고 각 타입 속도에 유리한 함수를 따로 사용해 계산해준다.


Pkg.add("Flux")
using Flux

NN1 = Chain(Dense(10, 5, tanh),
            Dense(5, 5, tanh),
            Dense(5, 2))

NN1(rand(10))

## 활성화 함수를 직접 정의하거나 층을 건드리는 경우 Flux.jl이 유리홤
