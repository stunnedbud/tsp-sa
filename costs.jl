include("graphs.jl")

function euclidean_distance(g::Graph, u::Int, v::Int)
    x = [g.nodes[u].latitude, g.nodes[u].longitude]
    y = [g.nodes[v].latitude, g.nodes[v].longitude]
    sqrt( (x[1]^2 - y[1])^2 + (x[2]^2 - y[2])^2 )
end

function weight_average(g::Graph, s::Array{Int,1})
    weights = Float64[]
    for i in s
        for j in s
            if j <= i
                continue
            end
            c = g.distances[i,j]
            if c != -1
                push!(weights,c)
            end
        end
    end
    
    println(sum(weights) / length(weights))
    sum(weights) / length(weights)
end

function calc_punishment(g::Graph, s::Array{Int, 1}, punishment_factor::Float64)
    m = -1
    for i in s
        for j in s
            c = g.distances[i,j]
            m = max(m,c)
        end
    end
    m*punishment_factor
end

function augmented_weight(g::Graph, u::Int, v::Int, punishment::Float64)
    g.distances[u,v] == -1 ? punishment : g.distances[u,v]
    #g.distances[u,v] == -1 ? euclidean_distance(g,u,v) : g.distances[u,v] 
end

function cost(g::Graph, s::Array{Int, 1}, punishment::Float64, average::Float64)
    ws = 0.0
    for i in 2:length(s)
        ws += augmented_weight(g, s[i-1], s[i], punishment)
    end
    ws / (average*(length(s)-1))
end
