#DNSO Script de Obtención de Temperaturas para la Asignatura de Minería de Datos
import http.client
import requests
import json

#El programa tiene un porcentaje de error, mi teoria es que el fallo se produce en las peticiones HTTP
#Con el registro que produce el programa bastaría con cambiar la fecha de inicio para no empezar de cero
# y volver a ejecutar el programa... (Puede que falle cada X peticiones o por las peticiones constantes, igual con un sleep es constante)

headers = {
    'cache-control': "no-cache"
}

#Parámetros para el script
initialYear = 2010
finalYear = 2019

apiKey = "" #Necesitas un key para usar el programa (no voy a dar la mia xD) si quieres una https://opendata.aemet.es/centrodedescargas/altaUsuario? 
monthDays = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

# Si el numero es 2 --> 02, para fechas
def formatNumberForRequest(n):
    n = str(n)
    return n.rjust(2, "0") 


def buildRequestURL(year, month):
    day = formatNumberForRequest(1)#Empezamos en el dia 1
    finalDay = formatNumberForRequest(monthDays[month-1])

    month = formatNumberForRequest(month)
    year = str(year)
    
    iniDate = "%s-%s-%sT10:00:00UTC"%(year, month, day)
    finalDate = "%s-%s-%sT10:00:00UTC"%(year, month, finalDay)
    print("Fecha Inicial: " + iniDate)
    print("Fecha Final: " + finalDate)
    url = "/opendata/api/valores/climatologicos/diarios/datos/fechaini/%s/fechafin/%s/todasestaciones/?api_key=%s"%(iniDate, finalDate, apiKey)
    return url

def runRequestAndSave(url, year, month):

    conn = http.client.HTTPSConnection("opendata.aemet.es")
    conn.request("GET", url , headers=headers)

    res = conn.getresponse()
    data = res.read()

    resString = data.decode("utf-8") # Resultado de la peticion en formato de texto
    resJson = json.loads(resString) # Resultado de la peticion en JSON

    #print(resString) #Mostrar estrucutra JSON con enlace a datos y metadatos

    linkDatos = resJson["datos"] #Link a los datos
    f = requests.get(linkDatos)

    #Escribir información en fichero
    fileName = "temp_%s_%s.json"%(year, month) #temp_año_mes.json
    path = "Temperatura/%s"%(fileName)
    print("Guardando la información... \n")
    with open(path, "w+") as file:
        file.write(f.text)
        print("Información guardada en %s... \n"%(path))


def main():
    for i in range(initialYear, finalYear+1):
        for j in range(1, (12+1)):
            print("Preparando petición para el año %s en el mes %s"%(i, j))
            url = buildRequestURL(i, j) #i = year, j = month, 1 = dia lo dejamos fijo
            runRequestAndSave(url, i, j)


main()