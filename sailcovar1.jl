#h: #represents # boats on hand at end of quarter
#x: #number of boats made less than 40
#y: #number of boats made above 40 
using JuMP, Clp
d = [40 60 75 25 36] # monthly demand for boats
m = Model(with_optimizer(Clp.Optimizer))

@variables(m, begin
    0 <= x[1:5] <= 40 #boats produced with regular labor
    y[1:5] >= 0 #boats produced with overtime labor
    h[1:5] >= 0 #boats held in inventory
end)

# conservation of boats
@constraints(m, begin
    h[5] >= 10
    h[2] == 15 + x[2] + y[2] - 60
    h[3] == h[2] + x[3] + y[3] - 75 
    h[4] == h[3] + x[4] + y[4] - 25
    h[5] == h[4] + x[5] + y[5] - 36
end)

@objective(m, Min, 400 * sum(x) + 450 * sum(y) + 20 * sum(h))         # minimize costs

status = optimize!(m)

println("Build ", Array{Int64}(value.(x')), " using regular labor")
println("Build ", Array{Int64}(value.(y')), " using overtime labor")
println("Inventory: ", Array{Int64}(value.(h')))