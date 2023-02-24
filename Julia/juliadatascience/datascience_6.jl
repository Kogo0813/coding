# Data Visualization with Makie.jl

# CairoMakie.jl : non-interactive 2D publication-quality vector graphics
# GLMakie.jl : interactive 2D or 3D plotting in windows(also GPU-powered)
# WGLMakie.jl : interactive 2D or 3D plotting in a web browser

using Pkg

Pkg.add("GLMakie")
Pkg.update()

GLMakie.activate!()

Pkg.add("CairoMakie")
using CairoMakie
CairoMakie.activate!()

fig = scatterlines(1:10, 1:10)

fig, ax, pltobj = scatterlines(1:10)
pltobj.attributes
help(lines)

Pkg.add("LaTeXStrings")
using LaTeXStrings
lines(1:10, (1:10).^2; color = :black, linewidth = 2, linestyle = :dash,
    figure = (; figure_padding = 5, resolution = (600, 400), font = "sans",
        backgroundcolor = :grey90, fontsize = 16),
    axis = (; xlabel = "x", ylabel = "x²", xgridstyle = :dash, title = "title",
        ygridstyle = :dash))
current_figure()

lines(1:10, (1:10).^2; color = :black, linewidth = 2, linestyle = :dash,
    figure = (; figure_padding = 5, resolution = (600, 400), font = "sans",
        backgroundcolor = :grey90, fontsize = 16),
    axis = (; xlabel = "x", ylabel = "x²", xgridstyle = :dash, title = "title",
        ygridstyle = :dash))
scatterlines!(1:10, (10:-1:1).^2; label = "Reverse(x)²")
axislegend("legend"; position = :rt)
current_figure()

scatterlines(1:10, (10:-1:1).^2; label = "Reverse(x)²")

set_theme!(; resolution = (600, 400),
    backgroundcolor = (:yellow, 0.5), fontsize = 16, font = "sans",
    Axis = (backgroundcolor = :grey90, xgridstyle = :dash, ygridstyle = :dash),
    Legend = (bgcolor = (:red, 0.2), framecolor = :dodgerblue))
    
lines(1:10, (1:10).^2; color = :black, linewidth = 2, linestyle = :dash,
    figure = (; figure_padding = 5, resolution = (600, 400), font = "sans",
        backgroundcolor = :grey90, fontsize = 16),
    axis = (; xlabel = "x", ylabel = "x²", xgridstyle = :dash, title = "title",
        ygridstyle = :dash))
scatterlines!(1:10, (10:-1:1).^2; label = "Reverse(x)²")
axislegend("legend"; position = :rt)
current_figure()
set_theme!()

using Random: seed!
seed!(28)

xyvals = randn(100, 3)
xyvals[1:5, :]

fig, ax, pltobj = scatter(xyvals[:, 1], xyvals[:, 2]; color = xyvals[:, 3],
    lable = "Bubbles", colormap = :plasma, markersize = 15 * abs.(xyvals[:, 3]),
    figure = (; resolution = (600, 400)), axis = (; aspect = DataAspect()))
limits!(-3, 3, -3, 3)
Legend(fig[1, 2], ax, valign = :top)
Colorbar(fig[1, 2], pltobj, height = Relative(3 / 4))
fig

fig, ax, pltobj = scatter(xyvals[:, 1], xyvals[:, 2], xyvals[:, 3], colormap = :plasma, color = :blue)
fig

using Random: seed!
seed!(123)
y = cumsum(randn(6, 6), dims = 2)

xv = yv = LinRange(-3, 0.5, 20)
matrix = randn(20, 20)
matrix[1:6, 1:6]

function demo_themes(y, xv, yv, matrix)
    fig, _ = series(y; labels = ["$i" for i in 1:6], markersize = 10,
        color = :Set1, figure = (; resolution = (600, 300)),
        axis = (; xlabel = "time (s)", ylabel = "Amplitude", 
            title = "Measurements"))
    hmap = heatmap!(xv, yv, matrix; colormap = :plasma)
    limits!(-3.1, 8.5, -6, 5.1)
    axislegend("legend"; merge = true)
    Colorbar(fig[1, 2], hmap)
    fig
end

with_theme(theme_dark()) do
    demo_themes(y, xv, yv, matrix)
end

with_theme(theme_light()) do
    demo_themes(y, xv, yv, matrix)
end

x, y, z = randn(6), randn(6), randn(6)
fig = Figure(resolution = (600, 400), backgroundcolor = :grey90)
ax = Axis(fig[1, 1], backgroundcolor = :white)
pltobj = scatter!(ax, x, y; color = z, label = "scatters")
lines!(ax, x, 1.1y; label = "line")
Legend(fig[2, 1:2], ax, "labels", orientation = :horizontal)
Colorbar(fig[1, 2], pltobj, label = "colorbar")
