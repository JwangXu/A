#encoding: utf-8
import os
import json
import csv
import re
def main():
    os.chdir(os.path.dirname(os.path.abspath(__file__)))

    #Preparamos el csv
    with open('deuda.csv', 'w') as archivo_csv:
             cabecera = ['Comunidades', 'Años', 'Trimestre', 'PIB']
             writer = csv.DictWriter(archivo_csv, fieldnames=cabecera, restval='')
             writer.writeheader()

             files = os.listdir("deuda/")
             fileNames = []
             for file in files:
                  if(file.endswith('.json')):
                      fileNames.append("deuda/" + file)
    
             for fileAct in fileNames:
                  separador = re.split(r'/', str(fileAct))[1]
                  comunidad = re.sub(r'.json', '', separador)
                  nombreArchivo = fileAct


                  with open(nombreArchivo) as archivo:
                      datos = json.load(archivo)
                      for metricas in datos['Datos']['Metricas']:
                          if metricas['Id'] == 0: #Solo escogemos los de esta comunidad
                              for valores in metricas['Datos']:
                                  valoresNuevos = {'Comunidades' : comunidad, 'Años' : valores['Agno'], 'Trimestre' : valores['Periodo'], 'PIB' : valores['Valor']}#Cambiamos el nombreArchivo de las claves
                                  writer.writerow(valoresNuevos)

main()