#encoding: utf-8
import csv
import pandas
import re
import os, sys

#Valores constantes para acceder en order a los datos del .csv desde 2013 hasta 2016

COMUNIDAD = 0
ANIO = 1
TRIMESTRE = 2
TIPO_DE_DELITO = 3
DENUNCIAS = 4
TRIMESTRE_ACTUAL = 1

#Diccionario para traducir los nombres de las comunidades

dictComunidades = {
    "Andalucía" : {"ANDALUCÍA", "Andalucia", "ANDALUCÖA"},
    "Aragón" : {"ARAGÓN", "ARAGàN", "Aragon"},
    "Principado de Asturias" : {"ASTURIAS (PRINCIPADO DE)", "Asturias"},
    "Islas Baleares" : {"BALEARS (ILLES)", "Baleares"},
    "Canarias" : {"CANARIAS", "Canarias"},
    "Cantabria" : {"CANTABRIA", "Cantabria"},
    "Castilla y León" : {"CASTILLA Y LEàN", "CASTILLA Y LEON", "CastillaYLeon", "CASTILLA Y LEÓN"},
    "Castilla-La Mancha" : {"CASTILLA - LA MANCHA", "CastillaLaMancha"},
    "Cataluña" : {"CATALU¥A", "CATALUÑA", "Cataluña"},
    "Comunidad Valenciana" : {"COMUNITAT VALENCIANA", "Valencia"},
    "Extremadura" : {"EXTREMADURA", "Extremadura"},
    "Galicia" : {"GALICIA", "Galicia"},
    "Comunidad de Madrid" : {"MADRID (COMUNIDAD DE)", "Madrid"},
    "Región de Murcia" : {"MURCIA (REGIàN DE)", "MURCIA (REGION DE)", "Murcia", "MURCIA (REGIÓN DE)"},
    "Comunidad Foral de Navarra" : {"NAVARRA (COMUNIDAD FORAL DE)", "Navarra"},
    "País Vasco" : {"PAÖS VASCO", "PAÍS VASCO", "PaisVasco"},
    "La Rioja" : {"RIOJA (LA)", "LaRioja"},
    "Ceuta" : {"CIUDAD AUTàNOMA DE CEUTA", "CIUDAD AUTÓNOMA DE CEUTA", "Ceuta"},
    "Melilla" : {"CIUDAD AUTàNOMA DE MELILLA", "CIUDAD AUTÓNOMA DE MELILLA", "Melilla"}
}

#Diccionario con los tipos de crimenes clasificados

dictDelitos = {
    "Homicidios dolosos y asesinatos consumados" : {"2.-HOMICIDIOS DOLOSOS Y ASESINATOS CONSUMADOS (EU)", "Homicidios dolosos y asesinatos consumados"},
    "Hurtos" : {"8.-HURTOS", "Hurtos"},
    "Robos con fuerza, violencia o intimidación" : {"3.1.-ROBO CON VIOLENCIA E INTIMIDACIàN (EU)", "3.-DELINCUENCIA VIOLENTA (EU)", "4.-ROBOS CON FUERZA", "Robos con fuerza en domicilios, establecimientos y otras instalaciones", "Robos con violencia e intimidación", "Robos con fuerza, violencia o intimidación"},
    "Sustracciones de vehículos" : {"5.-SUSTRACCIàN VEHÖCULOS A MOTOR (EU)", "5.-SUSTRACCIÓN VEHÍCULOS A MOTOR (EU)", "Sustracciones de vehículos"},
    "Tráfico de drogas" : {"6.-TRµFICO DE DROGAS (EU)", "6.-TRÁFICO DE DROGAS (EU)", "Tráfico de drogas"},
    "Otros" : {"7.-DA¥OS", "1.-DELITOS Y FALTAS (EU)", "Agresión sexual con penetración"}
}

