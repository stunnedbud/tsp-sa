include("costs.jl")

function sweep_once(g::Graph, s::Array{Int,1}, pun::Float64, avg::Float64)
    s1 = s
    c_ini = cost(g,s,pun,avg) 
    c_s1 = c_ini
    for i in 1:length(s)
        for j in 1:length(s)
            if j <= i
                continue
            end
            s2 = swap(s,i,j)
            c_s2 = cost(g,s2,pun,avg)
            if c_s2 < c_s1
                s1 = s2
                c_s1 = c_s2
            end
        end
    end    
    s1
end

function sweep(g::Graph, s::Array{Int,1}, pun::Float64, avg::Float64)
    s1 = s
    c_s1 = cost(g,s1,pun,avg)
    s2 = sweep_once(g,s1,pun,avg)
    c_s2 = cost(g,s2,pun,avg)
    while c_s2 < c_s1
        s1 = s2
        c_s1 = c_s2
        s2 = sweep_once(g,s1,pun,avg)
        c_s2 = cost(g,s2,pun,avg)
    end
    s1
end

function calc_lot(g::Graph, s::Array{Int,1}, seed::Int, T::Float64, L::Int, p::Float64, avg::Float64)
    best = s
    cost_best = cost(g,s,p,avg)
    accepted_costs = [cost_best]
    attempts = 0
    max_attempts = 500L
    count = 0
    taboo = []
    while count < L
        attempts += 1
        s2 = neighbor(s, convert(Int,floor(100000000rand())))
        cost_s1 = cost(g,s,p,avg)
        cost_s2 = cost(g,s2,p,avg)
        if cost_s2 < cost_s1 + T && taboo != s2 # accepts solution
            taboo = s
            s = s2
            if cost_s2 < cost_best
                best = s2
                cost_best = cost_s2
            end
            count += 1
            push!(accepted_costs, cost_s1)
        end
        if attempts > max_attempts
            println("Exceeded max attempts")
            break
        end
    end
    
    if feasible_path(g,best)
        out = ""
        for c in accepted_costs
            out *= "E:"*string(c)*"\n"
        end
    
        open("results/150/"*string(seed)*"_timeseries.txt","w") do f
            write(f, out)
        end
    end
    sum(accepted_costs)/L, s, best
end

#
function acceptance_by_thresholds(g::Graph, s::Array{Int,1}, seed::Int, T::Float64, L::Int, ε::Float64, ϕ::Float64, pun::Float64, avg::Float64)
    srand(seed)
    p = 0
    c = b = Int[]
    while T > ε
        q = p + 1
        while p < q
            q = p
            s = sweep(g,s,pun,avg) 
            p, s, b = calc_lot(g, s, convert(Int,floor(10000000rand())), T, L, pun, avg)
        end
        T = ϕ*T
        println(T)
    end
    s, b
end

