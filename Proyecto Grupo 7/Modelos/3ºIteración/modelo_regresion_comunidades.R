
require(RMySQL) #if already installed

#HAY QUE AMPLIAR EL TAMANIO DE ECOICOP A 100

#Libera memoria
rm(list=ls())

#Tabla de Hechos tiene que tener datos desde el 2010 aunque turismo este a null
#Al añadir todas la nuevas columnas de las tablas  hay que volver a separar las columnas de parados y deuda publica en otras tablas...


con <- dbConnect(RMySQL::MySQL(), host = "localhost",dbname="min",user = "root", password = "")

turismo <- dbReadTable(con, "turismo") #utilisateurs is a table from my database called extraction
ipc <- dbReadTable(con, "ipc") #utilisateurs is a table from my database called extraction
ipcids <- dbReadTable(con, "ipcids") #utilisateurs is a table from my database called extraction
criminalidad <- dbReadTable(con, "criminalidad") #utilisateurs is a table from my database called extraction
crimenids <- dbReadTable(con, "criminalidad") #utilisateurs is a table from my database called extraction
preciovivienda <- dbReadTable(con, "preciovivienda") #utilisateurs is a table from my database called extraction
tiempo <- dbReadTable(con, "tiempo") #utilisateurs is a table from my database called extraction
comunidad <- dbReadTable(con, "comunidad") #utilisateurs is a table from my database called extraction


#Numero de parados a nivel nacional
sqlParados <- "SELECT
    turismo.NumParados AS numParados,
    tiempo.Mes,
    tiempo.Anio,
    comunidad.NombreComunidad
FROM
    `turismo`
JOIN `tiempo` ON `turismo`.`ID Mes` = `tiempo`.`ID Mes`
JOIN `comunidad` ON `turismo`.`ID Comunidad` = `comunidad`.`ID Comunidad`
WHERE
    tiempo.Anio >= 2007 AND `comunidad`.`NombreComunidad` != \"Otras Comunidades Autónomas\" AND `comunidad`.`NombreComunidad` != \"Melilla\" AND `comunidad`.`NombreComunidad` != \"Ceuta\"
    
    ORDER BY `tiempo`.`ID Mes`,`comunidad`.`NombreComunidad` ASC;"


#Numero de turistas a nivel nacional

sqlIPC <- "SELECT
    `turismo`.`ID Mes`,
    tiempo.Mes,
    tiempo.Anio,
    IPC.Indice,
    comunidad.NombreComunidad
FROM
    turismo
JOIN ipcids ON `ipcids`.`idHecho` = `turismo`.`ID IPC`
JOIN `ipc` ON `ipc`.`ID IPC` = `ipcids`.`idDatos`
JOIN tiempo ON `turismo`.`ID Mes` = `tiempo`.`ID Mes`
JOIN comunidad ON `comunidad`.`ID Comunidad` = `turismo`.`ID Comunidad`
WHERE
    tiempo.Anio >= 2007 AND IPC.GrupoECOICOP = 'Índice general' AND `comunidad`.`NombreComunidad` != \"Otras Comunidades Autónomas\" AND `comunidad`.`NombreComunidad` != \"Melilla\" AND `comunidad`.`NombreComunidad` != \"Ceuta\"
ORDER BY
    `tiempo`.`ID Mes`,
    `comunidad`.`NombreComunidad` ASC;"


sqlPrecioVivienda = "SELECT
    `preciovivienda`.`Indice` AS IndicePrecioViv,
    tiempo.Mes,
    tiempo.Anio,
    comunidad.NombreComunidad
FROM
    `turismo`
JOIN `tiempo` ON `turismo`.`ID Mes` = `tiempo`.`ID Mes`
JOIN preciovivienda ON `turismo`.`ID PrecioVivienda` = `preciovivienda`.`ID PrecioVivienda`
JOIN comunidad ON `comunidad`.`ID Comunidad` = `turismo`.`ID Comunidad`
WHERE
    tiempo.Anio >= 2007 AND `preciovivienda`.`TipoVivienda` = 'General' AND `comunidad`.`NombreComunidad` != \"Otras Comunidades Autónomas\" AND `comunidad`.`NombreComunidad` != \"Melilla\" AND `comunidad`.`NombreComunidad` != \"Ceuta\"
ORDER BY
    `tiempo`.`ID Mes`,
    `comunidad`.`NombreComunidad` ASC;"

sqlDeudaPublica <- "SELECT
    turismo.deudaPubPIB AS deudaPubPIB,
    tiempo.Mes,
    tiempo.Anio,
    comunidad.NombreComunidad
FROM
    `turismo`
JOIN `tiempo` ON `turismo`.`ID Mes` = `tiempo`.`ID Mes`
JOIN comunidad ON `comunidad`.`ID Comunidad` = `turismo`.`ID Comunidad`
WHERE
    tiempo.Anio >= 2007 AND `comunidad`.`NombreComunidad` != \"Otras Comunidades Autónomas\" AND `comunidad`.`NombreComunidad` != \"Melilla\" AND `comunidad`.`NombreComunidad` != \"Ceuta\"
    ORDER BY
    `tiempo`.`ID Mes`,
    `comunidad`.`NombreComunidad` ASC"


paradosBD <- dbGetQuery(con, sqlParados)
ipcBD <- dbGetQuery(con, sqlIPC)
deudaPubBD <- dbGetQuery(con, sqlDeudaPublica)
precioViviendaBD <- dbGetQuery(con, sqlPrecioVivienda)



#--------------------------------------------------------------------------
#----------------------PRUEBA de 2007 a 2019---------------------------
#--------------------------------------------------------------------------

#Filtrar los datos NA

ipcPrePred <- ipcBD[-c(2602:2686),]
paradosPrePred <- paradosBD[-c(2602:2856),]
deudaPubPrePred <-deudaPubBD[-c(2602:2856),]
precioPrePred <- precioViviendaBD[-c(2602:2652),]

vectorIPC <- unlist(ipcPrePred$Indice, use.names = FALSE)
vectorParados <- unlist(paradosPrePred$numParados, use.names = FALSE)
vectorDeudaPub <- unlist(deudaPubPrePred$deudaPubPIB, use.names = FALSE)
vectorPrecioViv <-unlist(precioPrePred$IndicePrecioViv, use.names = FALSE)
vectorComunidades <- unlist(paradosPrePred$NombreComunidad, use.names = FALSE)
factorComunidades <- factor(vectorComunidades)
matriz <- cbind(vectorIPC, vectorParados, vectorDeudaPub, vectorPrecioViv, factorComunidades)


serieTemp <- ts(matriz, start = c(2007, 1), frequency = 12)

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
comunidadTrain <- trainData[,5]

pred <- lm(trainData[,2] ~ trainData[,1] + trainData[,3] + trainData[,4] + trainData[,5])

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

#COMO SELECCIOANAR LAS VARIABLES CONCRETAS PARA LA PREDICCION
s3d$plane3d(pred) # Pinta los puntos del modelo sobre la estructura



s3d <- scatterplot3d(trainData[,1], trainData[,4], trainData[,2], highlight.3d=T, type="h",
                     lab=c(2,3)) # Pinta la “estructura”.

