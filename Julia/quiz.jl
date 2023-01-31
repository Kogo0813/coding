# 1. 함수
function pow2(n)
    if n ≤ 0
       return 1
    else
        return 2 * pow2(n-1)
    end
end 

pow2(0)
pow2(1)
pow2(2)

isless6(n) = (n < 6 ? 1 : 0)
isless6(3)

# 1-1 기본과제 
## 힌트 1을 참고해 주어진 자연수 n에 대해 nn번째 피보나치 수를 반환하는 함수 F(n)을 작성하라. 단 F1 = F2 = 1이다.

function F(n)
    if n ≤ 2
        return 1
    else 
        return F(n-1) + F(n-2)
    end
end
F(40)

# 1-2 심화과제
## 힌트 2를 참고해 함수 F와 같은 기능을 하는 F1을 단 한 줄로 구현하라

F1(n) = (n ≤ 2 ? 1 : F(n-1) + F(n-2))
F1(40)

# 2. 자료구조
## 힌트 1 : push!()

x = []
push!(x, 1)

## 힌트 2 : @time
@time F1(40)

# 2-1 기본과제
## push!()는 배열의 가장 마지막 자리에 주어진 원소를 추가하는 기능을 한다. 과제 1에서 구현한 
## F혹은 F1을 사용해서 자연수 n을 받아 F_k, k=1 ~ n을 반환하는 함수 FA(n)을 작성하라

f = []
function FA(n)
    for i in 1:n
        push!(f, F(i))
    end
    return f
end
    
FA(10)

# 2-2 심화과제
## 동적 프로그래밍이란, 특정 범위까지의 값을 구하기 위해서 그것과 다른 범위까지의 값을 이용하여 효율적으로 값을 구하는 알고리즘 설계 기법이다.
## FA(n)과 기능이 같지만 동적 프로그래밍을 응용하여 속도를 개선시킨 FA2(n)를 구현하고, 힌트 2에 따라 FA(n)과 FA2(n)의 성능을 비교하라.


function FA2(n)
    f = [1, 1]
    for i in 3:n
        push!(f, f[i-2] + f[i-1])
    end
    return f
end
FA2(10)

# 시간 비교
@time FA(40)
@time FA2(40) # 압도적인 수행시간 차이를 알 수 있다


# 최적화
## 힌트 1 : randn(), rand()
## 힌트 2 : 브로드캐스팅
z = randn(10)
z = rand(10)
z .^ 2
abs.(z) 

## 힌트 3 : 행렬연산
y = [7; 6; 7]
X = [6 8; 9 4; 3 10]
W = rand(2)
b = randn(3)
(X * W) + b

# 3-1 기본과제
## 힌트 3의 W, b를 찾는 것은 손실함수 L(W, b) = |y - (XW+b)|의 함숫값이 0이 되게끔 하는 것과 같다.
## 이 함수 L(W, b)를 줄리아 코드로 정의하라

function L(W = rand(2), b = randn(3))
    y = [7; 6; 7]
    X = [6 8; 9 4; 3 10]
    return abs.(y .- (X * W) + b)
end
L(W, b)

# 3-2 추가과제
## L(W,b) 가 1보다 작아질 때까지 W = rand(2)과 b = randn(3)으로 난수추출을 반복해서 최적해 W0 와 b0 를 얻고,
## 최적화가 얼마나 빠르게 진행되는지 기록해서 확인하라. W와 b 는 더 낮은 값을 얻지 못했을 경우 업데이트 하지 않는다.
## 예를 들어, 최적화에 성공한 케이스 중 하나는 다음과 같다. L_은 손실함수값을 기록한 배열, W0, b0는 최적해다.

L_ = []
while true
    W = rand(2)
    b = randn(3)
    push!(L_, L(W, b))
    if L_[end] < 1
        W0 = W
        b0 = b
        break
    end
end



# 4. 일급객체
## 컴퓨터 프로그래밍 언어 디자인에서 일급 객체란 다른 객체들에 일반적으로 적용 가능한 연산을 모두 지원하는 객체를 가리킨다.
## 보통 함수에 매개변수로 넘기기, 수정하기, 변수에 대입하기와 같은 연산을 지원할 때 일급 객체라고 한다.

# 힌트 1 : 수렴성

n = 1
while true
    if (1 / F(n)) < 0.001
        break
    else 
        n += 1
    end
end


n

# 힌트 2 : 범함수
## 줄리아에서는 함수가 일급객체다. 다시 말해, 함수 자체가 인풋이나 아웃풋이 될 수도 있다. 가령 함수의 덧셈 h = f + g는 다음과 같이 구현할 수 있다.

h(f, g, x) = f(x) + g(x)
h(sin, cos, π/4)

# 4-1 기본과제
## ϵ = 10^-3 이하의 오차를 허용한다. 미분가능한 함수 f: R → R 의 미분계수를 구하는 함수 D(f, x)를 구현하라

function D(f, x)
    ϵ = 10^(-3)
    h(x) = f(x + ϵ) - f(x)
    return h(x) / ϵ
end
D(sin, π/4)

# 4-2 추가과제
## 위 기본과제에서의 적분값을 구하는 함수를 구현하라
using Pkg
Pkg.add("QuadGK")
using QuadGK
function I(f, a, b)
    return quadgk(f, a, b, rtol = 10^-3)    
end

I(sin, 0, 10)


# 5. 소인수분해
## 힌트 1 : 나눗셈
7 ÷ 2
7 / 2
7 % 2

[[2, 3, 5] ; [7, 11]]
[[2 3 5] , [7 11]]

## 힌트 2 : 튜플
function pm(a, b)
    return (a+b), (a-b)
end

c,d = pm(2,4)
c
d

# 5-1 기본과제
## 자연수 n의 소인수분해를 배열로 리턴한느 함수 factorize를 구현하라

function factorize(n)
    factors = []
    for i in 2:n
        while n % i == 0
            push!(factors, i)
            n = n ÷ i
        end
    end
    return factors
end

factorize(100)