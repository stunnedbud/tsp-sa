include("graphs.jl")
include("costs.jl")


function calc_lot(g::Graph, s::Array{Int,1}, seed::Int, T::Float64, L::Int, p::Float64)
    attempts = 0
    max_attempts = 100L # arbitrary
    count = 0
    accepted_costs = [cost(g, s, p)]
    best_solution_found = s
    s2 = Int[]
    srand(seed)
    while count < L
        attempts += 1
        s2 = neighbor(s, convert(Int,floor(100000000rand())))
        #println("NEIGHBOR")
        #println(s2)
        #println(cost(g,s,p))
        #println(s2)
        #println(cost(g,s2,p))
        if cost(g, s2, p) < cost(g, s, p) + T
            s = s2
            #println(cost(g,s,p))
            if cost(g, s, p) < cost(g, best_solution_found, p)   
                best_solution_found = s2
            end
            count += 1
            push!(accepted_costs, cost(g, s, p))
        else
            println("did not accept solution")
        end
        if attempts > max_attempts
            println("Exceeded max attempts")
            break
        end
    end
    #println("ended lot")
    accepted_costs, s, best_solution_found # returns accepted solutions' costs, last accepted one and best one found
end

# ϕ is the cooling factor
function acceptance_by_thresholds(g::Graph, s::Array{Int,1}, seed::Int, T::Float64, L::Int, ε::Float64, ϕ::Float64, pf::Float64)
    pun = calc_punishment(g, pf)
    srand(seed)
    p = 0
    c = b = Int[]
    println(T)
    while T > ε
        q = p + 1
        while p <= q
            q = p
            #println(s)
            c, s, b = calc_lot(g, s, convert(Int,floor(1000000rand())), T, L, pun)
            #println("exited calc_lot")
            #println(s)
            p = sum(c) / L # average of accepted solutions' costs
        end
        T = ϕ*T
        println(T)
    end
    c, s, b # returns array with timeseries for accepted solutions' costs, last accepted one and best one found
end

