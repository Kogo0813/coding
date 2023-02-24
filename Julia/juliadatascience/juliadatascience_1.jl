function grades_array()
    name = ["Bob", "Sally", "Alice", "Hank"]
    age = [17, 18, 20, 19]
    grade_2020 = [5.0, 1.0, 8.5, 4.0]
    (; name, age, grade_2020)
end

grades_array()

using DataFrames
names = ["Sally", "Bob", "Alice", "Hank"]
grades = [1, 5, 8.5, 4]

df = DataFrame(; names=names, grade_2020 = grades)

# 2.3.3 Multiple Dispatch
abstract type Animal end
struct Fox <: Animal
    weight :: Float64
end

struct Chicken <: Animal
    weight :: Float64
end


# 구조체(struct) : 새로운 형식의 타입을 지정하는 것
fiona = Fox(4.2)
big_bird = Chicken(2.9)
combined_weight(A1 :: Animal, A2 :: Animal) = A1.weight + A2.weight
combined_weight(fiona, big_bird)


function naive_trouble(A :: Animal, B :: Animal)
    if A isa Fox && B isa Chicken
        return true
    elseif A isa Chicken && B isa Fox
        return true
    elseif A isa Chicken && B isa Chicken
        return false
    end
end
naive_trouble(fiona, big_bird)


first(methodswith(Int64), 5)


# 3.2.2 사용자 정의 type
struct Language
    name :: String
    title :: String
    year_of_birth :: Int64
    fast :: Bool
end
fieldnames(Language)
julia = Language("Julia", "Rapidus", 2012, true)
typeof(julia)
julia.title = "Python"

# 변경가능한 struct , 일반적으로 만들어지는 구조체들은 변경불가능함
mutable struct MutableLanguage
    name :: String
    title :: String
    year_of_birth :: Int64
    fast :: Bool
end
julia_mutable = MutableLanguage("Julia", "Rapidus", 2012, true)
julia_mutable.title = "Python Obliteratus"


# 3.2.3 Boolean operators and numeric comparisons
!true 
(false && true) || (!false)
1 == 1
1 == 1.0
(1 != 10) || (3.14 <= 2.71) # true or false 이므로 true 반환


# 3.2.4 Functions
function function_name(arg1, arg2)
    result = stuff with the arg1 and arg2
    return result
end

function add_numbers(x, y)
    return x + y
end


add_numbers(17, 29)
add_numbers(38, 10.9)


function round_number(x::Float64)
    return round(x)
end


function round_number(x::Int64)
    return x
end


methods(round_number)
round_number(1)


# float64가 아닌 float32가 들어가야 하는 경우는 ??
function round_number(x::AbstractFloat)
    return round(x)
end
x_32 = Float32(1.1)
round_number(x_32)


Base.show(io::IO, l::Language) = print(
    io, l.name, ", ",
    2021 - l.year_of_birth, " years old, ",
    "has the following titles:", l.title
)
julia


Real <: Number
function logarithm(x::Real; base::Real=2.7182818284590)
    return log(base, x)
end

logarithm(10)
logarithm(10; base=2)
