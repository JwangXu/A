#IteraciÃ³n 3

require(RMySQL) #if already installed
require(scatterplot3d)

#Libera memoria
rm(list=ls())

#-----------------------------------Durante la 3Âº iteraciÃ³n se hicieron multitud de pruebas ----------------------------
#---------------------------------------con modelos de resgresiÃ³n algo mÃ¡s complejos------------------------------------
#---------------------------en este fichero se muestran las pruebas que se hicieron con las variables-------------------
#-----------con datos disponibles desde 2007, en este caso: numero de Parados, IPC, Deuda PÃºblica y Precio Vivienda-----
#-----------------------------------------------------------------------------------------------------------------------

con <- dbConnect(RMySQL::MySQL(), host = "localhost",dbname="min",user = "root", password = "")

#
# PredicciÃ³n de numero de parados a partir de IPC, DeudaPub y PrecioDeVivienda
#


#Preparamos las sentencias SQL


sqlCriminalidad = "SELECT SUM(`criminalidad`.`NumDenuncias`) as numDenuncias, tiempo.Mes, tiempo.Anio 
FROM `turismo` 
JOIN crimenids ON `crimenids`.`idHecho`=`turismo`.`ID Criminalidad`
JOIN `criminalidad` ON `criminalidad`.`ID Criminalidad` = `crimenids`.`idDatos` 
JOIN `tiempo` ON `turismo`.`ID Mes`=`tiempo`.`ID Mes` 
JOIN comunidad ON `comunidad`.`ID Comunidad` = `turismo`.`ID Comunidad` 
WHERE tiempo.Anio >= 2013
GROUP BY `tiempo`.`ID Mes`"


sqlPrecioVivienda = "SELECT AVG(`preciovivienda`.`Indice`) as IndicePrecioViv, tiempo.Mes, tiempo.Anio 
FROM `turismo` 
JOIN `tiempo` ON `turismo`.`ID Mes`=`tiempo`.`ID Mes` 
JOIN preciovivienda ON `turismo`.`ID PrecioVivienda` = `preciovivienda`.`ID PrecioVivienda`
JOIN comunidad ON `comunidad`.`ID Comunidad` = `turismo`.`ID Comunidad` 
WHERE tiempo.Anio >= 2013  AND `preciovivienda`.`TipoVivienda`='General'
GROUP BY `tiempo`.`ID Mes`"


#Numero de parados a nivel nacional
sqlParados <- "SELECT SUM(turismo.NumParados) as numParados, tiempo.Mes, tiempo.Anio FROM `turismo` JOIN `tiempo` ON `turismo`.`ID Mes`=`tiempo`.`ID Mes` WHERE tiempo.Anio >= 2013 GROUP BY `tiempo`.`ID Mes`;"

sqlIPC <- "SELECT ipc.Indice,tiempo.Mes, tiempo.Anio
FROM turismo 
JOIN ipcids ON `ipcids`.`idHecho`=`turismo`.`ID IPC`
JOIN `ipc` ON `ipc`.`ID IPC` = `ipcids`.`idDatos` 
JOIN tiempo ON `turismo`.`ID Mes` = `tiempo`.`ID Mes` 
JOIN comunidad ON `comunidad`.`ID Comunidad` = `turismo`.`ID Comunidad` 

WHERE tiempo.Anio >= 2013 AND ipc.GrupoECOICOP='�ndice general'
GROUP BY `tiempo`.`ID Mes` "


sqlDeudaPublica <- "SELECT AVG(turismo.deudaPubPIB) as deudaPubPIB, tiempo.Mes, tiempo.Anio FROM `turismo` JOIN `tiempo` ON `turismo`.`ID Mes`=`tiempo`.`ID Mes` WHERE tiempo.Anio >= 2013 GROUP BY `tiempo`.`ID Mes`"


#Ejecutamos la consultas SQL

criminalidadBD <- dbGetQuery(con, sqlCriminalidad)
paradosBD <- dbGetQuery(con, sqlParados)
ipcBD <- dbGetQuery(con, sqlIPC)
deudaPubBD <- dbGetQuery(con, sqlDeudaPublica)
precioViviendaBD <- dbGetQuery(con, sqlPrecioVivienda)


#Filtrar los datos NA, se ha hecho de manera semiaumÃ¡tica como en la anterior iteraciÃ³n...
#TambiÃ©n se han acortado los datos para que abarquen el mismo intervalo temporal

paradosPrePred <- paradosBD[-c(49:96),]
deudaPubPrePred <-deudaPubBD[-c(49:96),]
ipcPrePred <- ipcBD[-c(49:86),]
precioPrePred <- precioViviendaBD[-c(49:84),]

#----- UNIR DATA FRAMES CON SERIES TEMP------------------

vectorCriminalidad <-unlist(criminalidadBD$numDenuncias, use.names = FALSE)
vectorIPC <- unlist(ipcPrePred$Indice, use.names = FALSE)
vectorParados <- unlist(paradosPrePred$numParados, use.names = FALSE)
vectorDeudaPub <- unlist(deudaPubPrePred$deudaPubPIB, use.names = FALSE)
vectorPrecioViv <-unlist(precioPrePred$IndicePrecioViv, use.names = FALSE)

matriz <- cbind(vectorCriminalidad,vectorIPC, vectorParados, vectorDeudaPub, vectorPrecioViv)


serieTemp <- ts(matriz, start = c(2013, 6), frequency = 12)

serieTemp

cor(serieTemp)

#Semilla y division para entrenamiento

set.seed(1)

ind <- sample(2, nrow(matriz), replace=TRUE, prob=c(0.9, 0.1))
head(ind, 10)
# [1] 1 1 1 1 2 1 1 1 1 1
trainData <- matriz[ind==1,] ; dim(trainData)
# [1] 112 5
testData <- matriz[ind==2,] ; dim(testData)


#---------------MODELO DE REGRESIÃN CON LM-------------


cor(ipcPrePred$Indice, paradosPrePred$numParados)
criminalidadTrain <- trainData[,1]
ipcTrain <- trainData[,2]
paradTrain <- trainData[,3]
deudaTrain <- trainData[,4]
precionViviendaTrain <- trainData[,5]

pred <- lm(criminalidadTrain ~ paradTrain + ipcTrain + deudaTrain + precionViviendaTrain)

pred

attributes(pred)

pred$coefficients

summary(pred)

hist(pred$residuals)

layout(matrix(c(1,2,3,4),2,2)) # 4 grÃ¡ficos por ventana 
plot(pred)
layout(matrix(1)) # RestauraciÃ³n del valor inicial 

s3d <- scatterplot3d(trainData[,1], trainData[,3], trainData[,2], highlight.3d=T, type="h",
                     lab=c(2,3)) # Pinta la âestructuraâ.



s3d <- scatterplot3d(trainData[,1], trainData[,4], trainData[,2], highlight.3d=T, type="h",
                     lab=c(2,3)) # Pinta la âestructuraâ.

