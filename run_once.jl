include("simulated_annealing.jl")

if length(ARGS) < 1 
    println("Error: No se especificó el archivo de settings en la linea de comandos. El programa terminará.")
    return 0
end

settings_file = ARGS[1]

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

# Get seed
seed = parse(Int, settings["seed"])

# Punishment
punish = calc_punishment(g, cities, parse(Float64,utf8(settings["punishment_factor"])))
#punish = parse(Float64,utf8(settings["punishment_factor"])) * 4976033.95

# Weight average
average = weight_average(g, cities)

# Results file
out = "RUN RESULTS\n\n#######################################\nInitial settings\n"
for (k,v) in settings
    out *= k*": "*string(v)*"\n" 
end 
out *= "#######################################\n\n"
open("results/ONCE_"*string(seed)*".txt","w") do f
    write(f, out)
end

# Run once
s = cities
last, best = acceptance_by_thresholds(g, s, seed, parse(Float64,utf8(settings["T"])), parse(Int,utf8(settings["L"])), parse(Float64,utf8(settings["epsilon"])), parse(Float64,utf8(settings["theta"])), punish, average, seed)
    

out *= "Last ["*string(feasible_path(g,last))*"] ("*string(cost(g,last,punish,average))*"): "
for j in last
out *= string(j)*","
end
out = out[1:end-1]*"\n" # removes last comma
out *= "Best ["*string(feasible_path(g,best))*"] ("*string(cost(g,best,punish,average))*"): "
for j in best
out *= string(j)*","
end
out = out[1:end-1]*"\n\n" # remove last comma
print(out)

# Append run results to file
open("results/ONCE_"*string(seed)*".txt", "a") do f    
write(f, out)
end