diccSegundoFormato = {
    "2017" : {"Trimestre 3" : {"Homicidios dolosos y asesinatos consumados" : 0,
                                "Hurtos" : 0,
                                "Robos con fuerza, violencia o intimidación" : 0,
                                "Sustracciones de vehículos" : 0,
                                "Tráfico de drogas" : 0,
                                "Otros" : 0},
            "Trimestre 4" : {"Homicidios dolosos y asesinatos consumados" : 0,
                                "Hurtos" : 0,
                                "Robos con fuerza, violencia o intimidación" : 0,
                                "Sustracciones de vehículos" : 0,
                                "Tráfico de drogas" : 0,
                                "Otros" : 0}},
    "2018" : {  "Trimestre 1" : {"Homicidios dolosos y asesinatos consumados" : 0,
                                "Hurtos" : 0,
                                "Robos con fuerza, violencia o intimidación" : 0,
                                "Sustracciones de vehículos" : 0,
                                "Tráfico de drogas" : 0,
                                "Otros" : 0},
                "Trimestre 2" : {"Homicidios dolosos y asesinatos consumados" : 0,
                                "Hurtos" : 0,
                                "Robos con fuerza, violencia o intimidación" : 0,
                                "Sustracciones de vehículos" : 0,
                                "Tráfico de drogas" : 0,
                                "Otros" : 0},
                "Trimestre 3" : {"Homicidios dolosos y asesinatos consumados" : 0,
                                "Hurtos" : 0,
                                "Robos con fuerza, violencia o intimidación" : 0,
                                "Sustracciones de vehículos" : 0,
                                "Tráfico de drogas" : 0,
                                "Otros" : 0},
                "Trimestre 4" : {"Homicidios dolosos y asesinatos consumados" : 0,
                                "Hurtos" : 0,
                                "Robos con fuerza, violencia o intimidación" : 0,
                                "Sustracciones de vehículos" : 0,
                                "Tráfico de drogas" : 0,
                                "Otros" : 0}
    },
    "2019" : {  "Trimestre 1" : {"Homicidios dolosos y asesinatos consumados" : 0,
                                "Hurtos" : 0,
                                "Robos con fuerza, violencia o intimidación" : 0,
                                "Sustracciones de vehículos" : 0,
                                "Tráfico de drogas" : 0,
                                "Otros" : 0},
                "Trimestre 2" : {"Homicidios dolosos y asesinatos consumados" : 0,
                                "Hurtos" : 0,
                                "Robos con fuerza, violencia o intimidación" : 0,
                                "Sustracciones de vehículos" : 0,
                                "Tráfico de drogas" : 0,
                                "Otros" : 0},
                "Trimestre 3" : {"Homicidios dolosos y asesinatos consumados" : 0,
                                "Hurtos" : 0,
                                "Robos con fuerza, violencia o intimidación" : 0,
                                "Sustracciones de vehículos" : 0,
                                "Tráfico de drogas" : 0,
                                "Otros" : 0},
                "Trimestre 4" : {"Homicidios dolosos y asesinatos consumados" : 0,
                                "Hurtos" : 0,
                                "Robos con fuerza, violencia o intimidación" : 0,
                                "Sustracciones de vehículos" : 0,
                                "Tráfico de drogas" : 0,
                                "Otros" : 0}
    }
}

