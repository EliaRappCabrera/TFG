# PRIMER MODELO: 2 ENTREVISTADORES:
# Código para realizar el modelo matemático:
using JuMP
using Gurobi

# Se inicia el modelo.
m = Model(Gurobi.Optimizer)

# Se definen las variables.
@variable(m, x[I,K], binary=true)
@variable(m, y1[I], binary=true)
@variable(m, y2[I], binary=true)
@variable(m, z[P], binary=true)

# Se definen las restricciones.
@constraint(m, con1[i=I], y1[i]+y2[i]<=1)
@constraint(m, con2[i=I], sum(x[i,k] for k in K) 
    == y1[i]+2*y2[i])
for p in P
    TEncuestas = 0
    TEncuestas = sum(vuelos[i, "Encuestas"]*
        (y1[i]+y2[i]) for i in I if 
                vuelos[i, "Región"] == 
                dfRegion[p, "Región"])
    if dfRegion[p, "Max_encuestas"] >= 
        dfRegion[p,"Num_mues_min"]
        m[:con3] = @constraint(m, TEncuestas >= 
            (dfRegion[p,"Num_mues_min"]*(z[p])))
    elseif dfRegion[p, "Max_encuestas"] < 
        dfRegion[p,"Num_mues_min"]
        m[:con4] = @constraint(m, TEncuestas >= 
            (dfRegion[p, "Max_encuestas"]-
                (dfRegion[p,"Num_mues_min"]*(z[p]))))     
    end
end
for i in I
    for j in I
            if i!=j && vuelos[i,"Dia_semana"]==
            vuelos[j,"Dia_semana"] && 
                vuelos[i,"Tiempo_minutos"]<=
            vuelos[j,"Tiempo_minutos"]
            if vuelos[i,"Tiempo_minutos"]>
                vuelos[j,"Tiempo_minutos"]-
                vuelos[j,"Consumo(min)"]/2-
                Parámetros[1,"descanso_minutos"]|| 
                vuelos[i,"Tiempo_minutos"]-
                (vuelos[i,"Consumo(min)"]/2)+
                Parámetros[1,"jornada_horas"]*60<
                vuelos[j,"Tiempo_minutos"]
                m[:con5] = @constraint(m, [k=K], 
                    x[i,k]+x[j,k]<=1)
            elseif vuelos[i,"Tiempo_minutos"]>
                vuelos[j,"Tiempo_minutos"]-
                vuelos[j,"Consumo(min)"]-
                Parámetros[1,"descanso_minutos"]
                m[:con6] = @constraint(m, [k=K], 
                    x[i,k]+x[j,k]<=1+sum(x[j,l] 
                        for l in K if l!=k))
            elseif vuelos[i,"Tiempo_minutos"]-
                vuelos[i,"Consumo(min)"]+
                Parámetros[1,"jornada_horas"]*60<
                vuelos[j,"Tiempo_minutos"]
                m[:con7] = @constraint(m, [k=K], 
                    x[i,k]+x[j,k]<=1+sum(x[i,l] 
                        for l in K if l!=k))   
            end
        end
    end
end

# Se incluye la función objetivo (según se haya 
# elegido en el archivo parámetros).                  
if Parámetros[1, "f_optima"]==1
    @objective(m, Max, sum(vuelos[i,"Encuestas"]*
            (y1[i]+y2[i]) for i in I)-100*
        sum(dfRegion[p,"Max_encuestas"]*z[p] 
            for p in P))
end
if Parámetros[1, "f_optima"]==2
    @objective(m, Max, sum(vuelos[i,"Encuestas"]*
            (-y1[i]+y2[i]) for i in I)-100*
        sum(dfRegion[p,"Max_encuestas"]*z[p] 
            for p in P))
end
if Parámetros[1, "f_optima"]==3
    @objective(m, Max, sum(vuelos[i,"Encuestas"]*
            (y1[i]+2y2[i]) for i in I)-100*
        sum(dfRegion[p,"Max_encuestas"]*z[p] 
            for p in P))
end
if Parámetros[1, "f_optima"]==4
    @objective(m, Min, sum(vuelos[i,"Encuestas"]*
            (y1[i]+y2[i]) for i in I)-100*
        sum(dfRegion[p,"Max_encuestas"]*z[p] 
            for p in P))
end
if Parámetros[1, "f_optima"]==5
    @objective(m, Min, sum(vuelos[i,"Encuestas"]*
            (2y1[i]+y2[i]) for i in I)-100*
        sum(dfRegion[p,"Max_encuestas"]*z[p] 
            for p in P))
end

optimize!(m)
