#Iteración 3

require(RMySQL) #if already installed
require(scatterplot3d)

#Libera memoria
rm(list=ls())

#-----------------------------------Durante la 3º iteración se hicieron multitud de pruebas ----------------------------
#---------------------------------------con modelos de resgresión algo más complejos------------------------------------
#---------------------------en este fichero se muestran las pruebas que se hicieron con las variables-------------------
#-----------con datos disponibles desde 2007, en este caso: numero de Parados, IPC, Deuda Pública y Precio Vivienda-----
#-----------------------------------------------------------------------------------------------------------------------


con <- dbConnect(RMySQL::MySQL(), host = "localhost",dbname="min",user = "root", password = "")


#
# Predicción de numero de parados a partir de IPC, DeudaPub y PrecioDeVivienda
#


#Preparamos las sentencias SQL

sqlPrecioVivienda = "SELECT AVG(`preciovivienda`.`Indice`) as IndicePrecioViv, tiempo.Mes, tiempo.Anio 
FROM `turismo` 
JOIN `tiempo` ON `turismo`.`ID Mes`=`tiempo`.`ID Mes` 
JOIN preciovivienda ON `turismo`.`ID PrecioVivienda` = `preciovivienda`.`ID PrecioVivienda`
JOIN comunidad ON `comunidad`.`ID Comunidad` = `turismo`.`ID Comunidad` 
WHERE tiempo.Anio >= 2007  AND `preciovivienda`.`TipoVivienda`='General'
GROUP BY `tiempo`.`ID Mes`"


#Numero de parados a nivel nacional
sqlParados <- "SELECT SUM(turismo.NumParados) as numParados, tiempo.Mes, tiempo.Anio FROM `turismo` JOIN `tiempo` ON `turismo`.`ID Mes`=`tiempo`.`ID Mes` WHERE tiempo.Anio >= 2007 GROUP BY `tiempo`.`ID Mes`;"


#Numero de turistas a nivel nacional
sqlTuristas <- "SELECT SUM(turismo.NumTurista) as numTurista, tiempo.Mes, tiempo.Anio FROM `turismo` JOIN `tiempo` ON `turismo`.`ID Mes`=`tiempo`.`ID Mes` GROUP BY `tiempo`.`ID Mes`;"

sqlIPC <- "SELECT `turismo`.`ID Mes`, tiempo.Mes, tiempo.Anio, ipc.Indice
FROM turismo 
JOIN ipcids ON `ipcids`.`idHecho`=`turismo`.`ID IPC`
JOIN `ipc` ON `ipc`.`ID IPC` = `ipcids`.`idDatos` 
JOIN tiempo ON `turismo`.`ID Mes` = `tiempo`.`ID Mes` 
JOIN comunidad ON `comunidad`.`ID Comunidad` = `turismo`.`ID Comunidad` 

WHERE tiempo.Anio >= 2007 AND ipc.GrupoECOICOP='�ndice general'
GROUP BY `tiempo`.`ID Mes` "


sqlDeudaPublica <- "SELECT AVG(turismo.deudaPubPIB) as deudaPubPIB, tiempo.Mes, tiempo.Anio FROM `turismo` JOIN `tiempo` ON `turismo`.`ID Mes`=`tiempo`.`ID Mes` WHERE tiempo.Anio >= 2007 GROUP BY `tiempo`.`ID Mes`"


#Ejecutamos la consultas SQL
paradosBD <- dbGetQuery(con, sqlParados)
ipcBD <- dbGetQuery(con, sqlIPC)
deudaPubBD <- dbGetQuery(con, sqlDeudaPublica)
precioViviendaBD <- dbGetQuery(con, sqlPrecioVivienda)


#Filtrar los datos NA, se ha hecho de manera semiaumática como en la anterior iteración...
#También se han acortado los datos para que abarquen el mismo intervalo temporal
paradosPrePred <- paradosBD[-c(154:168),]
deudaPubPrePred <-deudaPubBD[-c(154:168),]
ipcPrePred <- ipcBD[-c(154:158),]
precioPrePred <- precioViviendaBD[-c(154:156),]

#----- UNIR DATA FRAMES CON SERIES TEMP------------------


vectorIPC <- unlist(ipcPrePred$Indice, use.names = FALSE)
vectorParados <- unlist(paradosPrePred$numParados, use.names = FALSE)
vectorDeudaPub <- unlist(deudaPubPrePred$deudaPubPIB, use.names = FALSE)
vectorPrecioViv <-unlist(precioPrePred$IndicePrecioViv, use.names = FALSE)

matriz <- cbind(vectorIPC, vectorParados, vectorDeudaPub, vectorPrecioViv)


serieTemp <- ts(matriz, start = c(2007, 5), frequency = 12)

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


#---------------MODELO DE REGRESIÓN CON LM-------------


cor(ipcPrePred$Indice, paradosPrePred$numParados)

cor(trainData[,1], trainData[,2])# 1 --> IPC, 2 --> Parados

ipcTrain <- trainData[,1]
paradTrain <- trainData[,2]
deudaTrain <- trainData[,3]
precioViviendaTrain <- trainData[,4]

length(ipcTrain)
length(paradTrain)
length(deudaTrain)
length(precioViviendaTrain)

pred <- lm(trainData[,2] ~ trainData[,1] + trainData[,3] + trainData[,4])
pred <- lm(paradTrain ~ ipcTrain + deudaTrain + precioViviendaTrain)

pred

attributes(pred)

pred$coefficients

summary(pred)

hist(pred$residuals)

boxplot(pred[['residuals']],main='Boxplot: Residuals',ylab='residual value')


#----Calculo del Error Cuadrático Medio Teórico de la Regresión
ECMaPriori <- sum((residuals(pred)^2))/length((residuals(pred)))

# Cálculo del error medio absoluto "teórico" o "a priori" de la regresión
EMAaPriori <- sqrt(ECMaPriori); EMAaPriori

# Cálculo del error medio relativo (o porcentual) "teórico" o "a priori"  de la regresión
EMRaPriori <- EMAaPriori / mean(paradTrain); EMRaPriori



layout(matrix(c(1,2,3,4),2,2)) # 4 gráficos por ventana 
plot(pred)
layout(matrix(1)) # Restauración del valor inicial 

s3d <- scatterplot3d(trainData[,1], trainData[,3], trainData[,2], highlight.3d=T, type="h",
                     lab=c(2,3)) # Pinta la “estructura”.


s3d <- scatterplot3d(trainData[,1], trainData[,4], trainData[,2], highlight.3d=T, type="h",
                     lab=c(2,3)) # Pinta la “estructura”.



#-----------------------------Predicción------------------------------------------------------

#Tiene que tener el mismo nombre que los coeficientes del modelo generado por lm
new = data.frame("ipcTrain"=testData[,1] , "deudaTrain"=testData[,3] , "precioViviendaTrain"=testData[,4]) 


#Se repite el 1 (tipo de estilo) para los datos usados en entrenamiento y el 2 para los datos que se van a usar para la prediccion
style <- c(rep(1,length(paradTrain)), rep(2,length(testData[,1])))

prediccion <- predict(pred, newdata = new)
prediccion

plot(c(paradTrain, prediccion), xaxt="n", ylab="Parados", xlab="", pch=style, col=style) #Predicción
plot(c(paradTrain, testData[,2]), xaxt="n", ylab="Parados", xlab="") #Datos Reales

#axis(1, at=1:16, las=3, labels=c(paste(year,quarter,sep="Q"), "2011Q1", "2011Q2", "2011Q3", "2011Q4"))



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
