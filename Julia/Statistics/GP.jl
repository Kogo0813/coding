using Pkg
#= Pkg.add("Distributions")
Pkg.add("Turing")
Pkg.add("GLM")
Pkg.add("MixedModels") =#

using Turing, StatsPlots, Random

# 동전이 앞면이 나올 실제 확률
p_true = 0.5
Ns = 0:100

Random.seed!(12)
data = rand(Bernoulli(p_true), last(Ns))

# declare out Turing model
@model function coinflip(y)
    # prior belief about the prob of heads in a coin
    p ~ Beta(1, 1)

    # The number of observations
    N = length(y)
    for n in 1:N
        y[n] ~ Bernoulli(p)
    end
end

iterationn = 1000
ϵ = 0.05
τ = 10

# start sampling
chain = sample(coinflip(data), HMC(ϵ, τ), iterationn)
@time histogram(chain[:p])
println(mean(chain[:p]))

plot(chain)

# ======================================================
@model function gdemo(x, y)
    s² ~ InverseGamma(2, 3)
    m ~ Normal(0, sqrt(s²))
    x ~ Normal(m, sqrt(s²))
    return y ~ Normal(m, sqrt(s²))
end

chn = sample(gdemo(1.5, 2.0), NUTS(), 1000) # NUTS sampling
plot(chn)

s² = InverseGamma(2, 3)
m = Normal(0, 1)
data = [1.5, 2]
x_bar = mean(data)
N = length(data)

mean_exp = (m.σ * m.μ + N * x_bar) / (m.σ + N)

updated_alpha = shape(s²) + (N / 2)
updated_beta =
    scale(s²) +
    (1 / 2) * sum((data[n] - x_bar)^2 for n in 1:N) +
    (N * m.σ) / (N + m.σ) * ((x_bar)^2) / 2
variance_exp = updated_beta / (updated_alpha - 1)
function sample_posterior(alpha, beta, mean, lambda, iterations)
    samples = []
    for i in 1:iterations
        sample_variance = rand(InverseGamma(alpha, beta), 1)
        sample_x = rand(Normal(mean, sqrt(sample_variance[1]) / lambda), 1)
        sanples = append!(samples, sample_x)
    end
    return samples
end

analytical_samples = sample_posterior(updated_alpha, updated_beta, mean_exp, 2, 1000);
density(analytical_samples; label="Posterior (Analytical)")
density!(chn[:m]; label="Posterior (HMC)")