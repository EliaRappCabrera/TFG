# Código para preparar los datos
using DataFrames
using CSVFiles
using DelimitedFiles
using Dates
using Statistics

# Se crean los Dataframes con la imformación aportada por 
# AENA.
dfvuelos = DataFrame(load("FronTur2022.csv", delim=';', 
        header_exists=true, colnames=["W21R", "DestinoR", 
            "Destino", "Código", "Dia_semana", 
            "Opera_desde", "Opera_hasta","Hora_Salida",
            "Tipo_aeronave", "Num_vuelo", "Región", 
            "Escala", "Origen"]))

# Se eliminan dos columnas que no aportan información para 
# el estudio.
dfvuelos = dfvuelos[:, Not(1,2)]

# Se obtiene los parámetros desde un archivo tipo csv.
Parámetros = DataFrame(load("Parámetros.csv", delim=';', 
        header_exists=true))

# Vector de índices de los entrevistadores.
K = range(1,Parámetros[1, "Num_entrevist"])

# Para el cálculo de las siguientes variables se necesita 
# elegir un único aeropuerto de origen. 
# Por ejemplo, tomaremos TFN.
dfvuelos = subset(dfvuelos, :Origen => ByRow(==("TFN")))

# Se crea otro Dataframe con la información sobre los 
# asientos de cada aeronave.
dfasientos = DataFrame(load("asientosTFG.csv", delim=',', 
        header_exists=true, colnames=["Código_nave", 
            "Num_asientos", "Modelo"]))

# Se combinan los dataframes para que en la tabla de los 
# vuelos se tenga una columna con la cantidad de asientos 
# de cada aeronave.
vuelos = innerjoin(dfvuelos, dfasientos, 
    on=:Tipo_aeronave=>:Código_nave)

# Se añade el fichero que contiene la semana seleccionada 
# en el fichero parámetros.
if Parámetros[1,"Semana"] == "Semana_1"
    Semana = DataFrame(readdlm("Semana_1.txt", '\t'), 
        ["Semana"])
end
if Parámetros[1,"Semana"] == "Semana_2"
    Semana = DataFrame(readdlm("Semana_2.txt", '\t'), 
        ["Semana"])
end
if Parámetros[1,"Semana"] == "Semana_3"
    Semana = DataFrame(readdlm("Semana_3.txt", '\t'), 
        ["Semana"])
end
if Parámetros[1,"Semana"] == "Semana_4"
    Semana = DataFrame(readdlm("Semana_4.txt", '\t'), 
        ["Semana"])
end

# Se calcula que día de la semana corresponde a cada 
# fecha del archivo semana.
Semana[!,"d_semana"] = copy(Semana[!,"Semana"])
Semana[!,"n_semana"] = copy(Semana[!,"Semana"])

for s in range(1,length(Semana.Semana))
    Semana[s, "n_semana"] = 
    Dates.dayofweek(Date(Semana[s,"Semana"]))
end

NumDias = [1, 2, 3, 4, 5, 6, 7]
LetraDias = ["L", "M", "X", "J", "V", "S", "D"]

for d in range(1,length(NumDias))
    for s in range(1,length(Semana.Semana))
        if Semana[s, "n_semana"] == NumDias[d]
            Semana[s, "d_semana"] = LetraDias[d]
        end
    end
end

# Se filtra para solo tener los vuelos que operan en la 
# semana seleccionada.
vuelos = subset(vuelos, :Opera_desde => 
    ByRow(<=(Date(Semana[length(Semana.Semana), 
                    "Semana"]))))
vuelos = subset(vuelos, :Opera_hasta => 
    ByRow(>=(Date(Semana[1, "Semana"]))))

# Se cambia la región de los aeropuertos de España por 
# el destino, que son "ComunidadesAutónomas-Aeropuerto".
for i in range(1,length(vuelos.Región))
    if vuelos[i,"Región"] == "ESPANIA"||
        vuelos[i,"Región"] == "ESPAÑA"||
        vuelos[i,"Región"] =="ESPAﾑA"
        vuelos[i, "Región"] = vuelos[i, "Destino"]
    end
end

