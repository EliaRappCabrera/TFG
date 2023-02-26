# SEGUNDO MODELO:FUNCIONA PARA K 
# ENTREVISTADORES
# Código para realizar el modelo matemático
using JuMP
using Gurobi

# Iniciamos el modelo
m = Model(Gurobi.Optimizer)

# Definir las variables
@variable(m, x[I,J,K], binary=true)
@variable(m, y[I,J], binary=true)
@variable(m, z[P], binary=true)

# Definir las restricciones
@constraint(m, con1[i=I], sum(y[i,j] for j 
            in J) <= 1)
@constraint(m, con2[i=I,j=J], sum(x[i,j,k] 
        for k in K) == j*y[i,j])

for p in P
    TEncuestas = 0
    TEncuestas = sum(sum(vuelos[i,
                "Encuestas"]*(y[i,j]) 
            for j in J) for i in I 
            if vuelos[i,"Región"]==
                dfRegion[p, "Región"])
    if dfRegion[p,"Max_encuestas"]>=
        dfRegion[p,"Num_mues_min"]
        m[:con3] = @constraint(m,TEncuestas>=
            (dfRegion[p,"Num_mues_min"]*(z[p])))
    elseif dfRegion[p,"Max_encuestas"]<
        dfRegion[p,"Num_mues_min"]
        m[:con4] = @constraint(m,TEncuestas>=
            (dfRegion[p, "Max_encuestas"]-
                (dfRegion[p,"Num_mues_min"]*
                    (z[p]))))     
    end
end

for i in I
    for l in I
        for j in J
            for t in J
                if i!=l&&vuelos[i,
                        "Dia_semana"]==vuelos[l,
                        "Dia_semana"]&&vuelos[i,
                        "Tiempo_minutos"]<=
                    vuelos[l,"Tiempo_minutos"]
                    if (vuelos[i,
                                "Tiempo_minutos"]
                            >vuelos[l,
                                "Tiempo_minutos"]-
                            (vuelos[l,
                                    "Consumo(min)"]
                                /t)-
                            Parámetros[1,"
                                descanso_minutos"])
                        ||(vuelos[i,
                                "Tiempo_minutos"]
                            -(vuelos[i,
                                    "Consumo(min)"]
                                /j)+Parámetros[1,
                                "jornada_horas"]*60
                            <vuelos[l,
                                "Tiempo_minutos"])
                        m[:con5] = @constraint(m,
                            [k=K], x[i,j,k]+
                            x[l,t,k]<=1)
                    end
                end
            end
        end
    end
end

if Parámetros[1, "f_optima"]==1
    @objective(m, Max, sum(vuelos[i,"Encuestas"]
            *sum((y[i,j]) for j in J) for i in I)- 
    100*sum(dfRegion[p,"Max_encuestas"]*z[p] 
            for p in P))
end 
if Parámetros[1, "f_optima"]==2
    @objective(m, Max, sum(vuelos[i,"Encuestas"]
            *sum(j*(y[i,j]) for j in J) 
            for i in I) - 
    100*sum(dfRegion[p,"Max_encuestas"]*z[p] 
            for p in P))
end


optimize!(m)
