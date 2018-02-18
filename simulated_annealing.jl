include("graphs.jl")
include("costs.jl")


function calc_lot(g::Graph, s::Array{Int,1}, seed::Int, T::Float64, L::Int, p::Float64)
    best = s
    cost_best = cost(g,s,p)
    accepted_costs = [cost_best]
    srand(seed)
    attempts = 0
    max_attempts = 10L # arbitrary
    count = 0
    while count < L
        attempts += 1
        s2 = neighbor(s, convert(Int,floor(100000000rand())))
        #println("NEIGHBOR")
        #println(s2)
        #println(cost(g,s,p))
        #println(s2)
        #println(cost(g,s2,p))
        cost_s1 = cost(g,s,p)
        cost_s2 = cost(g,s2,p)
        if cost_s2 < cost_s1 + T
            s = s2
            #println(cost(g,s,p))
            if cost(g, s, p) < cost_best  
                best = s2
                cost_best = cost_s2
            end
            count += 1
            push!(accepted_costs, cost_s1)
        else
            println("did not accept solution")
        end
        if attempts > max_attempts
            println("Exceeded max attempts")
            break
        end
    end
    #println("ended lot")
    accepted_costs, s, best# returns accepted solutions' costs, last accepted one and best one found
end

# ϕ is the cooling factor
function acceptance_by_thresholds(g::Graph, s::Array{Int,1}, seed::Int, T::Float64, L::Int, ε::Float64, ϕ::Float64, pf::Float64)
    srand(seed)
    pun = calc_punishment(g, pf)
    p = 0
    c = b = Int[]
    println(T)
    while T > ε
        q = p + 1
        while p < q
            q = p
            #println("q = "*string(q))
            #println(s)
            c, s, b = calc_lot(g, s, convert(Int,floor(10000000rand())), T, L, pun)
            #println(s)
            p = sum(c) / L # average of accepted solutions' costs
            #println("p = "*string(p))
        end
        T = ϕ*T
        println(T)
    end
    c, s, b # returns array with timeseries for accepted solutions' costs, last accepted one and best one found
end

