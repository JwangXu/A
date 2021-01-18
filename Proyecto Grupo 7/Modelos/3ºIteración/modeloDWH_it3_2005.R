#Iteración 3

require(RMySQL) #if already installed
require(scatterplot3d)

#Libera memoria
rm(list=ls())


#------------------------Durante la 3º iteración se hicieron multitud de pruebas -------------------
#------------------------------con modelos de resgresión algo más complejos-------------------------
#---------------en este fichero se muestran las pruebas que se hicieron con las variables-----------
#-------con datos disponibles desde 2005, en este caso: numero de Parados, IPC y Deuda Pública------
#---------------------------------------------------------------------------------------------------


con <- dbConnect(RMySQL::MySQL(), host = "localhost",dbname="min",user = "root", password = "")


#Preparamos las sentencias SQL

#Numero de parados a nivel nacional
sqlParados <- "SELECT SUM(turismo.NumParados) as numParados, tiempo.Mes, tiempo.Anio FROM `turismo` JOIN `tiempo` ON `turismo`.`ID Mes`=`tiempo`.`ID Mes` WHERE tiempo.Anio >= 2005 GROUP BY `tiempo`.`ID Mes`;"


sqlIPC <- "SELECT `turismo`.`ID Mes`, tiempo.Mes, tiempo.Anio, ipc.Indice
FROM turismo 
JOIN ipcids ON `ipcids`.`idHecho`=`turismo`.`ID IPC`
JOIN `ipc` ON `ipc`.`ID IPC` = `ipcids`.`idDatos` 
JOIN tiempo ON `turismo`.`ID Mes` = `tiempo`.`ID Mes` 
JOIN comunidad ON `comunidad`.`ID Comunidad` = `turismo`.`ID Comunidad` 

WHERE tiempo.Anio >= 2005 AND ipc.GrupoECOICOP='�ndice general'
GROUP BY `tiempo`.`ID Mes` "

sqlDeudaPublica <- "SELECT AVG(turismo.deudaPubPIB) as deudaPubPIB, tiempo.Mes, tiempo.Anio FROM `turismo` JOIN `tiempo` ON `turismo`.`ID Mes`=`tiempo`.`ID Mes` WHERE tiempo.Anio >= 2005 GROUP BY `tiempo`.`ID Mes`"


#Ejecutamos la consultas SQL
paradosBD <- dbGetQuery(con, sqlParados)
ipcBD <- dbGetQuery(con, sqlIPC)
deudaPubBD <- dbGetQuery(con, sqlDeudaPublica)


#Filtrar los datos NA, se ha hecho de manera semiaumática como en la anterior iteración...
#También se han acortado los datos para que abarquen el mismo intervalo temporal

ipcPrePred <- ipcBD[-c(1:4),]
paradosPrePred <- paradosBD[-c(183:192),]
paradosPrePred <- paradosPrePred[-c(1:4),]
deudaPrePred <- deudaPubBD[-c(1:4),]


#----------------------------------------------------------------------------------------------------------
#-----------------------------NumParados a partir de IPC desde 2005------------------------
#----------------------------------------------------------------------------------------------------------



paradosBD <- dbGetQuery(con, sqlParados)
ipcBD <- dbGetQuery(con, sqlIPC)
deudaPubBD <- dbGetQuery(con, sqlDeudaPublica)



#Filtrar los datos NA

ipcPrePred <- ipcBD[-c(1:4),]
ipcPrePred <- ipcBD[-c(178:182),]
paradosPrePred <- paradosBD[-c(182:192),]
paradosPrePred <- paradosPrePred[-c(1:4),]
deudaPrePred <- deudaPubBD[-c(1:4),]
deudaPrePred <- deudaPubBD[-c(178:192),]

#----- UNIR DATA FRAMES CON SERIES TEMP------------------


vectorIPC <- unlist(ipcPrePred$Indice, use.names = FALSE)
vectorParados <- unlist(paradosPrePred$numParados, use.names = FALSE)
vectorDeudaPub <- unlist(deudaPrePred$deudaPubPIB, use.names = FALSE)

matriz <- cbind(vectorIPC, vectorParados, vectorDeudaPub)

serieTemp <- ts(matriz, start = c(2005, 5), frequency = 12)

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


#----CON LM


cor(ipcPrePred$Indice, paradosPrePred$numParados)

