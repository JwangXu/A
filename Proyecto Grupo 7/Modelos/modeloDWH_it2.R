
require(RMySQL) #if already installed

#HAY QUE AMPLIAR EL TAMANIO DE ECOICOP A 100

#Libera memoria
rm(list=ls())


#----------------------------------------------------------------------------------------------------------------------------
#---------------------Principalmente durante la 2º iteración se experimento a realizar consultas al datawarehouse------------
#------------------y probar a relacionar otra variable a parte del turismo ya que solo teniamos registros desde 2015---------
#---------------------------------decidimos probar a relacionar el IPC a partir del número de parados------------------------
#------------------------------------ya que disponiamos de datos desde 2005 para hacer pruebas-------------------------------
#----------------------------------------------------------------------------------------------------------------------------

con <- dbConnect(RMySQL::MySQL(), host = "localhost",dbname="min",user = "root", password = "")

#Preparamos las sentencias SQL

#Numero de parados a nivel nacional
sqlParados <- "SELECT SUM(turismo.NumParados) as numParados, tiempo.Mes, tiempo.Anio FROM `turismo` JOIN `tiempo` ON `turismo`.`ID Mes`=`tiempo`.`ID Mes` WHERE tiempo.Anio >= 2005 GROUP BY `tiempo`.`ID Mes`;"


#Numero de turistas a nivel nacional
sqlTuristas <- "SELECT SUM(turismo.NumTurista) as numTurista, tiempo.Mes, tiempo.Anio FROM `turismo` JOIN `tiempo` ON `turismo`.`ID Mes`=`tiempo`.`ID Mes` GROUP BY `tiempo`.`ID Mes`;"

sqlIPC <- "SELECT `turismo`.`ID Mes`, tiempo.Mes, tiempo.Anio, ipc.Indice
FROM turismo 
JOIN ipcids ON `ipcids`.`idHecho`=`turismo`.`ID IPC`
JOIN `ipc` ON `ipc`.`ID IPC` = `ipcids`.`idDatos` 
JOIN tiempo ON `turismo`.`ID Mes` = `tiempo`.`ID Mes` 
JOIN comunidad ON `comunidad`.`ID Comunidad` = `turismo`.`ID Comunidad` 

WHERE tiempo.Anio >= 2005 AND ipc.GrupoECOICOP='Índice general'
GROUP BY `tiempo`.`ID Mes` "

#Realizamos las consultas SQL
paradosBD <- dbGetQuery(con, sqlParados)
turistasBD <- dbGetQuery(con, sqlTuristas)
ipcBD <- dbGetQuery(con, sqlIPC)




#--------------------------------------------------------------------------
#-----------------------------PRUEBA CON 15 AÑOS---------------------------
#--------------------------------------------------------------------------

#Filtrar los datos NA, para ello lo hemos de una manera semniautomática, revisando que datos estaban a NA para poder quitarlos

ipcPrePred <- ipcBD[-c(1:4),]
paradosPrePred <- paradosBD[-c(183:192),]
paradosPrePred <- paradosPrePred[-c(1:4),]

#---------------------UNIR DATA FRAMES CON SERIES TEMP------------------

#Construimos vectores para unirlos posteriormente a una matriz y construir una serie temporal
vectorIPC <- unlist(ipcPrePred$Indice, use.names = FALSE)
vectorParados <- unlist(paradosPrePred$numParados, use.names = FALSE)

matriz <- cbind(vectorIPC, vectorParados)

serieTemp <- ts(matriz, start = c(2005, 5), frequency = 12)

serieTemp

cor(serieTemp)

#Semilla y division para entrenamiento

set.seed(1)

ind <- sample(2, nrow(matriz), replace=TRUE, prob=c(0.9, 0.1))
head(ind, 10)

trainData <- matriz[ind==1,] ; dim(trainData)
testData <- matriz[ind==2,] ; dim(testData)

#---------------------
#------CON LM---------
#---------------------

cor(ipcPrePred$Indice, paradosPrePred$numParados)

cor(trainData[,1], trainData[,2])# 1 --> IPC, 2 --> Parados

ipcTrain <- trainData[,1]
paradTrain <- trainData[,2]

pred <- lm(ipcTrain ~ paradTrain)

pred

attributes(pred)

pred$coefficients

summary(pred)

hist(pred$residuals)

layout(matrix(c(1,2,3,4),2,2)) # 4 gráficos por ventana 
plot(pred)
layout(matrix(1)) # Restauración del valor inicial 


#Tabla de Prediccion
#Se intentó realizar una  predicción a partir de los datos pero no nos funcionó muy bien...

tablaRst <- table(predict(pred),trainData[,1])

plot(bodyfat$DEXfat, pred, xlab="Observed Values", ylab="Predicted Values")

abline(a=0, b=1)