def inicializarDicDelCom():
    diccContadorComunidades = {
        "Andalucía" : {
        "Homicidios dolosos y asesinatos consumados" : 0,
        "Hurtos" : 0,
        "Robos con fuerza, violencia o intimidación" : 0,
        "Sustracciones de vehículos" : 0,
        "Tráfico de drogas" : 0,
        "Otros" : 0
        },
        "Aragón" : {
            "Homicidios dolosos y asesinatos consumados" : 0,
            "Hurtos" : 0,
            "Robos con fuerza, violencia o intimidación" : 0,
            "Sustracciones de vehículos" : 0,
            "Tráfico de drogas" : 0,
            "Otros" : 0
        },
        "Principado de Asturias" : {
        "Homicidios dolosos y asesinatos consumados" : 0,
        "Hurtos" : 0,
        "Robos con fuerza, violencia o intimidación" : 0,
        "Sustracciones de vehículos" : 0,
        "Tráfico de drogas" : 0,
        "Otros" : 0
        },
        "Islas Baleares" : {
        "Homicidios dolosos y asesinatos consumados" : 0,
        "Hurtos" : 0,
        "Robos con fuerza, violencia o intimidación" : 0,
        "Sustracciones de vehículos" : 0,
        "Tráfico de drogas" : 0,
        "Otros" : 0
        },
        "Canarias" : {
        "Homicidios dolosos y asesinatos consumados" : 0,
        "Hurtos" : 0,
        "Robos con fuerza, violencia o intimidación" : 0,
        "Sustracciones de vehículos" : 0,
        "Tráfico de drogas" : 0,
        "Otros" : 0
        },
        "Cantabria" : {
        "Homicidios dolosos y asesinatos consumados" : 0,
        "Hurtos" : 0,
        "Robos con fuerza, violencia o intimidación" : 0,
        "Sustracciones de vehículos" : 0,
        "Tráfico de drogas" : 0,
        "Otros" : 0
        },
        "Castilla y León" : {
        "Homicidios dolosos y asesinatos consumados" : 0,
        "Hurtos" : 0,
        "Robos con fuerza, violencia o intimidación" : 0,
        "Sustracciones de vehículos" : 0,
        "Tráfico de drogas" : 0,
        "Otros" : 0
        },
        "Castilla-La Mancha" : {
        "Homicidios dolosos y asesinatos consumados" : 0,
        "Hurtos" : 0,
        "Robos con fuerza, violencia o intimidación" : 0,
        "Sustracciones de vehículos" : 0,
        "Tráfico de drogas" : 0,
        "Otros" : 0
        },
        "Cataluña" : {
        "Homicidios dolosos y asesinatos consumados" : 0,
        "Hurtos" : 0,
        "Robos con fuerza, violencia o intimidación" : 0,
        "Sustracciones de vehículos" : 0,
        "Tráfico de drogas" : 0,
        "Otros" : 0
        },
        "Comunidad Valenciana" : {
        "Homicidios dolosos y asesinatos consumados" : 0,
        "Hurtos" : 0,
        "Robos con fuerza, violencia o intimidación" : 0,
        "Sustracciones de vehículos" : 0,
        "Tráfico de drogas" : 0,
        "Otros" : 0
        },
        "Extremadura" : {
        "Homicidios dolosos y asesinatos consumados" : 0,
        "Hurtos" : 0,
        "Robos con fuerza, violencia o intimidación" : 0,
        "Sustracciones de vehículos" : 0,
        "Tráfico de drogas" : 0,
        "Otros" : 0
        },
        "Galicia" : {
        "Homicidios dolosos y asesinatos consumados" : 0,
        "Hurtos" : 0,
        "Robos con fuerza, violencia o intimidación" : 0,
        "Sustracciones de vehículos" : 0,
        "Tráfico de drogas" : 0,
        "Otros" : 0
        },
        "Comunidad de Madrid" : {
        "Homicidios dolosos y asesinatos consumados" : 0,
        "Hurtos" : 0,
        "Robos con fuerza, violencia o intimidación" : 0,
        "Sustracciones de vehículos" : 0,
        "Tráfico de drogas" : 0,
        "Otros" : 0
        },
        "Región de Murcia" : {
        "Homicidios dolosos y asesinatos consumados" : 0,
        "Hurtos" : 0,
        "Robos con fuerza, violencia o intimidación" : 0,
        "Sustracciones de vehículos" : 0,
        "Tráfico de drogas" : 0,
        "Otros" : 0
        },
        "Comunidad Foral de Navarra" : {
        "Homicidios dolosos y asesinatos consumados" : 0,
        "Hurtos" : 0,
        "Robos con fuerza, violencia o intimidación" : 0,
        "Sustracciones de vehículos" : 0,
        "Tráfico de drogas" : 0,
        "Otros" : 0
        },
        "País Vasco" : {
        "Homicidios dolosos y asesinatos consumados" : 0,
        "Hurtos" : 0,
        "Robos con fuerza, violencia o intimidación" : 0,
        "Sustracciones de vehículos" : 0,
        "Tráfico de drogas" : 0,
        "Otros" : 0
        },
        "La Rioja" : {
        "Homicidios dolosos y asesinatos consumados" : 0,
        "Hurtos" : 0,
        "Robos con fuerza, violencia o intimidación" : 0,
        "Sustracciones de vehículos" : 0,
        "Tráfico de drogas" : 0,
        "Otros" : 0
        },
        "Ceuta" : {
        "Homicidios dolosos y asesinatos consumados" : 0,
        "Hurtos" : 0,
        "Robos con fuerza, violencia o intimidación" : 0,
        "Sustracciones de vehículos" : 0,
        "Tráfico de drogas" : 0,
        "Otros" : 0
        },
        "Melilla" : {
        "Homicidios dolosos y asesinatos consumados" : 0,
        "Hurtos" : 0,
        "Robos con fuerza, violencia o intimidación" : 0,
        "Sustracciones de vehículos" : 0,
        "Tráfico de drogas" : 0,
        "Otros" : 0
        }
    }
    return diccContadorComunidades

def encontrarComunidad(comunidad_mal):
    global dictComunidades, COMUNIDAD ,ANIO , TIPO_DE_DELITO, DENUNCIAS, TRIMESTRE_ACTUAL, diccSegundoFormato
    rst = "Comunidad no encontrada"
    for comunidad, comunidade in dictComunidades.items(): 
        if(comunidad_mal in dictComunidades[comunidad]):
            rst = comunidad
            break
    if(rst == ""):
        print("No se ha encontrado la comunidad: " + comunidad_mal + " en el conjunto de datos")
    return rst

