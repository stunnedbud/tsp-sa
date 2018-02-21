include("graphs.jl")

function weight_average(g::Graph, s::Array{Int,1})
    weights = Float64[]
    for i in s
        for c in g.distances[i]
            push!(weights, c)
        end
    end
    sum(weights) / length(weights)
end

function calc_punishment(g::Graph, punishment_factor::Float64)
    maximum(g.distances)*punishment_factor
end

function euclidean_distance(g::Graph, u::Int, v::Int)
    x = [g.nodes[u].latitude, g.nodes[u].longitude]
    y = [g.nodes[v].latitude, g.nodes[v].longitude]
    sqrt( (x[1]^2 - y[1])^2 + (x[2]^2 - y[2])^2 )
end

function augmented_weight(g::Graph, u::Int, v::Int, punishment::Float64)
    g.distances[u,v] == -1 ? punishment : g.distances[u,v]
end

function cost(g::Graph, s::Array{Int, 1}, punishment::Float64)
    ws = 0.0
    roads_num = 0
    roads = AbstractString[]
    for i in 2:length(s)
        if g.distances[i-1,i] != -1
            roads_num += 1
            push!(roads, "("*string(s[i-1])*","*string(s[i])*")")
        end
        ws += augmented_weight(g, s[i-1], s[i], punishment)
        #ws += augmented_weight(g, i-1, i, euclidean_distance(g, i-1, i))
    end
    #print("S: ")
    #println(s)
    #print("ROADS: ")
    #print(roads_num)
    #println(roads)
    ws / ( weight_average(g,s)*(length(s)-1))
end

