z = randn(10_000)
z .+ 2

using Statistics
mean(z .^ 2)
E(X) = mean(X .^ 2)
Var(X) = var(X .^ 2)

using Plots


function moving_agent(n)
    location = rand(2, n)
    scatter(location[1, :], location[2, :], lims = (-10, 10))

    p = @animate for t = 1:100
        location .+= randn(2, n)
        scatter(location[1, :], location[2, :], lims = (-10, 10), label = "person", legend = :topright)
        
    end
    gif(p, fps = 10)
end

moving_agent(100)

n = 10
σ = 0.2
location = rand(2, n)
@time sum((location[:, 1] .- location[:, 2]) .^ 2)
@time sum((location[:, 1] - location[:, 2]) .^ 2)

D = zeros(10, 10)
for i = 1:n
    for j in 1:n # 열이 사람, 행이 각각 X, Y 좌표라고 생각하면 됨
        D[i, j] = sqrt(sum((location[:, i] - location[:, j]).^2)) # 사람별 거리
    end
end

D .< σ
sum(D .< σ, dims = 2) # 2차원 배열에서 2번째 차원을 기준으로 합을 구함(오른쪽 합)

mat = [1 2 3; 5 6 7]
sum(mat, dims = 2)

state = ['S' for _ in 1:10]
push!(state, 'I')
push!(state, 'I')
n = length(state)

bit_S = state .== 'S'
bit_I = state .== 'I'
n_S = sum(bit_S)
n_I = sum(bit_I)

location = rand(2, n)
for i in 1:n_S
    for j in 1:n_I
        D[i, j] = sqrt(sum((location[:, i] - location[:, 10 + j]).^2))
    end
end

D

using Distances
pairwise(Euclidean(), location[:, bit_S], location[:, bit_I])

D = pairwise(Euclidean(), location[:, bit_S], location[:, bit_I])
contact = sum(D .< σ, dims = 2)

β = 0.5

1 .- (1-β) .^ sum(contact, dims = 2)
infected = rand(n_S) .> 1 .- (1-β) .^ sum(contact, dims = 2)

state[((1:n)[bit_S])[vec(infected)]] .= 'I'
state

