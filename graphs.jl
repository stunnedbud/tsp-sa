#module graphs
#export Connection, Node, Graph, populate_graph, shuffle_subgraph, subgraph, swap, neighbor

# Basic graph types declarations and functions
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

function shuffle_subgraph(s::Array{Int,1}, seed)
    srand(seed)
    shuffle(MersenneTwister(seed), s)
end

# Swaps in place two indexes of a list. Returns g just in case
function swap(s::Array{Int,1}, u::Int, v::Int)
    #n = copy(g.nodes[u])
    r = copy(s)
    n = r[u]
    r[u] = r[v]
    r[v] = n
    return r
end

# Calculates a neighbor of the solution. We define a neighbor in TSP as a random permutation of 
function neighbor(s::Array{Int,1}, seed::Int)
    srand(seed)
    #println(seed)
    #println(convert( Int, floor(10000rand()%(length(s)+1)) ) )
    u = convert( Int, floor(10000rand()%length(s))+1 )
    if u == length(s)
        v = u-1
    else
        v = u+1
    end
    swap(s, u, v)
end

# Checks if an edge exists on graph g between every pair of consecutive nodes in solution s
function valid_path(g::Graph, s::Array{Int,1})
    for i in 2:length(s)
        u = g.nodes[i-1]
        v = g.nodes[i]
        if !(v.id in [c.to_node for c in u.connections])
            return false
        end
    end
    return true
end
