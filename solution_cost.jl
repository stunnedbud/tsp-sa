include("costs.jl")

if length(ARGS) < 1 
    println("Error: No hay entrada. Introduzca como parámetro la lista de nodos de la solución.")
    return 0
end

g = populate_graph("cities.txt","connections.txt")

cities_str = split(ARGS[1], ",")
cities_str = map(utf8, cities_str) # without this parse doesn't work
s = Int[]
for i in 1:length(cities_str)
     push!(s, parse(Int, cities_str[i]))
end

pun = calc_punishment(g,s,3.5)
avg = weight_average(g,s)
c = cost(g,s,pun,avg)
println(c)
