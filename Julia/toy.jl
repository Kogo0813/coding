using Pkg
Pkg.add("HypothesisTests")
using HypothesisTests

group_a = [1, 2, 3, 4, 5];
group_b = [6, 1, 2, 9, 0.1];

# 등분산 검정
EqualVarianceTTest(group_a, group_b)

using Random

using Random

# 목표 분포
function target_distribution(x)
    return exp(-x^2 / 2)  # 예시로 가우시안 분포 사용
end
k = 0
# 확률보행 메트로폴리스 알고리즘
function metropolis_hastings(target, num_samples, initial_value, proposal_stddev, k=0::Int64)
    chain = Float64[]
    x = initial_value
    push!(chain, x)
    rng = Random.GLOBAL_RNG
    

    for i in 2:num_samples
        # 현재 위치에서 샘플 제안
        x_proposed = x + randn(rng) * proposal_stddev

        # 샘플 제안의 목표 분포 값 계산
        p_proposed = target(x_proposed)

        # 현재 위치의 목표 분포 값 계산
        p_current = target(x)

        # 승인 확률 계산
        acceptance_prob = min(1.0, p_proposed / p_current)

        # 승인 여부 결정
        if rand(rng) < acceptance_prob
            x = x_proposed  # 제안된 샘플 승인
        else
            x = x
            k = k + 1
        end
        push!(chain, x)
    end

    return chain
end

# 메인 코드
num_samples = 10000
initial_value = 0.0
proposal_stddev = 0.5

chain = metropolis_hastings(target_distribution, num_samples, initial_value, proposal_stddev)

# 결과 출력
using Statistics
println("Mean: ", mean(chain))
println("Standard Deviation: ", std(chain))

using Plots
plot(chain, legend=false, title="Metropolis-Hastings", ylabel="x", xlabel="iteration", color=:black, lw=0.5, alpha=0.5)






