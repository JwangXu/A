import json
import csv
import os.path 
import array as arr

#Script para la unificación de los JSON extraidos por el script de python aenetTemp.py en un fichero .csv
# Estructura final de los datos obtenidos de AEMET
# Comunidad, Año, Mes, Temperatura Media, Mínima, Máxima, Presión Máx, Rachas

#Parámetros para el script
initialYear = 2010
finalYear = 2019
monthDays = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

folder = "Temperatura" #Carpeta donde se encuentran los json
finalFile = "temperaturasEspaña.csv"

# "Valores constantes" para acceder a los datos del array generado por comunidad
COMUNIDAD = 0
ANIO = 1
MES = 2
TEMPERATURA_MED = 3
TEMPERATURA_MAX = 4
TEMPERATURA_MIN = 5
PRESION_MAX = 6
RACHA = 7


#Andalucía, Aragón, Islas Baleares, Cataluña, Canarias, Cantabria, 
# Castilla-La Mancha, Castilla y León, Comunidad de Madrid, 
# Comunidad Foral de Navarra, Comunidad Valenciana, 
# Extremadura, Galicia, 
# País Vasco, Principado de Asturias, 
# Región de Murcia y La Rioja.
# Ceuta y Melilla


arrayMeses = ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"]

#Diccionario para identificar las provincias del json a procesar
dictComunidades = {
    "Andalucia" : {"ALMERIA", "GRANADA", "HUELVA", "CADIZ", "CORDOBA", "SEVILLA", "MALAGA", "JAEN"},
    "Aragón" : {"HUESCA", "ZARAGOZA", "TERUEL"},
    "Islas Baleares" : {"ILLES BALEARS"},
    "Cataluña" : {"TARRAGONA", "GIRONA", "LLEIDA", "BARCELONA"},
    "Canarias" : {"STA. CRUZ DE TENERIFE", "LAS PALMAS"},
    "Cantabria" : {"CANTABRIA", },
    "Castilla-La Mancha" : {"CUENCA", "GUADALAJARA", "CIUDAD REAL", "TOLEDO", "ALBACETE"},
    "Castilla y León" : {"BURGOS", "ZAMORA", "SEGOVIA", "AVILA", "VALLADOLID", "LEON", "SALAMANCA", "PALENCIA", "SORIA"},
    "Comunidad de Madrid" : {"MADRID"},
    "Comunidad Foral de Navarra" : {"NAVARRA"},
    "Comunidad Valenciana" : {"ALICANTE", "VALENCIA", "CASTELLON" },
    "Extremadura" : {"BADAJOZ", "CACERES" },
    "Galicia" : {"OURENSE", "A CORU�A", "LUGO", "PONTEVEDRA", "A CORUï¿½A", "A CORUÑA"},
    "País Vasco" : {"BIZKAIA", "GIPUZKOA", "ARABA/ALAVA"},
    "Principado de Asturias" : {"ASTURIAS"},
    "Región de Murcia" : {"MURCIA", },
    "La Rioja" : {"LA RIOJA"},
    "Ceuta" : {"CEUTA"},
    "Melilla" : {"MELILLA"}
}

#Diccionario para guardar por comunidad, los arrays con los datos de que se van a introducir al .csv
dictDatosComunidades = {
    "Andalucia" : [0]*9,
    "Aragón" : [0]*9,
    "Islas Baleares" :[0]*9,
    "Cataluña" : [0]*9,
    "Canarias" : [0]*9,
    "Cantabria" : [0]*9,
    "Castilla-La Mancha" : [0]*9,
    "Castilla y León" : [0]*9,
    "Comunidad de Madrid" : [0]*9,
    "Comunidad Foral de Navarra" : [0]*9,
    "Comunidad Valenciana" : [0]*9,
    "Extremadura" : [0]*9,
    "Galicia" : [0]*9,
    "País Vasco" : [0]*9,
    "Principado de Asturias" : [0] * 9,
    "Región de Murcia" : [0]*9,
    "La Rioja" : [0]*9,
    "Ceuta" : [0]*9,
    "Melilla" : [0]*9
}

