#h: #represents # boats on hand at end of quarter
#x: #number of boats made less than 40
#y: #number of boats made above 40 
using JuMP, Clp
d = [40 60 75 25 36] # monthly demand for boats
m = Model(with_optimizer(Clp.Optimizer))

@variables(m, begin
0 <= x[1:4] <= 40 #boats produced with regular labor
y[1:4]>= 0 #boats produced with overtime labor
h[1:5] >= 0 #boats held in inventory
c1[1:4] >= 0 #to capture change in production from period to period
c2[1:4] >= 0 #to capture change in production from period to period
end)

@constraints(m, begin
    h[1] == 10 + x[1] + y[1] - 40
    h[2] == h[1] + x[2] + y[2] - 60
    h[3] == h[2] + x[3] + y[3] - 75   # conservation of boats
    h[4] == h[3] + x[4] + y[4] - 25
    h[4] >= 10
    x[1]+y[1] - 50 == c1[1] - c2[1]
    x[2] + y[2] -(x[1] + y[1]) == c1[2] - c2[2]
    x[3] + y[3] -(x[2] + y[2]) == c1[3] - c2[3]
    x[4] + y[4] -(x[3] + y[3]) == c1[4] - c2[4]
end)

@objective(m, Min, 400*sum(x) + 450*sum(y) + 20*sum(h) +  400*sum(c1) + 500*sum(c2))      # minimize costs

status = optimize!(m)

println("Build ", Array{Int64}(value.(x')), " using regular labor")
println("Build ", Array{Int64}(value.(y')), " using overtime labor")
println("Build ", Array{Int64}(value.(c1')), " first capture change in production")
println("Build ", Array{Int64}(value.(c2')), " second capture change in production")
println("Inventory: ", Array{Int64}(value.(h')))