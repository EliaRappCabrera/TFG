# Código para imprimir los resultados-Resumen 
println("Tiempo tardado en optimizar el problema: 
", solve_time(m), " segundos.")
print("\n")
total=0
encuestas1 = 0
encuestas2 = 0
vuelos1 = 0
print("RESULTADOS OBTENIDOS: \n")
for i in I
    if (JuMP.value.(y1)[i]*JuMP.value.(x)[i,1]==
            1.0)||(JuMP.value.(y1)[i]*JuMP.value.(x)
            [i,2]==1.0)||((JuMP.value.(y2)[i]*
                JuMP.value.(x)[i,1]==1.0)&&
            (JuMP.value.(y2)[i]*JuMP.value.(x)
                [i,2]==1.0))
        total = total + vuelos[i,"Encuestas"]
        vuelos1 = vuelos1 + 1 
    end
    if (JuMP.value.(y1)[i]*JuMP.value.(x)[i,1]==1.0)||
        (JuMP.value.(y1)[i]*JuMP.value.(x)[i,2]==1.0)
      encuestas1 = encuestas1 + vuelos[i,"Encuestas"]
    end
    if (JuMP.value.(y2)[i]*JuMP.value.(x)[i,1]==1.0)
        &&(JuMP.value.(y2)[i]*JuMP.value.(x)[i,2]==1.0)
        encuestas2 = encuestas2 + vuelos[i,"Encuestas"]
    end
end
R_nocumple = 0
for p in P
    EncuestasR = 0
    VuelosR = 0
    for i in I
        if (JuMP.value.(y1)[i]*JuMP.value.(x)[i,1]
                ==1.0)||(JuMP.value.(y1)[i]*
                JuMP.value.(x)[i,2]==1.0)||
            ((JuMP.value.(y2)[i]*JuMP.value.(x)[i,1]
                    ==1.0)&&(JuMP.value.(y2)[i]*
                    JuMP.value.(x)[i,2]==1.0))
            if vuelos[i,"Región"]== 
                dfRegion[p,"Región"]
                EncuestasR=EncuestasR+
                vuelos[i, "Encuestas"]
            end
        end
    end
    if EncuestasR < dfRegion[p, "Num_mues_min"]
        R_nocumple = R_nocumple + 1
    end
end
println("Total de vuelos con los que se trabaja: ", 
    length(I), "\n", "Total encuestas realizadas: ",
    total, "\n", "Número de encuestadores: 1. 
    Encuestas realizadas: ",encuestas1, "\n", 
    "Número de encuestadores: 2. Encuestas 
    realizadas: ", encuestas2, "\n","Total de vuelos 
    encuestados: ", vuelos1, "\n", "Regiones que no 
    cumplen el mínimo: ", R_nocumple) 

# Código para imprimir los resultados(forma extensa)
println("Tiempo tardado en optimizar el problema: ", 
    solve_time(m), " segundos.")
print("\n")
# Total encuestas realizadas, realizadas por un 
# trabajador, realizadas por dos trabajadores, total
# vuelos encuestados
total=0
encuestas1 = 0
encuestas2 = 0
vuelos1 = 0
print("RESULTADOS OBTENIDOS: \n")
print("\n")
for i in I
    if (JuMP.value.(y1)[i]*JuMP.value.(x)[i,1]==
            1.0)||(JuMP.value.(y1)[i]*
            JuMP.value.(x)[i,2]==1.0)|| 
        ((JuMP.value.(y2)[i]*JuMP.value.(x)[i,1]
                ==1.0)&&(JuMP.value.(y2)[i]*
                JuMP.value.(x)[i,2]==1.0))
        total = total + vuelos[i,"Encuestas"]
        vuelos1 = vuelos1 + 1 
    end
    if (JuMP.value.(y1)[i]*JuMP.value.(x)[i,1]==1.0)
        ||(JuMP.value.(y1)[i]*JuMP.value.(x)[i,2]==1.0)
      encuestas1 = encuestas1 + vuelos[i,"Encuestas"]
    end
    if (JuMP.value.(y2)[i]*JuMP.value.(x)[i,1]==1.0)
        &&(JuMP.value.(y2)[i]*JuMP.value.(x)[i,2]==1.0)
        encuestas2 = encuestas2 + vuelos[i,"Encuestas"]
    end
end
println("Total encuestas realizadas: ", Int(total))
print("\n")
println("Encuestas realizadas por un trabajador: ", 
    Int(encuestas1))
print("\n")
println("Encuestas realizadas por dos trabajadores: ", 
    Int(encuestas2))
print("\n")
println("Total de vuelos encuestados: ", vuelos1, "\n")
print("\n")

# Para la impresión de datos, se crea una columna con la 
# hora de comienzo de encuestar para cada vuelo, y se 
# ordena el dataframe según la hora de salida de los 
# vuelos
vuelos[!,"Comienzo_E"]=copy(vuelos[!, "Hora_Salida"])
vuelos[!,"Comienzo_EM"]=copy(vuelos[!, "Hora_Salida"])
vuelos[!,"Comienzo_E(min)"]=copy(vuelos[!, 
        "Consumo(min)"])
#diferenciamos el tiempo de consumo según si se ha 
# encuestado un vuelo por uno o dos encuestadores
for i in I
    if (JuMP.value.(y2)[i]*JuMP.value.(x)[i,1])==1.0
        vuelos[i, "Comienzo_E(min)"]=
        vuelos[i,"Tiempo_minutos"]-
        vuelos[i,"Consumo(min)"]/2
    end 
    if (JuMP.value.(y1)[i]*JuMP.value.(x)[i,1])==1.0
        ||(JuMP.value.(y1)[i]*JuMP.value.(x)[i,2])==1.0
        vuelos[i,"Comienzo_E(min)"]=
        vuelos[i,"Tiempo_minutos"]-
        vuelos[i,"Consumo(min)"]
    end
end     
for i in I 
    vuelos[i,"Comienzo_EM"]=
    string(Int(round(vuelos[i,"Comienzo_E(min)"]%60)))
    if length(vuelos[i,"Comienzo_EM"])==1 
        vuelos[i,"Comienzo_EM"]=("0")*
        vuelos[i,"Comienzo_EM"]
    end
    vuelos[i,"Comienzo_E"]=
    string(Int(round(vuelos[i,"Comienzo_E(min)"]÷60)))
    *(":")*vuelos[i,"Comienzo_EM"]
end

# Horario de los encuestadores
NumDias = [1, 2, 3, 4, 5, 6, 7]
LetraDias = ["L", "M", "X", "J", "V", "S", "D"]
print("HORARIO DE LOS TRABAJADORES: \n")
print("\n")
print("PRIMER TRABAJADOR: \n")
print("\n")
for n in range(1, length(NumDias))
    print("Fecha: ",Semana[NumDias[n],"Semana"]," \n")
    print("\n")
    for i in I
        if (JuMP.value.(y2)[i]*JuMP.value.(x)[i,1])
            ==1.0 
            if vuelos[i, "Dia_semana"]==LetraDias[n]
                println("** Vuelo: ",
                    vuelos[i, "Num_vuelo"],
                    ". Intervalo de trabajo: ",
                    vuelos[i, "Comienzo_E"]," - ", 
                    vuelos[i, "Hora_Salida"],
                    ". Encuestas: ",
                    vuelos[i, "Encuestas"],
                    ". Duración: ", 
                    Int(round(vuelos[i,"Encuestas"]*
                            Parámetros[1,
                                "velocidad_minutos"]/2)),
                    " minutos. \n")
            end
        end
        if (JuMP.value.(y1)[i]*JuMP.value.(x)[i,1])==
            1.0 
            if vuelos[i,"Dia_semana"]==LetraDias[n]
                println("* Vuelo: ",vuelos[i,
                        "Num_vuelo"],". Intervalo de 
                    trabajo: ",vuelos[i,"Comienzo_E"],
                    " - ",vuelos[i,"Hora_Salida"], 
                    ". Encuestas: ",vuelos[i,
                        "Encuestas"],". Duración: ", 
                    Int(round(vuelos[i,"Encuestas"]*
                            Parámetros[1,
                                "velocidad_minutos"])), 
                    " minutos. \n")
            end
            
        end
    end
    print("\n")
end

print("SEGUNDO TRABAJADOR: \n")
print("\n")
for n in range(1, length(NumDias))
    print(Semana[NumDias[n], "Semana"]," \n")
    print("\n")
    for i in I
        if (JuMP.value.(y2)[i]*JuMP.value.(x)[i,2])
            ==1.0 
            if vuelos[i,"Dia_semana"]==LetraDias[n]
                println("** Vuelo: ",vuelos[i,
                        "Num_vuelo"],". Intervalo de 
                    trabajo: ",vuelos[i,"Comienzo_E"],
                    " - ",vuelos[i,"Hora_Salida"],
                    ". Encuestas: ",vuelos[i,
                        "Encuestas"],". Duración: ", 
                    Int(round(vuelos[i,"Encuestas"]*
                            Parámetros[1,
                                "velocidad_minutos"]/2)), 
                    " minutos. \n")
            end
        end
        if (JuMP.value.(y1)[i]*JuMP.value.(x)[i,2])
            ==1.0 
            if vuelos[i,"Dia_semana"]==LetraDias[n]
                println("* Vuelo: ",vuelos[i,
                        "Num_vuelo"],". Intervalo de 
                    trabajo: ",vuelos[i,"Comienzo_E"],
                    " - ",vuelos[i,"Hora_Salida"],
                    ". Encuestas: ", vuelos[i,
                        "Encuestas"],". Duración: ", 
                    Int(round(vuelos[i,"Encuestas"]*
                            Parámetros[1,
                                "velocidad_minutos"])), 
                    " minutos. \n")
            end
        end
    end
    print("\n")
end

# Cantidad de vuelos y encuestas para cada región
print("CANTIDAD DE VUELOS Y ENCUESTAS PARA CADA REGIÓN 
    : \n")
print("\n")
R_nocumple = 0
for p in P
    EncuestasR = 0
    VuelosR = 0
    for i in I
        if (JuMP.value.(y1)[i]*JuMP.value.(x)[i,1]==1.0)
            ||(JuMP.value.(y1)[i]*JuMP.value.(x)[i,2]==
                1.0)||((JuMP.value.(y2)[i]*JuMP.value.(x)
                    [i,1]==1.0) && (JuMP.value.(y2)[i]*
                    JuMP.value.(x)[i,2]==1.0))
            if vuelos[i,"Región"]==dfRegion[p,"Región"]
                EncuestasR=EncuestasR+vuelos[i,
                    "Encuestas"]
                VuelosR = VuelosR + 1 
            end
        end
    end
    if EncuestasR < dfRegion[p, "Num_mues_min"]
        println("Región : ", dfRegion[p, "Región"], 
            "\n", "Encuestas realizadas : ", 
            Int(EncuestasR), "\n","Vuelos encuestados : ",
            VuelosR, "\n", "Encuestas faltantes : ",
            Int(dfRegion[p, "Num_mues_min"] - EncuestasR), 
            "\n")
        R_nocumple = R_nocumple + 1 
    else  println("Región : ", dfRegion[p, "Región"], 
            "\n","Encuestas realizadas : ",Int(EncuestasR), 
            "\n","Vuelos encuestados : ", VuelosR,
            "\n", "Encuestas faltantes : ", 0, "\n")
    end
end

