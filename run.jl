include("graphs.jl")
include("costs.jl")
include("simulated_annealing.jl")

settings_file = "settings.txt"

println("Loaded dependencies")

# Read settings file, save into dictionary
k = AbstractString[]    
v = AbstractString[]    
open(settings_file, "r") do f
    lines = readlines(f)
    for l in lines
        if startswith(l, "#") | (l=="\n") # so we can comment out a line
            continue
        end
        str = split(strip(l), "=")
        push!(k, str[1])
        push!(v, str[2])
    end
end
settings = Dict(zip(k,v))
println(settings)

# Generate graph object from file
g = populate_graph(settings["db_cities_file"], settings["db_connections_file"])

# Parse cities subset from settings (this and seed should/will be inputable from command line)
cities_str = split(settings["cities"], ",")
cities_str = map(utf8, cities_str) # without this parse doesn't work
cities = Int[]
for i in 1:length(cities_str)
     push!(cities, parse(Int, cities_str[i]))
end
println("\nCities subset:")
println(cities)
println()

# Get master seed
seed = parse(Int, settings["seed"])
srand(seed)

# Run heuristic
for i in 1:parse(Int, settings["runs"])
    current_seed = convert(Int,floor(100000000rand()))
    print("#################################\nCurrent seed: ")
    println(current_seed)
    s = shuffle_subgraph(cities, current_seed)
    print("Shuffle: ")
    println(s)
    accepted, last, best = acceptance_by_thresholds(g, s, current_seed, parse(Float64,utf8(settings["T"])), parse(Int,utf8(settings["L"])), parse(Float64,utf8(settings["epsilon"])), parse(Float64,utf8(settings["theta"])), parse(Float64,utf8(settings["punishment_factor"])))
    
    # Save run results to file(s)
    open("results/"*string(current_seed)*".txt", "w") do f
        out = "Run results and settings for seed "*string(current_seed)*"\n\n"
        out *= "Last solution: "*string(last)*"\n" 
        out *= "Last solution's cost: "*string(cost(g, last, calc_punishment(g, parse(Float64,utf8(settings["punishment_factor"])))))*"\n"
        out *= "Valid path: "*string(valid_path(g,last))*"\n\n"
        out *= "Best solution: "*string(best)*"\n"
        out *= "Best solution's cost: "*string(cost(g, best, calc_punishment(g, parse(Float64,utf8(settings["punishment_factor"])))))*"\n"
        out *= "Valid path: "*string(valid_path(g,best))*"\n\n"
        print(out)
        for (k,v) in settings
            out *= k*" = "*string(v)*"\n"   
        end
        write(f, out)
    end
    # Save cost data timeseries to plot later
    open("results/"*string(current_seed)*"_timeseries.dt","w") do f
        out = ""
        for c in accepted
            out *= string(c)*"\n"
        end
        write(f, out)
    end
    println("Ended run #"*string(i)*" for seed "*string(current_seed))
end
