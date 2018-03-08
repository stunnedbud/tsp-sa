include("graphs.jl")

function weight_average(g::Graph, s::Array{Int,1})
    weights = Float64[]
    for i in s
        for c in g.distances[i]
            if c != -1
                push!(weights, c)
            end
        end
    end
    print("PROMEDIO ")
    println(sum(weights) / length(weights))
    sum(weights) / length(weights)
end

function calc_punishment(g::Graph, punishment_factor::Float64)
    print("MAXIMUM ")
    println(maximum(g.distances))
    maximum(g.distances)*punishment_factor
end

function augmented_weight(g::Graph, u::Int, v::Int, punishment::Float64)
    g.distances[u,v] == -1 ? punishment : g.distances[u,v]
end

function cost(g::Graph, s::Array{Int, 1}, punishment::Float64)
    ws = 0.0
    for i in 2:length(s)
        ws += augmented_weight(g, s[i-1], s[i], punishment)
    end
    ws / ( weight_average(g,s)*(length(s)-1))
end
