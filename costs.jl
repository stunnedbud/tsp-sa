include("graphs.jl")

### Cost related functions.

# Returns euclidean distance between two cities in the graph. Unused, didn't work.
function euclidean_distance(g::Graph, u::Int, v::Int)
    x = [g.nodes[u].latitude, g.nodes[u].longitude]
    y = [g.nodes[v].latitude, g.nodes[v].longitude]
    sqrt( (x[1]^2 - y[1])^2 + (x[2]^2 - y[2])^2 )
end

# Averages weights of all connections in the subset s.
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
    
    sum(weights) / length(weights)
end

# Returns the maximum distance in subset s multiplied by the punishment factor.
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

# Returns the weight between two nodes. If they aren't connected it returns the punishment.
function augmented_weight(g::Graph, u::Int, v::Int, punishment::Float64)
    g.distances[u,v] == -1 ? punishment : g.distances[u,v]
    #g.distances[u,v] == -1 ? euclidean_distance(g,u,v) : g.distances[u,v] 
end

# Returns cost of solution s, which is the sum of weights (or punishments) it traverses, normalized.
function cost(g::Graph, s::Array{Int, 1}, punishment::Float64, average::Float64)
    w = 0.0
    for i in 2:length(s)
        w += augmented_weight(g, s[i-1], s[i], punishment)
    end
    w / (average*(length(s)-1))
end

# Since we only swap two indexes (at most) between neighbors, we need not recalculate the entire cost.
# This function calculates cost of a neighbor solution, given the original subset s, its cost, and the 
#swapped nodes u and v.
# Use carefully, the result isn't precisely what cost returns (but close enough).
function cost_fast(g::Graph, s::Array{Int,1}, pun::Float64, avg::Float64, u::Int, v::Int, c::Float64)
    w = c * (avg * (length(s)-1))
    
    if u > 1
        w -= augmented_weight(g, s[u-1], s[u], pun) 
        w += augmented_weight(g, s[u-1], s[v], pun)
    end    
    if u < length(s)
        w -= augmented_weight(g, s[u], s[u+1], pun)
        w += augmented_weight(g, s[v], s[u+1], pun)
    end
    if v > 1
        w -= augmented_weight(g, s[v-1], s[v], pun)
        w += augmented_weight(g, s[v-1], s[u], pun)
    end
    if v < length(s)
        w -= augmented_weight(g, s[v], s[v+1], pun)
        w += augmented_weight(g, s[u], s[v+1], pun)
    end
    w / (avg*(length(s)-1)) 
end