# Se cambia la región de los aeropuertos de Canarias 
# por "CANARIAS".
for i in range(1,length(vuelos.Región))
    if vuelos[i,"Código"] == "LPA"||
        vuelos[i,"Código"] == "ACE"||
        vuelos[i,"Código"] == "FUE"||
        vuelos[i,"Código"] == "SPC"||
        vuelos[i,"Código"] == "TFN"||
        vuelos[i,"Código"] == "TFS"||
        vuelos[i,"Código"] == "VDE"||
        vuelos[i,"Código"] == "GMZ"
        vuelos[i, "Región"] = "CANARIAS"
    end
end

# Se modifica la columna Dia_semana.
vuelosL = copy(vuelos)
vuelosM = copy(vuelos)
vuelosX = copy(vuelos)
vuelosJ = copy(vuelos)
vuelosV = copy(vuelos)
vuelosS = copy(vuelos)
vuelosD = copy(vuelos)
for i in range(1,length(vuelos.Num_vuelo))
    if 'L' in vuelosL[i,"Dia_semana"] && "L" in 
        Semana.d_semana
         vuelosL[i,"Dia_semana"] = "L"
    end
    if 'M' in vuelosM[i,"Dia_semana"] && "M" in 
        Semana.d_semana
         vuelosM[i,"Dia_semana"] = "M"
    end
    if 'X' in vuelosX[i,"Dia_semana"] && "X" in 
        Semana.d_semana
         vuelosX[i,"Dia_semana"] = "X"
    end
    if 'J' in vuelosJ[i,"Dia_semana"] && "J" in 
        Semana.d_semana
         vuelosJ[i,"Dia_semana"] = "J"
    end
    if 'V' in vuelosV[i,"Dia_semana"] && "V" in 
        Semana.d_semana
         vuelosV[i,"Dia_semana"] = "V"
    end
    if 'S' in vuelosS[i,"Dia_semana"] && "S" in 
        Semana.d_semana
         vuelosS[i,"Dia_semana"] = "S"
    end
    if 'D' in vuelosD[i,"Dia_semana"] && "D" in 
        Semana.d_semana
         vuelosD[i,"Dia_semana"] = "D"
    end
end
vuelosL = subset(vuelosL, :Dia_semana => 
    ByRow(==("L")))
vuelosM = subset(vuelosM, :Dia_semana => 
    ByRow(==("M")))
vuelosX = subset(vuelosX, :Dia_semana => 
    ByRow(==("X")))
vuelosJ = subset(vuelosJ, :Dia_semana => 
    ByRow(==("J")))
vuelosV = subset(vuelosV, :Dia_semana => 
    ByRow(==("V")))
vuelosS = subset(vuelosS, :Dia_semana => 
    ByRow(==("S")))
vuelosD = subset(vuelosD, :Dia_semana => 
    ByRow(==("D")))
vuelos = vcat(vuelosL,vuelosM,vuelosX,vuelosJ,vuelosV,
    vuelosS, vuelosD)

# Se agrupa por región y se calcula el número total 
# de asientos.
using Statistics
gregion = groupby(vuelos, :Región)
dfRegion = combine(gregion, :Num_asientos => sum, nrow)

# Se multiplica la columna de asientos totales por la 
# ocupación supuesta (80%).
dfRegion[!,"Ocupacion_region"]=
dfRegion[!,"Num_asientos_sum"]*Parámetros[1, "ocupación"]

# Se añade la informacion proporcionada por AENA donde 
# se representan las equivalencias de pasajeros y encuestas 
# mínimas.
tablamin = DataFrame(readdlm("tablamin.txt", ','), 
    ["hasta_pasajeros", "min_num"])
