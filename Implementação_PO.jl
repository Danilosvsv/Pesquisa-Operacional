using JuMP
using GLPK

struct InstanceBarCuts
    n::Int64
    k::Int64
    p::Array{Int64}
    d::Array{Int64}
    q::Array{Int64}
    c::Array{Int64}

end

function ReadInstanceBarCuts(file::AbstractString)

    open(file, "r") do f
       n = parse(Int64,readline(f));
       k = parse(Int64,readline(f));
       p = parse.(Int64,split(readline(f)));
       d = parse.(Int64,split(readline(f)));
       q = parse.(Int64,split(readline(f)));
       c = parse.(Int64,split(readline(f)));
       return InstanceBarCuts(n, k, p, d, q, c) ;
    end

end

function resolution(instance::InstanceBarCuts)

    model = Model(with_optimizer(GLPK.Optimizer))

    # Variáveis
    @variable(model, y[1:instance.k], Bin)
    @variable(model, 0 <= x[1:instance.k,1:instance.n] , Int)

    # Função Objetivo
    @objective(model, Min, sum(instance.p[j]*y[j] for j = 1:instance.k ))

    # Restrições
    @constraint(model, con1[j in 1:instance.k], sum(instance.q[i]*x[j,i] for i = 1:instance.n) <= instance.c[j]*y[j] )

    @constraint(model, con2[i in 1:instance.n], sum(x[j,i] for j = 1:instance.k) == instance.d[i] )


    optimize!(model)
    print(model)
    for j = 1:instance.k, i = 1:instance.n
        if (value(x[j,i]) > 0.001)
            println(value(x[j,i]))
        end
    end

    for j = 1:instance.k
        if (value(y[j]) > 0.001)
            println(value(y[j]))
        end
    end

    println("Funcao Objetivo: ", objective_value(model))
    println(termination_status(model))
end

file_name = "teste.txt";

instance = ReadInstanceBarCuts(file_name);
resolution(instance);
