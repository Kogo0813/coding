# 3.3 dot product
first(methodswith(String), 5)

[1, 2, 3] .+ 1
logarithm.([1, 2, 3])
log.([1, 2, 3])

# 3.3.2 bang! function
function add_one!(V)
    for i in eachindex(V)
        V[i] += 1
    end
    return nothing
end
my_data = [1, 2, 3]
add_one!(my_data)
my_data

# 3.3.3 String
typeof("This is a string")

hello = "Hello"
goodbye = "Goodbye"
join([hello, goodbye], " ")

"$hello $goodbye"

function test_interpolated(a, b)
    if a < b
        "$a is less than $b"
    elseif a > b
        "$a is greater than $b"
    else
        "$a is equal to $b"
    end
end

julia_string = "Julia is an amazing open source programming language"

contains(julia_string, "Julia")
startswith(julia_string, "Julia")
endswith(julia_string, "Julia")
lowercase(julia_string)
uppercase(julia_string)
titlecase(julia_string)
lowercasefirst(julia_string)
replace(julia_string, "amazing" => "awesome")
split(julia_string, " ")

# parse() : 자료형 변경
typeof(parse(Int64, "123"))
tryparse(Int64, "A very non-numeric string")
# tryparse() : 자료형 변경 실패시 nothing 반환, error를 피할 수 있음

# 3.3.4 Tuple
my_tuple = (1, 3.14, "Julia")
my_tuple[2]

map((x, y) -> x^y, 2, 3)
map((x, y, z) -> x^y, 2, 3, 1)

# 3.3.5 Named Tuple
named_tuple = (i = 1, f = 3.14, s = "Julia")
named_tuple

# 3.3.6 Ranges
1:10
typeof(1:10)
[x for x in 1:10] # list comprehension
typeof(collect(1:10))

# 3.3.7 Array
myarray = [1, 2, 3]
myarray = ["text", 1, :symbol]
typeof(myarray)

my_vector = Vector{Float64}(undef, 10)
my_matrix = Matrix{Float64}(undef, 10, 2)
typeof(zeros(10, 2))
typeof(zeros(Int64, 10, 2))

my_matrix
fill!(my_matrix, 3.14)
[ones(Int, 2, 2) zeros(Int, 2, 2)]

[zeros(Int, 2, 2)
ones(Int, 2, 2)]
[x^2 for x in 1:10 if isodd(x)]
cat(ones(2), zeros(2), dims = 1)
vcat(ones(2), zeros(2))
hcat(ones(2), zeros(2))

eltype(my_matrix)
typeof(my_matrix)
length(my_matrix)
size(my_matrix)

v = [1, 2, 3, 4, 5]
v[end - 1]
v[begin]

six_vector = [1, 2, 3, 4, 5, 6]
three_two_matrix = reshape(six_vector, (3, 2))
reshape(six_vector, (6, ))

map(log10, my_matrix)
map(x -> 3x, my_matrix)
(x -> 3x).(my_matrix)

mapslices(sum, my_matrix, dims = 2)
my_matrix

simple_vector = [1, 2, 3]
empty_vector = Int64[]

for i in simple_vector
    push!(empty_vector, i + 1)
end
empty_vector

forty_twos = [42, 42, 42]
empty_vector = Int64[]

for i in eachindex(forty_twos)
    push!(empty_vector, i)
end
empty_vector

mat = [[1 2]
        [3 4]]
for i in eachrow(mat)
    println(i)
end

# 3.3.8 Pair
my_pair = "Julia" => 42
my_pair.first
my_pair.second

# 3.3.9 Dict
name2number_map = Dict([("one", 1), ("two", 2)])
name2number_map = Dict("one" => 1, "two" => 2)

name2number_map["three"] = 3
"two" in keys(name2number_map)

delete!(name2number_map, "three")
popped_value = pop!(name2number_map, "two")
A = ["one", "two", "three"]
B = [1, 2, 3]

name2number_map = Dict(zip(A, B))

# 3.3.10 symbol
sym = :some_text
s = string(sym)
sym = Symbol(s)

# 3.3.11 Splat Operator
add_elements(a, b, c) = a + b + c
my_collection = [1, 2, 3]
add_elements(my_collection...)
add_elements(1:3...)

root = dirname(@__FILE__)
joinpath(root, "data", "my_data.csv")

# 3.5 Julia Standard Library
using Pkg
using Dates

Date(1987)
Date(1987, 9)
DateTime(1987, 9, 1, 12, 30, 45)
subtypes(Period)
subtypes(DatePeriod)

Date("19870913", "yyyymmdd")

format = DateFormat("yyyymmdd")
Date("19870913", format)

birthday = Date("1987-09-13")
year(birthday)
month(birthday)

yearmonthday(birthday)

dayofweek(birthday)
dayname(birthday)

# Date Operations
birthday + Day(90)
birthday + Day(90) + Month(2) + Year(1)

date_interval = Date("2021-01-01"):Day(1):Date("2021-01-07")
collect(date_interval)

# 3.5.2 Random Numbers
using Random: seed!
rand()
rand(1.0:10.0)
rand(2:2:20)
rand((42, "Julia", 3.14))
randn((2,2))

my_seed = seed!(123)
rand(3)
rand(my_seed, 3)