#Diccionario para guardar por comunidad, las veces que aparecen los distintos datos y asi poder realizar la media
dictCommunityAppears = {
    "Andalucia" : [0]*9,
    "Aragón" : [0]*9,
    "Islas Baleares" :[0]*9,
    "Cataluña" : [0]*9,
    "Canarias" : [0]*9,
    "Cantabria" : [0]*9,
    "Castilla-La Mancha" : [0]*9,
    "Castilla y León" : [0]*9,
    "Comunidad de Madrid" : [0]*9,
    "Comunidad Foral de Navarra" : [0]*9,
    "Comunidad Valenciana" : [0]*9,
    "Extremadura" : [0]*9,
    "Galicia" : [0]*9,
    "País Vasco" : [0]*9,
    "Principado de Asturias" : [0]*9,
    "Región de Murcia" : [0]*9,
    "La Rioja" : [0]*9,
    "Ceuta" : [0]*9,
    "Melilla" : [0]*9
}

def initDictArrays(diccionario):
    for comunidad, lista in diccionario.items(): 
        diccionario[comunidad].clear()
        diccionario[comunidad] = [0] * 9 #Iniciar array 
        

def initDictIntValue():
    global dictCommunityAppears
    for comunidad, lista in dictCommunityAppears.items(): 
        dictCommunityAppears[comunidad] = 0 #Iniciar array 


def provinceCommunity(province):
    global dictComunidades, dictCommunityAppears, COMUNIDAD ,ANIO , MES, TEMPERATURA_MED , TEMPERATURA_MAX, TEMPERATURA_MIN , PRESION_MAX, RACHA
    rst = "Comunidad No Encontrada"
    for comunidad, provincia in dictComunidades.items(): 
        #print(comunidad, ":", provincia)
        if(province in dictComunidades[comunidad]):
            rst = comunidad
            #print("La provincia " + province + " esta en la comunidad " + comunidad  + "\n")
            break
    if(rst == ""):
        print("No se ha encontrado la provincia: " + province + " en el conjunto de datos")
    return rst

def buildRowData(fileJSON, jsonLenth, year, month):
    global dictComunidades, dictDatosComunidades,  dictCommunityAppears, COMUNIDAD ,ANIO , MES, TEMPERATURA_MED , TEMPERATURA_MAX, TEMPERATURA_MIN , PRESION_MAX, RACHA
    
    #Almacenar los datos del json
    for i in range(0, (jsonLenth)):
        comunidad = provinceCommunity(fileJSON[i]["provincia"])
        #print("Año " + str(year) + " mes: "+ str(month) + " comunidad " + comunidad )
        #print(str(fileJSON[i]))

        dictDatosComunidades[comunidad][COMUNIDAD] = 0
        dictDatosComunidades[comunidad][ANIO] = year
        dictDatosComunidades[comunidad][MES] = month
        if "tmed" in fileJSON[i]:
            dictDatosComunidades[comunidad][TEMPERATURA_MED] += float(fileJSON[i]["tmed"].replace(",", "."))
            dictCommunityAppears[comunidad][TEMPERATURA_MED] += 1

        if "tmax" in fileJSON[i]:
            dictDatosComunidades[comunidad][TEMPERATURA_MAX] += float(fileJSON[i]["tmax"].replace(",", "."))
            dictCommunityAppears[comunidad][TEMPERATURA_MAX] += 1

        if "tmin" in fileJSON[i]:
            dictDatosComunidades[comunidad][TEMPERATURA_MIN] += float(fileJSON[i]["tmin"].replace(",", "."))
            dictCommunityAppears[comunidad][TEMPERATURA_MIN] += 1

        if "presMax" in fileJSON[i]:
            dictDatosComunidades[comunidad][PRESION_MAX] += float(fileJSON[i]["presMax"].replace(",", "."))
            dictCommunityAppears[comunidad][PRESION_MAX] += 1


        if "racha" in fileJSON[i]:
            dictDatosComunidades[comunidad][RACHA] += float(fileJSON[i]["racha"].replace(",", "."))
            dictCommunityAppears[comunidad][RACHA] += 1

    #Hacer la media
    for comunidad, lista in dictDatosComunidades.items():
        dictDatosComunidades[comunidad][TEMPERATURA_MED] /= dictCommunityAppears[comunidad][TEMPERATURA_MED]
        dictDatosComunidades[comunidad][TEMPERATURA_MAX] /= dictCommunityAppears[comunidad][TEMPERATURA_MAX]
        dictDatosComunidades[comunidad][TEMPERATURA_MIN] /= dictCommunityAppears[comunidad][TEMPERATURA_MIN]
        dictDatosComunidades[comunidad][PRESION_MAX] /= dictCommunityAppears[comunidad][PRESION_MAX]
        dictDatosComunidades[comunidad][RACHA] /= dictCommunityAppears[comunidad][RACHA]

