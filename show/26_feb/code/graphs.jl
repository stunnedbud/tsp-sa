# Basic graph types declarations and functions
type Node
    id::Int # should coincide with its index on nodes array
    name::AbstractString
    country::AbstractString
    population::Int
    latitude::Float64
    longitude::Float64
    degree::Int
end

type Graph
    nodes::Array{Node,1}
    distances::Array{Float64,2}
end

# Should've used sqlite from the start
# Reads .txts generated from mysql tables
function populate_graph(cities_file::AbstractString, connections_file::AbstractString)
    nodes = Node[]    
    open(cities_file) do f
        lines = readlines(f)
        for l in lines
            words = split(l, "\t")
            words = map(utf8, words)
            node = Node(parse(Int,words[1]), words[2], words[3], parse(Int,words[4]), parse(Float64,words[5]), parse(Float64,words[6]), 0)
            push!(nodes, node)
        end
    end
    distances = fill(-1.0, (length(nodes), length(nodes)))
    open(connections_file) do f
        lines = readlines(f)
        for l in lines
            words = split(l, "\t")
            words = map(utf8, words)
            from_index = parse(Int, words[1])
            to_index = parse(Int, words[2])
            distance = parse(Float64, words[3])
            distances[from_index, to_index] = distance 
            distances[to_index, from_index] = distance
        end
    end 

    Graph(nodes, distances)
end

function shuffle_solution(s::Array{Int,1}, seed)
    shuffle(MersenneTwister(seed), s)
end

# Swaps two indexes of a list. Returns new list.
function swap(s::Array{Int,1}, u::Int, v::Int)
    r = copy(s)
    n = r[u]
    r[u] = r[v]
    r[v] = n
    return r
end

# Calculates a neighbor of the solution. We define a neighbor in TSP as a random swap of two consecutive nodes in a solution 
function neighbor(s::Array{Int,1}, seed::Int)
    srand(seed)
    u = convert( Int, floor(10000rand()%length(s))+1 )
    v = convert( Int, floor(10000rand()%length(s))+1 )
    #v = u == length(s) ? u-1 : u+1
    swap(s, u, v)
end

# Checks if an edge exists on graph g between every pair of consecutive nodes in solution s
function feasible_path(g::Graph, s::Array{Int,1})
    for i in 2:length(s)
        if g.distances[s[i-1],s[i]] == -1
            return false
        end
    end
    return true
end
