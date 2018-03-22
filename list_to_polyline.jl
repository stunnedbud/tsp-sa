include("graphs.jl")

## Prints in console path s as a polyline (list of lists of coordinate pairs) to draw using leaflet (just copypaste output into script.js).
## Yeah it's a little dirty and probably should've automated it, but it does the trick.


if length(ARGS) < 1 
    println("Error: No hay entrada. Introduzca como parámetro en consola la lista de nodos de la solución.")
    return 0
end

g = populate_graph("cities.txt","connections.txt")

cities_str = split(ARGS[1], ",")
cities_str = map(utf8, cities_str) # without this parse doesn't work
s = Int[]
for i in 1:length(cities_str)
     push!(s, parse(Int, cities_str[i]))
end

out = "["
for i in s
    n = g.nodes[i]
    out *= @sprintf("[%1.5f,%1.5f],",n.latitude, n.longitude)
end
out = out[1:(length(out)-1)] * "]"

println(out)


