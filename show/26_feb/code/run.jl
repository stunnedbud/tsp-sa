include("graphs.jl")
include("costs.jl")
include("simulated_annealing.jl")

settings_file = "settings.txt"

println("Loaded modules")

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
println("Settings")
for (k,v) in settings
    println(k*": "*string(v))
end

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
master_seed = parse(Int, settings["seed"])
srand(master_seed)

# Punishment
punish = calc_punishment(g, parse(Float64,utf8(settings["punishment_factor"])))

# Results file
out = "RUN RESULTS\n\n#######################################\nInitial settings\n"
for (k,v) in settings
    out *= k*": "*string(v)*"\n" 
end 
out *= "#######################################\n\n"
open("results/"*string(master_seed)*".txt","w") do f
    write(f, out)
end
open("results/150/timeseries.txt","w") do f
    write(f, "")
end

# Create directory for plots' data
#timeseries_path ="results/"*string(master_seed)*"/"
#if !isdir(timeseries_path)
#    mkdir(timeseries_path)
#end

# Run heuristic
abs_best = cities
best_run = -1
s = shuffle_solution(cities, master_seed) #initial solution
for i in 1:parse(Int, settings["runs"])
    current_seed = convert(Int,floor(rand()*10^13))
    out = "Run #"*string(i)*"\n"
    out *= "Seed: "
    out *= string(current_seed)*"\n"
    
    last, best = acceptance_by_thresholds(g, s, current_seed, parse(Float64,utf8(settings["T"])), parse(Int,utf8(settings["L"])), parse(Float64,utf8(settings["epsilon"])), parse(Float64,utf8(settings["theta"])), punish)
    
    s = best
    #s = shuffle_solution(cities,current_seed)

    # Update absolute best found
    if cost(g, best, punish) < cost(g, abs_best, punish)
        abs_best = best
        best_run = i
    end

    out *= "Last ["*string(feasible_path(g,last))*"] ("*string(cost(g,last,punish))*"): "
    for j in last
        out *= string(j)*","
    end
    out = out[1:end-1]*"\n" # removes last comma
    out *= "Best ["*string(feasible_path(g,best))*"] ("*string(cost(g,best,punish))*"): "
    for j in best
        out *= string(j)*","
    end
    out = out[1:end-1]*"\n\n" # remove last comma
    print(out)
    
    # Append run results to file
    open("results/"*string(master_seed)*".txt", "a") do f    
        write(f, out)
    end
    
    # Save cost data timeseries to plot later
    #open("results/"*string(master_seed)*"_timeseries.dt","a") do f
        #write(f, ""*string(cost(g,best,punish))*"\n")
    #end
end

# Append final results
out = "\n############################################################\n"
out *= "Best solution found: \n"
for j in best_run
    out *= string(j)*","
end
out = out[1:end-1]*"\n" # removes last comma
out *= "Which costs "*string(cost(g, abs_best, punish))*"\n"
out *= "From run "*string(best_run)*"\n"

open("results/"*string(master_seed)*".txt","a") do f
    write(f, out)
end
