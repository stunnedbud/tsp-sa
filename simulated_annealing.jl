include("costs.jl")

# Checks al neighbors of solution s, returns the one with lowest cost.
# Probably could use cost_fast here to speed it up a bit.
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

# Sweeps neighbors until cost stops improving.
function sweep(g::Graph, s::Array{Int,1}, pun::Float64, avg::Float64)
    s1 = s
    c_s1 = cost(g,s1,pun,avg)
    s2 = sweep_once(g,s1,pun,avg)
    c_s2 = cost(g,s2,pun,avg) # this function could be 3 lines shorter if julia had a do while
    while c_s2 < c_s1
        s1 = s2
        c_s1 = c_s2
        s2 = sweep_once(g,s1,pun,avg)
        c_s2 = cost(g,s2,pun,avg)
    end
    s1
end

# Starting with solution s, we define a neighbor as a solution s2 where at most two indexes have swapped places.
# An acceptable solution is an s2 which cost at most s's cost plus T.
# Once we accept a solution we assign it to s and keep searching.
# This function generates neighbors until we accept L solutions, or we exceed max_attempts.
# Returns average of accepted costs, last and best accepted solution.
function calc_lot(g::Graph, s::Array{Int,1}, seed::Int, T::Float64, L::Int, p::Float64, avg::Float64, plot_name::Int)
    best = s
    cost_best = cost(g,s,p,avg)
    accepted_costs = [cost_best]
    count = 0
    attempts = 0
    max_attempts = L^2 #WORKS FOR BEST 150
    cost_s1 = cost(g,s,p,avg)
    while count < L
        attempts += 1
        cost_s1 = cost(g,s,p,avg)
        s2, u, v = neighbor(s, convert(Int,floor(100000000rand())))
        #cost_s2 = cost(g,s2,p,avg)
        cost_s2 = cost_fast(g,s,p,avg,u,v,cost_s1)
        if cost_s2 <= cost_s1 + T # accepts solution
            s = s2
            cost_s1 = cost(g,s2,p,avg) #no dejamos que varie mucho el costo rapido
            count += 1
            push!(accepted_costs, cost_s1)
        end
        if cost_s2 < cost_best
            best = s2
            cost_best = cost_s2
        end
        if attempts > max_attempts
            println("Exceeded max attempts")
            #return sum(accepted_costs)/L, s, best, true # if flag is true it ends run entirely
           return sum(accepted_costs)/L, s, best, true
        end
    end

    # Uncomment to save timeseries of accepted costs to file.
    # Deactivated it because my memory was running out.
    out = ""
    for c in accepted_costs
        out *= string(c)*"\n" 
    end
    open("results/plots/"*string(plot_name)*".txt","a") do f
        write(f, out)
    end

    sum(accepted_costs)/L, s, best, false
end

# "Main" function in this file. Calculates lot until average of accepted solutions improves, whereupon it
# decreases T by multiplying it by theta (cooling factor). Keeps doing that until T reaches epsilon.
# Also, every time we improve our best solution found it sweeps to find the local best.
# Returns last accepted solution and the absolute best found.
function acceptance_by_thresholds(g::Graph, s::Array{Int,1}, seed::Int, T::Float64, L::Int, ε::Float64, ϕ::Float64, pun::Float64, avg::Float64, plot_name::Int)
    open("results/plots/"*string(plot_name)*".txt","w") do f
        write(f, "")
    end
    srand(seed)
    p = 0
    abs_b = s # absolute best
    b = s
    f = false
    while T > ε
        q = p + 1
        while p < q
            q = p
            p, s, b, f = calc_lot(g, s, convert(Int,floor(10000000rand())), T, L, pun, avg, plot_name)         
            
            if f # exceeded max attempts
                println("FUCK")
                #b = sweep(g,b,pun,avg)
                return s,b
            end
            
            # Sweeping
            if cost(g,b,pun,avg) < cost(g,abs_b,pun,avg)
                #println("SWEEP:")
                sw = sweep(g,b,pun,avg)
                if cost(g,sw,pun,avg) < cost(g,abs_b,pun,avg)
                    abs_b = sw
                end
                #s = sw # uncomment this to start next lot with swept solution. Not reccomended since it usually gets you stuck in a local minimum.
                #println(cost(g,b,pun,avg))
                #println(cost(g,sw,pun,avg))
                #println("")
            end
        end
       
        T = ϕ*T
        #println(T)
    end

    s,abs_b
end

