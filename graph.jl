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

# Might be better to use JLD to save and load the graph object, rather than remaking it each time
#function populate_graph(jld_file::String)

#end

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
    
    return net
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
    return Graph(nodes)
end

# Returns true if solution (path) is acceptable, ie. connections exist between all consecutive nodes
function acceptable(g::Graph, path::Array{Int,1})
    i = 1
    println(path)
    while i < length(path)
        from = path[i]
        to = path[i+1]
        con_exists = false
        for c in g.nodes[from].connections
            if c.to_node == to
                con_exists = true
                break
            end
        end
        if !con_exists
            println("failed at "*string(i))
            return false
        end
        i += 1
    end
    true
end


function random_acceptable(g::Graph, cities::Array{Int,1}, seed)
    srand(seed)
    return shuffle(MersenneTwister(seed), cities)
end

#=
function random_acceptable2(g::Graph, cities::Array{Int,1}, seed)	
    println("Will find hamiltonian path for:")
    println(cities)
    println("throwing darts...")
    srand(seed)
    attempts = 0
    while true
        attempts += 1
        seed2 = convert(Int, floor(100000000rand())) # because we cannot use a float as seed
        shuffled = shuffle(MersenneTwister(seed2), cities) # might not be most efficient but this way it is reproducible
        n = pop!(shuffled)
        path = [n]
        tried_both_ends = false
        while length(shuffled) > 0
            n_neighbors = [m.to_node for m in g.nodes[n].connections] # lets transform conns to list of ints to make life easier
            found_path = false
            position = 0
            for c in shuffled
                position += 1
                if c in n_neighbors
                    deleteat!(shuffled,position)
                    push!(path, c)
                    n = c
                    found_path = true
                    break
                end
            end
            if !found_path
                if !tried_both_ends
                    n = path[1]
                    tried_both_ends = true
                else
                    break
                end
            end
        end
        if length(path) == length(cities)
            break
        end
        # else
        #println(length(path))
        #println(path)
    end
    
    println("FOUND ACCEPTABLE SOLUTION AFTER "*string(attempts)*" ATTEMPTS:")
    println(path)
    
    return path
end
=#

cities = [22,74,109,113,117,137,178,180,200,216,272,299,345,447,492,493,498,505,521,572,607,627,642,679,710,717,747,774,786,829,830,839,853,857,893,921,935,986,1032,1073]
seed = 1234567890

g = populate_graph("cities.txt", "connections.txt")

solution = random_acceptable(g, cities, seed)
print(solution)