tablamin = tablamin[Not(1),:]
for i in range(1,length(dfRegion.Num_asientos_sum))
    if dfRegion[i, "Num_asientos_sum"]<
        tablamin[1, "hasta_pasajeros"]
        dfRegion[i, "nrow"]=tablamin[1, "min_num"]
    elseif tablamin[1, "hasta_pasajeros"]<=
        dfRegion[i, "Num_asientos_sum"]<
        tablamin[2, "hasta_pasajeros"]
        dfRegion[i, "nrow"]=tablamin[2, "min_num"]
    elseif tablamin[2, "hasta_pasajeros"]<=
        dfRegion[i, "Num_asientos_sum"]<
        tablamin[3, "hasta_pasajeros"]
        dfRegion[i, "nrow"]=tablamin[3, "min_num"]
    elseif tablamin[3, "hasta_pasajeros"]<=
        dfRegion[i, "Num_asientos_sum"]<
        tablamin[4, "hasta_pasajeros"]
        dfRegion[i, "nrow"]=tablamin[4, "min_num"]
    elseif tablamin[4, "hasta_pasajeros"]<=
        dfRegion[i, "Num_asientos_sum"]<
        tablamin[5, "hasta_pasajeros"]
         dfRegion[i, "nrow"]=tablamin[5, "min_num"]
    elseif tablamin[5, "hasta_pasajeros"]<=
        dfRegion[i, "Num_asientos_sum"]<
        tablamin[6, "hasta_pasajeros"]
        dfRegion[i, "nrow"]=tablamin[6, "min_num"]
    elseif dfRegion[i, "Num_asientos_sum"]>=
        tablamin[6, "hasta_pasajeros"]
        dfRegion[i, "nrow"]=tablamin[7, "min_num"] 
    end
end
rename!(dfRegion,:nrow => :Num_mues_min)   

# Se crea una columna con las horas y otra con los minutos 
# en la tabla vuelos.
Horas=1:length(vuelos.Hora_Salida)
vuelos[!,"HorasS"]=copy(vuelos[!,"Hora_Salida"])
vuelos[!,"Horas"]=Horas
for i in range(1,length(vuelos.Hora_Salida))
    vuelos[i,"HorasS"]=split(vuelos[i,"HorasS"],":")[1]
    vuelos[i,"Horas"]=parse(Int8,vuelos[i,"HorasS"])
end

Minutos=1:length(vuelos.Hora_Salida)
vuelos[!,"MinutosS"]=copy(vuelos[!,"Hora_Salida"])
vuelos[!,"Minutos"]=Minutos
for i in range(1,length(vuelos.Hora_Salida))
    vuelos[i,"MinutosS"]=split(vuelos[i,"MinutosS"],":")[2]
    vuelos[i,"Minutos"]=parse(Int8,vuelos[i,"MinutosS"])
end  

# Se crea otra columna donde se pasan las horas de salida a 
# minutos para las comparaciones posteriores.
 vuelos[!,"Tiempo_minutos"] = 
vuelos[!,"Horas"]*60+vuelos[!,"Minutos"]

# Se añade una nueva columna que contiene la cantidad de 
# encuestas posibles para cada vuelo, teniendo en cuenta 
# la cantidad de pasajeros y el éxito supuestos al principio.
vuelos[!,"Encuestas"]=vuelos[!,"Num_asientos"]*
Parámetros[1,"ocupación"]*Parámetros[1,"éxito"]
for i in range(1,length(vuelos.Encuestas))
     vuelos[i,"Encuestas"] = 
    round(Int, vuelos[i,"Encuestas"])
end

# Se calcula el tiempo que tarda en encuestarse cada vuelo, 
# utilizando la variable velocidad y cantidad de encuestas.
vuelos[!,"Consumo(min)"]=vuelos[!,"Encuestas"]*
Parámetros[1,"velocidad_minutos"]

# Se calcula la cantidad máxima de encuestas de cada región.
gregion = groupby(vuelos, :Región)
gregionMaxE = combine(gregion, :Encuestas => sum)
dfRegion = innerjoin(dfRegion, gregionMaxE, 
    on=:Región=>:Región)
rename!(dfRegion,:Encuestas_sum => :Max_encuestas)       
vuelos = innerjoin(vuelos, dfRegion, on=:Región=>:Región)

# Se calcula el número de regiones a las que llegan los 
# vuelos con origen TFN en la semana seleccionada, para 
# crear el vector P cuyo tamaño es el total de regiones.
Num_Regiones = nrow(dfRegion)
P = range(1,Num_Regiones)

# Se calcula el número de vuelos que salen de TFN en la 
# semana seleccionada, para crear el vector I que cuyo 
# tamaño es el total de vuelos.
Num_vuelos = nrow(vuelos)
I = range(1,Num_vuelos)

# Se eliminan columnas innecesarias.
vuelos = vuelos[:, Not(4,5,7,10,12,13,14,16,21)]
vuelos = sort(vuelos,[:Tiempo_minutos])

# Se crea el vector J, que coincide en tamaño con el 
# vector K. Este nuevo vector se utilizará en la 
# configuración de cada vuelo para el segundo modelo.
J = K
