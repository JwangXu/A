
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
    tiempo.Anio >= 2007 AND `comunidad`.`NombreComunidad` != \"Otras Comunidades Aut�nomas\" AND `comunidad`.`NombreComunidad` != \"Melilla\" AND `comunidad`.`NombreComunidad` != \"Ceuta\"
    
    ORDER BY `tiempo`.`ID Mes`,`comunidad`.`NombreComunidad` ASC;"


#Numero de turistas a nivel nacional
#sqlTuristas <- "SELECT SUM(turismo.NumTurista) as numTurista, tiempo.Mes, tiempo.Anio FROM `turismo` JOIN `tiempo` ON `turismo`.`ID Mes`=`tiempo`.`ID Mes` GROUP BY `tiempo`.`ID Mes`;"

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
    tiempo.Anio >= 2007 AND IPC.GrupoECOICOP = '�ndice general' AND `comunidad`.`NombreComunidad` != \"Otras Comunidades Autónomas\" AND `comunidad`.`NombreComunidad` != \"Melilla\" AND `comunidad`.`NombreComunidad` != \"Ceuta\"
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
#turistasBD <- dbGetQuery(con, sqlTuristas)
ipcBD <- dbGetQuery(con, sqlIPC)
deudaPubBD <- dbGetQuery(con, sqlDeudaPublica)
precioViviendaBD <- dbGetQuery(con, sqlPrecioVivienda)



#--------------------------------------------------------------------------
#----------------------PRUEBA de 2007 a 2019---------------------------
#--------------------------------------------------------------------------

#Filtrar los datos NA

ipcPrePred <- ipcBD[-c(2602:length(ipcBD[,1])),]
paradosPrePred <- paradosBD[-c(2602:length(paradosBD[,1])),]
deudaPubPrePred <-deudaPubBD[-c(2602:length(deudaPubBD[,1])),]
precioPrePred <- precioViviendaBD[-c(2602:length(precioViviendaBD[,1])),]

#Categorizamos paradosPrePred

vectorParados <- unlist(paradosPrePred$numParados, use.names = FALSE)
paradosPrePred


vectorIPC <- unlist(ipcPrePred$Indice, use.names = FALSE)

vectorDeudaPub <- unlist(deudaPubPrePred$deudaPubPIB, use.names = FALSE)

vectorPrecioViv <- unlist(precioPrePred$IndicePrecioViv, use.names = FALSE)

vectorComunidades <- unlist(paradosPrePred$NombreComunidad, use.names = FALSE)
factorComunidades <- factor(vectorComunidades)

#Calculamos el numero de intervalos
k = 5
#Calculamos la amplitud
A = diff(range(vectorParados))/k

A = ceiling(A)

#Calculamos el elemento minimo para poner los intervalos
m = min(vectorParados)

L = m - 0.05 + A * (0:k)
L

marcas = (L[0:k] + L[1:k+1])/2
marcas

etiq = c("grado 1", "grado 2", "grado 3","grado 4","grado 5")

corteCuantitativo = cut(vectorParados, breaks=L, labels=etiq, right=FALSE)
corteCuantitativo

###PRueba con Rpart

install.packages("rpart")
install.packages("rpart.plot")
library("rpart")
library("rpart.plot")

dataframeGrados = data.frame(vectorIPC, corteCuantitativo, vectorDeudaPub, vectorPrecioViv, factorComunidades)

myFormula <- corteCuantitativo ~ vectorIPC + vectorDeudaPub + vectorPrecioViv + factorComunidades

arbol_rpart <- rpart(myFormula, method = "class", dataframeGrados)

attributes(arbol_rpart)

print(arbol_rpart)

rpart.plot(arbol_rpart, extra = 4, cex = 0.6, box.palette = "green")
print(arbol_rpart$cptable)

plot(arbol_rpart)
text(arbol_rpart, use.n=T)
printcp(arbol_rpart)
plotcp(arbol_rpart)
table(predict(arbol_rpart))

opt <- which.min(arbol_rpart$cptable[,"xerror"])
cp <- arbol_rpart$cptable[opt, "CP"]
arbol_rpart_prune <- prune(arbol_rpart, cp = cp)

print(arbol_rpart_prune)

plot(arbol_rpart_prune)
text(arbol_rpart_prune, use.n=T)


table(predict(arbol_rpart_prune))


#--------CON SERIES TEMP------------------


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
# [1] 1 1 1 1 2 1 1 1 1 1
trainData <- matriz[ind==1,] ; dim(trainData)
# [1] 112 5
testData <- matriz[ind==2,] ; dim(testData)


