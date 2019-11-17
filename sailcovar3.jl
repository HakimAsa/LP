#h: #represents # boats on hand at end of quarter
#x: #number of boats made less than 40
#y: #number of boats made above 40 
using JuMP, Clp
d = [40 60 75 25 36] # monthly demand for boats
m = Model(with_optimizer(Clp.Optimizer))

@variables(m, begin
    0 <= x[1:4] <= 40 #boats produced with regular labor
    y[1:4] >= 0 #boats produced with overtime labor
    c1[1:4] >= 0 #to capture change in production from period to period
    c2[1:4] >= 0 #to capture change in production from period to period
    h1[1:4] >= 0 #Allowing demandsto be backlogged
    h2[1:4] >= 0 #Allowing demandsto be backlogged
    end)

@constraints(m, begin
    h1[1] - h2[2] == 10 + x[1] + y[1] - 40
    h1[2] - h2[2] == h1[1] - h2[2] + x[2] + y[2] - 60
    h1[3]- h2[3] == h1[2] - h2[2] + x[3] + y[3] - 75 
    h1[4] - h2[4] == h1[3]- h2[3] + x[4] + y[4] - 25
    h1[4] >= 10
    h2[4] <= 0
    x[1] + y[1] - 50 == c1[1] - c2[1]
    x[2] + y[2] - (x[1] + y[1]) == c1[2] - c2[2]
    x[3] + y[3] - (x[2] + y[2]) == c1[3] - c2[3]
    x[4] + y[4] - (x[3] + y[3]) == c1[4] - c2[4]
end)

@objective(m, Min, 400 * sum(x) + 450 * sum(y) + 20 * sum(h1) +  400 * sum(c1) + 500 * sum(c2) + 100 * sum(h2))      # minimize costs

status = optimize!(m)

println("Build ", Array{Int64}(value.(x')), " using regular labor")
println("Build ", Array{Int64}(value.(y')), " using overtime labor")
println("Build ", Array{Int64}(value.(c1')), " first capture change in production")
println("Build ", Array{Int64}(value.(c2')), " second capture change in production")
println("Build ", Array{Int64}(value.(h1')), " potential backlog")
println("Build ", Array{Int64}(value.(h2')), " non-negative except for final period potential backlog")