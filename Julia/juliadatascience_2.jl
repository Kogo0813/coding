using Pkg

# 줄리아에서 문자열 합치기
hello = "hello "
world = "world"
hello*world

join([hello, world], "")
"$hello$world"

julia_string = "Julia is best language"
contains(julia_string, "si")
startswith(julia_string, "Julia")
endswith(julia_string, "language")
lowercase(julia_string)
uppercase(julia_string)
titlecase(julia_string)
lowercasefirst(julia_string) # 첫글자만 소문자로


# 문자열에서 문자열 변환
replace(julia_string, "Julia" => "R")
split(julia_string, "")


# 3.3.4 Tuple
# A tuple is a fixed_length container that can hold multiple different types.
# A tuple is immutable, meaning that it cannot be changed once created.
mytup = (1, 3.14, "Julia")
typeof(mytup)
mytup[1]
map((x, y) -> x ^ y, 2, 3)


# 3.3.5 Named Tuple
namedtuple = (i = 1, f = 3.14, s = "Julia")
namedtuple.fixed_length


1:6
typeof(1:6)
[x for x in 1:10]
collect(1:10)


my_vector = Vector{Float64}(undef, 10)
my_matrix = Matrix{Float64}(undef, 10, 2)
my_vector_zeros = zeros(10)
my_matrix_zeros = zeros(Int64, 10, 2)
ones(3,4)


# cat : concatenate imput arrays along a specific dimension
cat(ones(2), zeros(2), dims = 1)
vcat(ones(2), zeros(2))
hcat(ones(2), zeros(2))