cor(trainData[,1], trainData[,2])# 1 --> IPC, 2 --> Parados

ipcTrain <- trainData[,1]
paradTrain <- trainData[,2]

pred <- lm(paradTrain ~ ipcTrain)

pred

attributes(pred)

pred$coefficients

summary(pred)

hist(pred$residuals)

layout(matrix(c(1,2,3,4),2,2)) # 4 gráficos por ventana 
plot(pred)
layout(matrix(1)) # Restauración del valor inicial 




#Ahora se prueba otro modelo con una variable más, Deuda Pública

#----------------------------------------------------------------------------------------------------------
#-----------------------NumParados a partir de IPC y Deuda Pública desde 2005------------------------------
#----------------------------------------------------------------------------------------------------------


#------------UNIR DATA FRAMES-CON SERIES TEMP------------------

#Se construyen los vectores
vectorIPC <- unlist(ipcPrePred$Indice, use.names = FALSE)
vectorParados <- unlist(paradosPrePred$numParados, use.names = FALSE)
vectorDeudaPub <- unlist(deudaPrePred$deudaPubPIB, use.names = FALSE)

matriz <- cbind(vectorIPC, vectorParados, vectorDeudaPub)

serieTemp <- ts(matriz, start = c(2005, 5), frequency = 12)

serieTemp

cor(serieTemp)

#Semilla y division para entrenamiento

set.seed(1)

ind <- sample(2, nrow(matriz), replace=TRUE, prob=c(0.9, 0.1))
head(ind, 10)

trainData <- matriz[ind==1,] ; dim(trainData)
testData <- matriz[ind==2,] ; dim(testData)


#----MODELO DE REGRESIÓN CON LM------


cor(ipcPrePred$Indice, paradosPrePred$numParados)

cor(trainData[,1], trainData[,2])# 1 --> IPC, 2 --> Parados

ipcTrain <- trainData[,1]
paradTrain <- trainData[,2]
deudaTrain <- trainData[,3]

pred <- lm(trainData[,2] ~ trainData[,1] + trainData[,3]) # Formula = Parados ~ IPC + DEUDA PUB

pred

attributes(pred)

pred$coefficients

summary(pred)

hist(pred$residuals)

layout(matrix(c(1,2,3,4),2,2)) # 4 gráficos por ventana 
plot(pred)
layout(matrix(1)) # Restauración del valor inicial 


s3d <- scatterplot3d(trainData[,1], trainData[,3], trainData[,2], highlight.3d=T, type="h",
                     lab=c(2,3)) # Pinta la “estructura”.
s3d$plane3d(pred) # Pinta los puntos del modelo sobre la estructura


#-----------------------------Predicción------------------------------------------------------

#Tiene que tener el mismo nombre que los coeficientes del modelo generado por lm
new = data.frame("ipcTrain"=testData[,2] , "deudaTrain"=testData[,1] , "paradTrain"=testData[,3]) 


#Se repite el 1 (tipo de estilo) para los datos usados en entrenamiento y el 2 para los datos que se van a usar para la prediccion
style <- c(rep(1,length(paradTrain)), rep(2,length(testData[,1])))

prediccion <- predict(pred, newdata = new)
prediccion

plot(c(paradTrain, prediccion), xaxt="n", ylab="Parados", xlab="", pch=style, col=style) #Predicción
plot(c(paradTrain, testData[,2]), xaxt="n", ylab="Parados", xlab="") #Datos Reales


#Se define un estilo para las ultimas 3 rangos de predicion(fir, lwr y upr) (es lo que genera la prediccion con el intervalo definido...)
style <- c(rep(1,length(paradTrain)), rep(2,length(testData[,1])), rep(3,length(testData[,1])), rep(4,length(testData[,1])))

prediccion <- predict(pred, newdata = new, interval='confidence')
prediccion

plot(c(paradTrain, prediccion), xaxt="n", ylab="Parados", xlab="", pch=style, col=style) #Predicción
plot(c(paradTrain, testData[,2]), xaxt="n", ylab="Parados", xlab="") #Datos Reales


prediccion <- predict(pred, newdata = new, interval='prediction')
prediccion

plot(c(paradTrain, prediccion), xaxt="n", ylab="Parados", xlab="", pch=style, col=style) #Predicción
plot(c(paradTrain, testData[,2]), xaxt="n", ylab="Parados", xlab="") #Datos Reales

