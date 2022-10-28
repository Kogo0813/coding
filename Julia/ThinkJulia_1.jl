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


