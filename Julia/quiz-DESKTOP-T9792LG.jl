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
## 힌트 1을 참고해 주어진 자연수 n에 대해 n번째 피보나치 수를 반환하는 함수 F(n)을 작성하라. 단 F1 = F2 = 1이다.

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

f = []
f[1] = 1
f[2] = 1
function FA2(n)
    f = [1,1]
    for i in 3:n
        push!(f, f[i-1] + f[i-2])
    end
    return f
end
FA2(10)

@time FA(10)
@time FA2(10)