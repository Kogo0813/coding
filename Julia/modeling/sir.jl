using Pkg
Pkg.add("DifferentialEquations")

using DifferentialEquations

# SIR모델 정의
function sir!(du, u, p, t)
    S, I, R = u
    β, γ = p

    dS = -β * S * I
    dI = β * S * I - γ * I
    dR = γ * I

    du[1] = dS
    du[2] = dI
    du[3] = dR
end

# initial condition
u0 = [99.0, 1.0, 0.0]
β = 0.01
γ = 0.3
p = [β, γ]

# 시간 범위 설정
tspan = (0.0, 20.0)

# problem
prob = ODEProblem(sir!, u0, tspan, p)

# solver
sol = solve(prob, Tsit5())

# plot
using Plots
plot(sol, xlabel="Time", ylabel="Population", label=["S" "I" "R"])

pwd()
using GeoDataFrames; const GDF=GeoDataFrames
using DataFrames
using GDAL

cd(@__DIR__)
path = "ctp_rvn.shp"
table = Shapefile.Table(path)

df = DataFrame(table)
df.plot(column = :CTP_KOR_NM, legend = true)

using Random


# Define the agent type
struct Agent
    x::Int
    y::Int
end

# Define the environment type
struct Environment
    width::Int
    height::Int
    agents::Vector{Agent}
end

# Define the rules for agent movement
function move_agent!(agent::Agent, env::Environment)
    dx, dy = rand((-1, 0, 1), 2)
    new_x = agent.x + dx
    new_y = agent.y + dy
    if 1 <= new_x <= env.width && 1 <= new_y <= env.height
        agent.x = new_x
        agent.y = new_y
    end
end

# Define the simulation loop
function run_simulation(env::Environment, num_steps::Int)
    for i in 1:num_steps
        for agent in env.agents
            move_agent!(agent, env)
        end
    end
end

# Create an environment with 10 agents in a 20x20 grid
agents = [Agent(rand(1:20), rand(1:20)) for i in 1:10]
env = Environment(20, 20, agents)

# Run the simulation for 100 steps
run_simulation(env, 100)