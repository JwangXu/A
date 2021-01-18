require(RMySQL) #if already installed

#Libera memoria
rm(list=ls())

#------------------------------------------------------------------------------------------------
#---------Principalmente durante la 1º iteración se hicieron pruebas con el datawarehouse--------
#------------------para ver su funcionamiento y probar algún modelo simple-----------------------
#------------------------------------------------------------------------------------------------


con <- dbConnect(RMySQL::MySQL(), host = "localhost",dbname="min",user = "root", password = "")

#Carga de las tablas de la Base de Datos
turismo <- dbReadTable(con, "turismo") 
ipc <- dbReadTable(con, "ipc") 
ipcids <- dbReadTable(con, "ipcids") 
criminalidad <- dbReadTable(con, "criminalidad") 
crimenids <- dbReadTable(con, "criminalidad") 
preciovivienda <- dbReadTable(con, "preciovivienda") 
tiempo <- dbReadTable(con, "tiempo") 
comunidad <- dbReadTable(con, "comunidad") 



#Ordenar la tabla de turismo por ID Mes (Ordenarla cronologicamente)
turismo2 <- turismo[order(turismo$ID.Mes),]

year <- rep(2016:2019, each=12); 
quarter <- rep(1:12, 4)


#Grafica con la Evolución del Turismo
plot(turismo$NumTurista, xaxt="n", ylab="Id Mes", xlab="Turismo")

plot(turismo2$ID.Mes,turismo2$NumTurista,  ylab="Turismo", xlab="")

axis(1, labels=turismo2$ID.Mes, at=1:364, las=2)


#Agregar la tabla de turismo por Mes, sumando el turismo de las distintas comunidades
aggregate(turismo2 ~ ID.Mes, turismo2[turismo2$ID.Mes,], sum)
turismo3 <- aggregate(turismo2, turismo2["ID.Mes"], sum)


#Pruebas para graficar el turismo....

plot(turismo3$ID.Mes,turismo3$NumTurista,  ylab="Turismo", xlab="", type="s")
lines(lowess(turismo3$NumTurista))


plot(turismo3$NumTurista, xaxt="n",  ylab="Turismo", xlab="")
axis(1, labels=paste(year, quarter, sep="M"), at=1:12, las=3)


#Pruebas para agregar
turismo4 <- aggregate(turismo2 ~ ID.Mes , turismo2["ID.Mes"], sum)
turismo4 <- aggregate(turismo2$ID.Mes , by=list(turismo2$ID.Mes), sum)

numTur <- turismo3$NumTurista
rstTurismo <- merge(turismo2, tiempo, by.x = "ID.Mes", by.y = "ID.Mes")
turismo4 <- aggregate(rstTurismo, rstTurismo["ID.Mes"], sum)


#---------------------------------Segunda parte de la 1º iteración----------------------------------
#---------------------Prueba de un modelo de regresión del turismo a partir del tiempo--------------
#---------------------------------------------------------------------------------------------------

install.packages("data.table", dependencies = TRUE)

library(data.table)

t <- setDT(rstTurismo)[, .(Mes=mean(Mes), Anio=mean(Anio), NumTurista=sum(NumTurista)), by=ID.Mes]

#Prueba del modelo con meses y años
pred <- lm(t$NumTurista ~ t$Mes + t$Anio)

pred

attributes(pred)

pred$coefficients

summary(pred)

layout(matrix(c(1,2,3,4),2,2)) # 4 gráficos por ventana 
plot(pred)
layout(matrix(1)) # Restauración del valor inicial 


#Prueba del modelo con solo los meses

pred <- lm(t$NumTurista ~ t$Mes)

pred

attributes(pred)

pred$coefficients

summary(pred)

hist(pred$residuals)

layout(matrix(c(1,2,3,4),2,2)) # 4 gráficos por ventana 
plot(pred)
layout(matrix(1)) # Restauración del valor inicial 

cor(t$NumTurista, t$Mes)


t2 <- t[-c(1:3, 49), ]

cor(t2$NumTurista, t2$Mes)


#-------------------------------3º Parte 1º Iteración---------------------------------
#--------Tras probar a agregar los resultados de readTable con funciones R -----------
#--------decicimos que realizar consultas SQL podría resultar más sencillo------------
#-------------pero no nos dio tiempo a indagar mucho más en ellas---------------------


#---Consultas de prueba

#SELECT SUM(`turismo`.`NumTurista`) as turismoMensual FROM `turismo` JOIN `tiempo` ON `turismo`.`ID Mes`=`tiempo`.`ID Mes` GROUP BY `turismo`.`ID Comunidad` 
#SELECT `ID Mes`, tiempo.Mes, tiempo.Anio, `ID Comunidad`, `NumTurista` FROM `turismo` JOIN `tiempo` ON `turismo`.`ID Mes`=`tiempo`.`ID Mes`
#SELECT SUM(turismo.NumParados) as numParados, tiempo.Mes, tiempo.Anio FROM `turismo` JOIN `tiempo` ON `turismo`.`ID Mes`=`tiempo`.`ID Mes` GROUP BY `tiempo`.`ID Mes`

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

con <- dbConnect(RMySQL::MySQL(), host = "localhost",dbname="min",user = "root", password = "")

paradosBD <- dbGetQuery(con, sqlParados)
turistasBD <- dbGetQuery(con, sqlTuristas)
ipcBD <- dbGetQuery(con, sqlIPC)


cor(ipcBD$Indice, turistasBD$numTurista)