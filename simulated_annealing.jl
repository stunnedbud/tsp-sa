include("graphs.jl")
include("costs.jl")


function calc_lot(g::Graph, s::Array{Int,1}, seed::Int, T::Float64, L::Int, p::Float64)
    best = s
    cost_best = cost(g,s,p)
    accepted_costs = [cost_best]
    srand(seed)
    attempts = 0
    max_attempts = 100L # arbitrary
    count = 0
    while count < L
        attempts += 1
        s2 = neighbor(s, convert(Int,floor(100000000rand())))
        cost_s1 = cost(g,s,p)
        cost_s2 = cost(g,s2,p)
        if cost_s2 < cost_s1 + T
            s = s2
            if cost(g, s, p) < cost_best  
                best = s2
                cost_best = cost_s2
            end
            count += 1
            push!(accepted_costs, cost_s1)
            #println("accepted solution")
        #else
            #println("did not accept solution")
        end
        if attempts > max_attempts
            #println("Exceeded max attempts")
            break
        end
    end
    sum(accepted_costs)/L, s, best
end

#
function acceptance_by_thresholds(g::Graph, s::Array{Int,1}, seed::Int, T::Float64, L::Int, ε::Float64, ϕ::Float64, pf::Float64)
    srand(seed)
    pun = calc_punishment(g, pf)
    p = 0
    c = b = Int[]
    while T > ε
        q = p + 1
        while p < q
            q = p
            p, s, b = calc_lot(g, s, convert(Int,floor(10000000rand())), T, L, pun)
        end
        T = ϕ*T
        println(T)
    end
    s, b
end

