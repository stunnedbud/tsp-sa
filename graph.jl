#using JLD

type Connection
    to_node::Int
    distance::Float64
end

type Node
    id::Int # should coincide with its index on nodes array
    name::AbstractString
    country::AbstractString
    population::Int
    latitude::Float64
    longitude::Float64
    connections::Array{Connection,1}
    degree::Int
end

type Graph
    nodes::Array{Node,1}
end

function populate_graph(cities_file::AbstractString, connections_file::AbstractString)
    net = Graph(Node[])    
    open(cities_file) do f
        lines = readlines(f)
        for l in lines
            print(l)
            words = split(l, "\t")
            words = map(utf8, words)
            node = Node(parse(Int,words[1]), words[2], words[3], parse(Int,words[4]), parse(Float64,words[5]), parse(Float64,words[6]), Connection[], 0)
            push!(net.nodes, node)
        end
    end
    open(connections_file) do f
        lines = readlines(f)
        for l in lines
            print(l)
            words = split(l, "\t")
            words = map(utf8, words)
            from_index = parse(Int, words[1])
            to_index = parse(Int, words[2])
            distance = parse(Float64, words[3])
            push!(net.nodes[from_index].connections, Connection(to_index, distance)) 
            net.nodes[from_index].degree += 1
        end
    end 
    net
end

# Might be useful
function subgraph(graph::Graph, cities::Array{Int,1})
    nodes = Node[]
    for c in cities
        og = graph.nodes[c]
        conns = Connection[]
        for i in og.connections
            if i.to_node in cities
                push!(conns, Connection(i.to_node, i.distance))
            end
        end
        push!(nodes, Node(c, og.name, og.country, og.population, og.latitude, conns, length(conns)))
    end
    Graph(nodes)
end

function shuffle_subgraph(g::Graph, s::Array{Int,1}, seed)
    srand(seed)
    shuffle(MersenneTwister(seed), s)
end

##
# Cost
##
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


cities = [22,74,109,113,117,137,178,180,200,216,272,299,345,447,492,493,498,505,521,572,607,627,642,679,710,717,747,774,786,829,830,839,853,857,893,921,935,986,1032,1073]
seed = 1234567890
punishment_factor = 5.5

g = populate_graph("cities.txt", "connections.txt")

p = calc_punishment(g, punishment_factor)
println(cost(g, cities, p))