def buildCSVData(fileJSON, jsonLenth, year, month):
    global dictComunidades, dictDatosComunidades, dictCommunityAppears, COMUNIDAD ,ANIO , MES, TEMPERATURA_MED , TEMPERATURA_MAX, TEMPERATURA_MIN , PRESION_MAX, RACHA
    mode = ""
    if os.path.isfile(finalFile):
        mode = "a"
    else:
        mode = "w+"

    #Construir los datos para un determinado fichero(mes y año)
    initDictArrays(dictDatosComunidades) #Incializar los arrays con datos para la nueva fila
    initDictArrays(dictCommunityAppears) #Incializar los arrays con datos para la nueva fila
    #initDictIntValue() #Incializar el valor del numero de veces que ha aperecido una comunidad en el json
    buildRowData(fileJSON, jsonLenth, year, month)

    #Escribir los datos en el fichero 
    with open(finalFile, mode, newline='', encoding='utf-8') as file:
        writer = csv.writer(file)
        if mode == "w+":
            writer.writerow(["Comunidad", "Año", "Mes", "Temperatura Media", "Temperatura Minima", "Temperatura Maxima", "Presion Maxima", "Racha"])
        #Escribir los datos almacenados en el diccionario en el .csv
        for comunidad, lista in dictDatosComunidades.items():
            rowData = dictDatosComunidades[comunidad]
            rowData[TEMPERATURA_MED] = str(round(rowData[TEMPERATURA_MED], 2))
            rowData[TEMPERATURA_MIN] = str(round(rowData[TEMPERATURA_MIN], 2))
            rowData[TEMPERATURA_MAX] = str(round(rowData[TEMPERATURA_MAX], 2))
            rowData[PRESION_MAX] = str(round(rowData[PRESION_MAX], 2))
            rowData[RACHA] = str(round(rowData[RACHA], 2))
            writer.writerow([comunidad, rowData[ANIO], arrayMeses[rowData[MES]-1], rowData[TEMPERATURA_MED], rowData[TEMPERATURA_MIN], rowData[TEMPERATURA_MAX], rowData[PRESION_MAX], rowData[RACHA]])

#finalYear = initialYear
meses = 12

def main():
    for i in range(initialYear, finalYear+1):
        for j in range(1, (meses+1)):
            print("Unificando datos para el año %s en el mes %s...\n"%(i, j))
            fileName = folder + "/temp_%s_%s.json"%(i, j) #i = year, j = month, 1 = dia lo dejamos fijo
            with open(fileName, "r") as file:
                fileJSON = json.load(file)
                jsonLenth = len(fileJSON)
                print("Numero de datos en el fichero: %s\n"%(jsonLenth))
                buildCSVData(fileJSON, jsonLenth, i, j)


main()