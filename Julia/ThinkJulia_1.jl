# typeof : 자료형을 파악하는 함수
# 줄리아의 예약어는 변수명으로 사용할 수 없다.

"abc"^3
"abc"*"def"

typeof(nothing)

# 3.14 연습문제
# rightjustify라는 함수를 작성해보세요. 문자열 변수s를 매개변수로 바고, 그 문자열을 화면에 출력하되
# 마지막 글자가 화면의 70번째 컬럼에 위치하도록 앞에 빈칸을 붙여서 출력하는 함수입니다.

function rightjustify(s::String)
    print(" "^70*s)
end

rightjustify("monty")

# 연습 3-4
# printgrid라는 함수를 만들어보세요. 다음과 같은 격자를 출력해야 합니다.
function printgrid()
    println("+ - - - - + - - - - +")
    println("|         |         |")
    println("|         |         |")
    println("|         |         |")
    println("|         |         |")
    println("+ - - - - + - - - - +")
    println("|         |         |")
    println("|         |         |")
    println("|         |         |")
    println("|         |         |")
    println("+ - - - - + - - - - +")
end

printgrid()

function pandan(x)
    if x > 0
        println("x is positive")
    elseif x < 0
        println("x is negative")
    else
        println("x is zero")
    end
end
pandan(-1)


# 2.10 연습문제
# 2-2-1
n = 42
42 = n

# 2-2-2
x = y = 1

# 2-2-3
## 줄리아에서 마지막 문장에 세미콜론을 붙이나 안 붙이나 같은 결과를 낸다.
n = 1
n = 1;

# 2-2-4
## 문장의 마지막에 마침표를 넣으면?
n = "djlf".

# 2-2-5
## 수학에서는 x와 y를 곱할때, x y 처럼 연산자를 생략할수있다. 줄리아에서도 가능한가?
x = 1;y = 2
xy
5x

# 연습 2-3
## 2-3-1
## 반지름이 5인 구의 부피??
(4pi*5^3)/3

## 2-3-2
24.95*0.6*60 + 3 + 0.75*59

## 2-3-3
mile = 8.15
mile2 = 7.12
(mile*2 + mile2*3)

# 3.1
## trunc() 함수는 소수점 이하를 버리는 함수이다.
trunc(Int64, 3.9999)

## parse() 함수는 문자열을 숫자로 변환하는 함수이다.(지정된 타입이 아니라면 오류 반환)
typeof(parse(Int64, "123"))

string(123)

# 연습 3-1
repeatlyrics()
function printlyrics()
    println("I'm a lumberjack, and I'm okay.")
    println("I sleep all night and I work all day.")
end

function repeatlyrics()
    printlyrics()
    printlyrics()
end

sqrt(5)

# 3.14 연습문제
# rightjustify라는 함수를 작성해보세요. 문자열 변수s를 매개변수로 바고, 그 문자열을 화면에 출력하되
# 마지막 글자가 화면의 70번째 컬럼에 위치하도록 앞에 빈칸을 붙여서 출력하는 함수입니다.

function rightjustify(s::String)
    k = length(s)
    println(" "^(70-k), s)
end
rightjustify("monty")

# 연습 3-3

function dotwice(f)
    f()
    f()
end

function printspam()
    println("spam")
end

dotwice(printspam)

## 3-3-2 
## dotwice함수를 두 개의 인수를 받도록 수정. 함수 객체와 값을 받아서 함수를 두 번 호출하되, 전달받은 값은 인수로
## 사용하도록 해야한다.

function dotwice(f, v)
    f(v)
    f(v)
end 

dotwice(println, "spam")

# 연습 3-4
function printgrid()
    for j in 1:2
        println("+", "-" ^ 4, "+", "-" ^ 4, "+")
        for i in 1:4
            println("|", " " ^ 4, "|", " " ^ 4, "|")
        end
    end
    println("+", "-" ^ 4, "+", "-" ^ 4, "+")
end
printgrid()

using Pkg

text = readline()

x = 3; y = 2
@show x y

function addall(t)
    total = 0
    for x in t
        total += x
    end
    total
end
[1; 2 ;3].^3

t = [1, 2, 3]
pop!(t)
splice!(t, 1)
popfirst!(t)
t = [1, 2, 4]
insert!(t, 3, 3)
t = [1 , 2, 3]

words = ["julia", "is", "fun"]
join(words, ' ')