def encontrarDelito(delito_mal):
    rst = "Delito no encontrado"
    for delito, delite in dictDelitos.items(): 
        #print(comunidad, ":", provincia)
        if(delito_mal in dictDelitos[delito]):
            rst = delito
            #print("La provincia " + province + " esta en la comunidad " + comunidad  + "\n")
            break
    if(rst == ""):
        print("No se ha encontrado el delito: " + delito_mal + " en el conjunto de datos")
    return rst

def cambiaTrimestre(trimestre):
    return trimestre != TRIMESTRE_ACTUAL

def separarDatos(d):
    datoComillas = re.split(r';', d)
    if len(datoComillas) == 4:
        dat1 = datoComillas[0]
        dat2 = re.split(r'"',datoComillas[1])
        dat3 = re.split(r'"',datoComillas[2])
        dat4 = re.split(r'"',datoComillas[3])
        return [dat1, dat2[1], dat3[1], dat4[1]]
    else:
        return []

def procesarArchivo():
    result = pandas.DataFrame(columns=['Comunidad','Año','Trimestre','Tipo de delito','Denuncias'])
    files = os.listdir('C:/Users/David/Desktop/Mineria Dataset Criminalidad/Fuente Dataset')
    fileNames = []
    fileNames2 = []
    for file in files:
        if (file.endswith('trimestre.csv')):
            fileNames.append('C:/Users/David/Desktop/Mineria Dataset Criminalidad/Fuente Dataset/' + file)
        elif (file.endswith('.csv')):
            fileNames2.append('C:/Users/David/Desktop/Mineria Dataset Criminalidad/Fuente Dataset/' + file)
    for fileAct in fileNames:
        nombreArchivo = re.split(r'/', str(fileAct))[6]
        anio = re.split(r'_', str(nombreArchivo))[1]
        trimestre = 'Trimestre ' + re.split(r'_', str(nombreArchivo))[2]
        diccContadorComunidades = inicializarDicDelCom()
        data = pandas.read_csv(fileAct, encoding='latin-1')
        for i in range(0, len(data)):
            d = data.iloc[i].name
            datos_separados = re.split(r';', d)
            comunidad = encontrarComunidad(datos_separados[0])
            tipo = encontrarDelito(datos_separados[1])
            if (comunidad != "Comunidad no encontrada" and tipo != "Delito no encontrado"):
                resultado=re.sub('[\.-]','', datos_separados[3])
                diccContadorComunidades[comunidad][tipo] += int(resultado)
        for comunidad, tipo_dicc in diccContadorComunidades.items():
            for tipo_delito, cantidad in tipo_dicc.items():
                if (comunidad != "Comunidad no encontrada" and tipo != "Delito no encontrado"):
                    trimestre_limpio = re.split(r' ', str(trimestre))[1]
                    result = result.append({'Comunidad' : comunidad, 'Año' : anio, 'Trimestre' : trimestre_limpio, 'Tipo de delito' : tipo_delito, 'Denuncias' : cantidad},ignore_index=True)
    for fileAct in fileNames2:
        a = re.split(r'/', str(fileAct))[6]
        comunidad = re.sub(r'.csv', '', a)
        comunidad = re.split(r'_', str(comunidad))[1]
        comunidad = encontrarComunidad(comunidad)
        data = pandas.read_csv(fileAct, error_bad_lines=False)
        diccContadorComunidades = inicializarDicDelCom()
        for i in range(0, len(data)):
            d = data.iloc[i, 0]
            res = separarDatos(d)
            if res != []:
                tipo = encontrarDelito(res[2])
                if (comunidad != "Comunidad no encontrada" and tipo != "Delito no encontrado"):
                    resultado=re.sub('[\.-]','', res[3])
                    diccSegundoFormato[res[0]][res[1]][tipo] += int(resultado)
        if (comunidad != "Comunidad no encontrada" and tipo != "Delito no encontrado"):
            for anio, trimestre in diccSegundoFormato.items():
                for trimestre_actual, delito in trimestre.items():
                    for tipo_delito, cantidad in delito.items():
                        if (comunidad != "Comunidad no encontrada" and tipo != "Delito no encontrado"):
                            trimestre_limpio = re.split(r' ', str(trimestre_actual))[1]
                            result = result.append({'Comunidad' : comunidad, 'Año' : anio, 'Trimestre' : trimestre_actual, 'Tipo de delito' : tipo_delito, 'Denuncias' : cantidad},ignore_index=True)
        data.drop(data.columns, axis=1)
    result.sort_values(by=['Año', 'Trimestre'], inplace=True)
    result.to_csv('Criminalidad.csv', index=False)                



procesarArchivo()