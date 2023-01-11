print("helloworld")


z = randn(10000)
z .+ 2
@time z .^  2


E(X) = sum(X) / length(X)
Var(X) = sum((X .- E(X)).^2)/(length(X)-1)


E(z .^ 2)
Var(z .^ 2)


using Plots
function moving_agent(n)
    location = rand(2, n)
    scatter(location[1, :], location[2, :])

    p = @animate for t = 1:100
        location += 0.2randn(2, n)
        scatter(location[1, :], location[2, :], lims = (-10, 10)) # x,y축 범위 한 번에 지정
    end
    gif(p, fps = 10)
end


moving_agent(10)
moving_agent(100)

## 거리행렬

n = 10
σ = 0.2
location = rand(2, n)
location[:, 1]
location[:, 8]
sum((location[:, 1] .- location[:, 8]).^2)
D = zeros(10, 10)
for i in 1:n
    for j in 1:n
        D[i, j] = sqrt(sum((location[:, i] - location[:, j]).^2))
    end
end
D
D .< σ
sum(D .< σ, dims = 2) # 열별로 합을 벡터로 나타내줌


## 배열

state = ['S' for _ in 1:10]
push!(state, 'I')
push!(state, 'I')
state
n = length(state)


bit_S = state .== 'S'
bit_I = state .== 'I'
n_S = sum(bit_S)
n_I = sum(bit_I)


location = rand(2, n)


D = zeros(n_S, n_I)
for i in 1:n_S
    for j in 1:n_I
        D[i, j] = sqrt(sum((location[:, i] - location[:, j]).^2)) # 유클리드 거리
    end
end
D


using Pkg
Pkg.add("Distances")
using Distances
pairwise(Euclidean(), location[:, bit_S], location[:, bit_I]) # 정상인 사람들과 감염자들간의 유클리드 거리행렬
D = pairwise(Euclidean(), location[:, bit_S], location[:, bit_I])
contact = sum(D .< σ, dims = 2) # 정상인 사람들이 감염자들과 접촉한 횟수

# D : 행이 정상인 사람들의 데이터, 열이 감염자들과의 거리
# D .< σ : 행이 정상인 사람들의 데이터, 열이 감염자들과의 거리가 σ보다 작은지 여부


## 확률계산

β = 0.5

1 .- (1-β) .^ sum(contact, dims = 2) # 감염자가 되는 확률
infected = 1 .- (1-β) .^ sum(contact, dims = 2) .< rand(n_S)
rand(n_S)

state[((1:n)[bit_S])[vec(infected)]] .= 'I'
state


## SIR

function SIR(n)
    β = 0.3
    σ = 0.1
    μ = 0.1

    S_ = []
    I_ = []
    R_ = []
    t = 0

    ID = 1:n
    state = ['S' for _ in 1:n]
    state[1] = 'I'
    location = rand(2, n)

    while sum(state .== 'I') > 0
        t = t+1
        location += randn(2, n)
        bit_S = state .== 'S'; n_S = sum(bit_S); ID_S = ID[bit_S]; push!(S_, n_S)
        bit_I = state .== 'I'; n_I = sum(bit_I); ID_I = ID[bit_I]; push!(I_, n_I)
        bit_R = state .== 'R'; n_R = sum(bit_R); ID_R = ID[bit_R]; push!(R_, n_R)

        D = pairwise(Euclidean(), location[:, bit_S], location[:, bit_I])
        contact = sum(D .< σ, dims = 2)
        infected = rand(n_S) .< (1 .- (1-β) .^ contact) # contact가 정수이므로 앞으 확률에 제곱을 해야함

        state[ID_S[infected, :]] .= 'I'
        state[ID_I[rand(n_I) .< μ]] .= 'R'
    end
    return S_, I_, R_
end
    
@time S, I, R = SIR(5*10^4)
t_end = length(S)
p = @animate for t in 1:t_end
    plot(S[1:t], xlims = (1, t_end), label = 'S')
    plot!(I[1:t], xlims = (1, t_end), label = 'I')
    plot!(R[1:t], xlims = (1, t_end), label = 'R')
end
gif(p)


## 최적화

Pkg.add("NearestNeighbors")
using NearestNeighbors
KDtree_I = KDTree(location[:, bit_I])
inrange(KDtree_I, location[:, bit_S], σ) # 정상인과 감염자의 거리가 σ보다 작은 걸 골라냄 
D .< σ


function SIR2(n)
    β = 0.3
    σ = 0.1
    μ = 0.1

    S_ = []
    I_ = []
    R_ = []
    t = 0

    ID = 1:n
    state = ['S' for _ in 1:n]
    state[1] = 'I'
    location = rand(2, n)

    while sum(state .== 'I') > 0
        t += 1
        location += randn(2, n)
        bit_S = state .== 'S'; n_S = sum(bit_S); ID_S = ID[bit_S]; push!(S_, n_S)
        bit_I = state .== 'I'; n_I = sum(bit_I); ID_I = ID[bit_I]; push!(I_, n_I)
        bit_R = state .== 'R'; n_R = sum(bit_R); ID_R = ID[bit_R]; push!(R_, n_R)

        KDtree_I = KDTree(location[:, bit_I])
        contact = length.(inrange(KDtree_I, location[:, bit_S], σ))
        infected = rand(n_S) .< (1 .- (1-β).^ contact)

        state[ID_S[infected, :]] .= 'I'
        state[ID_I[rand(n_I) .< μ]] .= 'R'
    end
    return S_, I_, R_
end


S, I, R = SIR2(5*10^4)

@time SIR2(5*10^4)
@time SIR(5*10^4)