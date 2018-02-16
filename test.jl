include("graphs.jl")
include("costs.jl")
include("simulated_annealing.jl")

# test values
punishment_factor = 5.0
cities = [22,74,109,113,117,137,178,180,200,216,272,299,345,447,492,493,498,505,521,572,607,627,642,679,710,717,747,774,786,829,830,839,853,857,893,921,935,986,1032,1073]

g = populate_graph("cities.txt", "connections.txt")

p = calc_punishment(g, punishment_factor)
println(cost(g, cities, p))


