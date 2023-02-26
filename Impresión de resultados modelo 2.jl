# Código para imprimir los resultados-Resumen
println("Tiempo tardado en optimizar el problema: 
    ", solve_time(m)," segundos.")
print("\n")
total=0
vuelos1 = 0
print("RESULTADOS OBTENIDOS: \n")
println("Total de vuelos con los que se trabaja: 
    ", length(I),"\n")
for i in I
    if sum(sum(JuMP.value.(y)[i,j]*
                JuMP.value.(x)[i,j,k] 
                for k in K) for j in J)>=1.0
        total = total + vuelos[i,"Encuestas"]
        vuelos1 = vuelos1 + 1
    end
end
println("Total encuestas realizadas: ", total)
for j in J
    encuestas = 0
    for i in I
        if sum(JuMP.value.(y)[i,j]*
                JuMP.value.(x)[i,j,k] 
                for k in K)>=1.0 
            encuestas = encuestas + 
            vuelos[i,"Encuestas"]
        end
    end
    println("Número de encuestadores: ", j , 
        ". Encuestas realizadas: ", encuestas) 
end

R_nocumple = 0
for p in P
    EncuestasR = 0
    for i in I
        if sum(sum(JuMP.value.(y)[i,j]*
                    JuMP.value.(x)[i,j,k] 
                    for k in K) for j in J)>=1.0 
            if vuelos[i, "Región"] == 
                dfRegion[p, "Región"]
                EncuestasR = EncuestasR + 
                vuelos[i, "Encuestas"]
            end
        end
    end
    if EncuestasR < dfRegion[p, "Num_mues_min"]
        R_nocumple = R_nocumple + 1 
    end
end
println("Total de vuelos encuestados: ", vuelos1, 
    "\n", "Regiones que no cumplen el mínimo: ", 
    R_nocumple) 
   

# Código para imprimir los resultados
println("Tiempo tardado en optimizar el problema: 
    ", solve_time(m), " segundos.")
print("\n")
# Total encuestas realizadas, realizadas por un 
# trabajador, realizadas por dos trabajadores, 
# total vuelos encuestados
total=0
vuelos1 = 0
print("RESULTADOS OBTENIDOS: \n")
print("\n")
println("Total de vuelos con los que se trabaja: 
    ", length(I),"\n")
for i in I
    if sum(sum(JuMP.value.(y)[i,j]*
                JuMP.value.(x)[i,j,k] 
                for k in K) for j in J)>=1.0
        total = total + vuelos[i,"Encuestas"]
        vuelos1 = vuelos1 + 1
    end
end
println("Total encuestas realizadas: ", 
    Int(total))
print("\n")
println("Total de vuelos encuestados: ", 
    vuelos1, "\n") 
for j in J
    encuestas = 0
    for i in I
        if sum(JuMP.value.(y)[i,j]*
                JuMP.value.(x)[i,j,k] 
                for k in K)>=1.0
            encuestas = encuestas + 
            vuelos[i,"Encuestas"]
        end
    end
   println("Número de encuestadores: ", j , 
        " Encuestas realizadas: ",encuestas,"\n") 
end

# Para la impresión de datos, se crea una columna 
# con la hora de comienzo de encuestar para cada 
# vuelo, y se ordena el dataframe según la hora 
# de salida de los vuelos
vuelos[!,"Comienzo_E"]=copy(vuelos[!, "Hora_Salida"])
vuelos[!,"Comienzo_EM"]=copy(vuelos[!, "Hora_Salida"])
vuelos[!,"Comienzo_E(min)"]=copy(vuelos[!, 
        "Consumo(min)"])
# Diferenciamos el tiempo de consumo según cuantos 
# trabajadores lo hayan encuestado
for i in I
    if sum(sum(JuMP.value.(y)[i,j]*
                JuMP.value.(x)[i,j,k] for k in K) 
            for j in J)>=1.0
        vuelos[i, "Comienzo_E(min)"] = 
        vuelos[i, "Tiempo_minutos"]-
        vuelos[i,"Consumo(min)"]/j
    end
end
      
for i in I 
    vuelos[i, "Comienzo_EM"] = 
    string(Int(round(vuelos[i,"Comienzo_E(min)"]%60)))
    if length(vuelos[i, "Comienzo_EM"]) == 1 
        vuelos[i, "Comienzo_EM"] = 
        ("0")*vuelos[i, "Comienzo_EM"]
    end
    vuelos[i, "Comienzo_E"] = 
    string(Int(round(vuelos[i,"Comienzo_E(min)"]÷60)))
    *(":")*vuelos[i, "Comienzo_EM"]
end
# Horario de los encuestadores
NumDias = [1, 2, 3, 4, 5, 6, 7]
LetraDias = ["L", "M", "X", "J", "V", "S", "D"]
print("HORARIO DE LOS TRABAJADORES: \n")
print("\n")
for k in K
    println("TRABAJADOR",k)
    print("\n")
    for n in range(1, length(NumDias))
        print("Fecha: ", Semana[NumDias[n], 
                "Semana"]," \n")
        print("\n")
        for i in I
            for j in J
                if JuMP.value.(y)[i,j]*
                    JuMP.value.(x)[i,j,k] == 1.0 
                    if vuelos[i, "Dia_semana"] == 
                        LetraDias[n]
                        println("Encuestadores: ", j, 
                            ". Vuelo: "  , vuelos[i, 
                                "Num_vuelo"],
                            ". Intervalo de trabajo: ", 
                            vuelos[i, "Comienzo_E"],
                            " - ",vuelos[i, 
                                "Hora_Salida"], 
                            ". Encuestas: ", vuelos[i, 
                                "Encuestas"], 
                            ". Duración: ", 
                            Int(round(vuelos[i,
                                        "Encuestas"]*
                                    Parámetros[1,
                                        "velocidad_
                                        minutos"]/2)), 
                            " minutos. \n")
                    end
                end
            end
        end
    end
end
# Cantidad de vuelos y encuestas para cada región
print("CANTIDAD DE VUELOS Y ENCUESTAS PARA CADA REGIÓN :
    \n")
print("\n")
R_nocumple = 0
for p in P
    EncuestasR = 0
    VuelosR = 0
    for i in I
        if sum(sum(JuMP.value.(y)[i,j]*
                    JuMP.value.(x)[i,j,k] for k in K) 
                for j in J)>=1.0 
            if vuelos[i,"Región"]==dfRegion[p,"Región"]
                EncuestasR = EncuestasR + 
                vuelos[i, "Encuestas"]
                VuelosR = VuelosR + 1 
            end
        end
    end
    if EncuestasR < dfRegion[p, "Num_mues_min"]
        println("Región : ", dfRegion[p, "Región"], 
            "\n", "Encuestas realizadas : ", 
            Int(EncuestasR), "\n", 
        "Vuelos encuestados : ", VuelosR, "\n", 
            "Encuestas faltantes : ", Int(dfRegion[p, 
                    "Num_mues_min"] - EncuestasR), 
            "\n")
        R_nocumple = R_nocumple + 1 
    else  println("Región : ", dfRegion[p, "Región"], 
            "\n", "Encuestas realizadas : ", 
            Int(EncuestasR), "\n", 
        "Vuelos encuestados : ", VuelosR, "\n", 
            "Encuestas faltantes : ", 0, "\n")
    end
end                                 
