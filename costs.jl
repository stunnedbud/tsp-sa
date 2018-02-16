#module costs
#export weight_average, calc_punishment, augmented_weight, cost

include("graphs.jl")
#using graphs

function weight_average(g::Graph, s::Array{Int,1})
    weights = Float64[]
    for n in s
        for c in g.nodes[n].connections
            push!(weights, c.distance)
        end
    end
    sum(weights) / length(weights)
end

function calc_punishment(g::Graph, punishment_factor::Float64)
    max = 0.0
    for n in g.nodes
        for c in n.connections
            if c.distance > max
                max = c.distance
            end
        end
    end
    max*punishment_factor
end

function augmented_weight(g::Graph, u::Int, v::Int, punishment::Float64)
    
    distance = -1
    for c in g.nodes[u].connections
        if c.to_node == v
            distance = c.distance
            break
        end
    end       
    if distance != -1
        return distance
    else
        return punishment
    end
end

function cost(g::Graph, s::Array{Int, 1}, punishment::Float64)
    ws = 0.0
    for i in 2:length(s)
        ws += augmented_weight(g, i-1, i, punishment)
    end
    ws / weight_average(g,s)
end

#end #end of module

