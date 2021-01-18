#encoding: utf-8
import os, sys
import pandas as pd
import numpy as np
import re

def limpieza(prueba):
    lol = re.split(r';', prueba)
    dat1 = lol[0]
    dat2 = re.split(r'"',lol[1])
    dat3 = re.split(r'"',lol[2])
    return [dat1, dat2[1], dat3[1]]

result = pd.DataFrame(columns=['Comunidad','Año','Mes','Numero Paradas'])
files = os.listdir("paro/")
fileNames = []
for file in files:
    if(file.endswith('.csv')):
        fileNames.append("paro/" + file)
for fileAct in fileNames:
    a = re.split(r'/', str(fileAct))[1]
    comunidad = re.sub(r'.csv', '', a)
    data = pd.read_csv(fileAct)
    for i in range(0, len(data)):
        prueba = data.iloc[i, 0]
        res = limpieza(prueba)
        result = result.append({'Comunidad' : comunidad, 'Año' : res[0], 'Mes' : res[1], 'Numero Paradas' : res[2]},ignore_index=True)	
    data.drop(data.columns, axis=1)

result.sort_values(by=['Año', 'Mes'], inplace=True)

result.to_csv("paroComunidades.csv",index=False)