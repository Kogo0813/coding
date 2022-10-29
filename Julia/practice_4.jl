using Pkg
using Graphs

# 구조체 속성을 확인하는 법
G_nm = erdos_renyi(50, 200)
propertynames(G_nm)

G_nm.ne
G_nm.fadjlist


# 네임드 튜플
x = rand(Bool, 5); y = rand(Bool, 5)
z = (; x, y)
typeof(z)
z.x;z[2]


# 컨테이너 내부 원소 타입 체크하는 법
set_primes = Set([2,3,5,7,11,13])
arr_primes = Array([2,3,5,7,11,13])
typeof(set_primes)
eltype(set_primes)
typeof(arr_primes)
eltype(arr_primes)


# 빈 배열 만드는 법
empty = Array{Float64, 2}(undef, 3, 4)
one_and_two = Array{Int64, 2}(undef, 3, 5)
empty = Array{Float64, 1}()
empty = Array{Array{Float64, 1}, 1}()
empty = Float64[]
empty = Array{Float64, 1}[]


# 줄리아는 열우선이다.
ones(3)
ones(3, 2)
A = reshape(range(1,6), (3,2))
for i in 1:6
    println(A[i])
end
ones(3,2,4) # 3x2x4 텐서


# 줄리아에서 특정 값으로 채운 배열 만드는 법
typeof(fill(1, 4))
typeof(ones(4, 1))
fill(false, 2, 3)
fill(3.14, 2, 3, 2)


# 줄리아에서 배열 Flatten 하는 법
A = rand(0:9, 3, 4)
vec(A) # 1차원 행렬이냐 벡터이냐
b = rand(0:9, 10, 1)
vec(b)
c = rand(0:9, 3, 3)
Iterators.flatten(c)
vec(c)


# 배열을 평행이동시키는 방법
A = transpose(reshape(1:25, 5, 5))
circshift(A, (-1, 0))
circshift(A, (0, 3))
circshift(A, (-1, 3))

B = reshape(1:4*4*3, 4, 4, 3)
circshift(B, (-1, 0))


# 배열의 원소들이 어떤 리스트에 속하는지 체크하는법
x = rand('a' : 'c', 10)
x .∈ ['a', 'b']
x .∈ Ref(['a', 'b'])
y = rand('a':'c', 1, 10)
y .∈ ['a', 'b']


# 2차원 배열 연산에 관한 함수들
A = [1 2 1;
    0 3 0;
    2 3 4]
transpose(A)
A' # 실수행렬과 복소수행렬인 경우 전혀 다른 결과
A_complex = [1+im 2 1+im;
    0 3 0+im;
    2 3+im 4]
transpose(A_complex)
A_complex'


# 거듭제곱
A = [1 2 1;
    0 3 0;
    2 3 4]
A^2
A*A


# 원소별 곱셈, 원소별 나눗셈
A = [1 2 1;
    0 3 0;
    2 3 4]
A .* A # 하다마드 곱셈
A ./ A # 하다마드 나눗셈


# 좌우반전, 상하반전
A = [1 2 1;
    0 3 0;
    2 3 4]
reverse(A, dims = 1) # 상하반전
reverse(A, dims = 2) # 좌우반전


# 역행렬
A = [1 2 1;
    0 3 0;
    2 3 4]
inv(A)


# 벡터를 생성하는 여러 가지 방법
x1 = [1 2 3]
x2 = [1, 2, 3]
x3 = [i for i in 1:3]
x4 = [i for i in 1:3:10]
x5 = [i for i in 1:3:11]


# 빈 배열인지 확인하는 방법
isempty([])
isempty(Set())
isempty("")
@time for t in 1:10^6
    isempty([])
end

@time for t in 1:10^6
    length([]) == 0
end


Pkg.add("CategoricalArrays")
using CategoricalArrays
A = ["red", "blue", "red", "green"]
B = categorical(A)
levels(B)
B[2] = "red"; B
levels(B)
@time for t in 1:10^6
    unique(A)
end
@time for t in 1:10^6
    levels(B)
end 
# unique보다 levels로 할 때 40배정도 더 빠름


x = [1 2 3]
y = [1 2 3 4]

x' .+ y 
x .+ y'


# 인덱스를 찾는 함수
x = [3, 7, 4, 5, 10, 3, 12, 3, 2, 4]
argmin(x)
argmax(x)
findmin(x)
findmax(x)
extrema(x)
findfirst(x .== 3)
findlast(x .== 3)
findall(x .== 3)
findnext(x .== 3, 5)
findprev(x .== 3, 5)


# 줄리아의 다차원 인덱스
M = rand(0:9, 4, 4)
pt = (3, 4)
M[pt[1], pt[2]]
pt = CartesianIndex(3, 4)
M[pt]


# 데이터프레임과 2차원 배열간 변환 방법
using DataFrames
data1 = rand(3, 4)
data2 = convert(Array, data1)
DataFrame(data1, :auto)