#Script con las funciones necesarias para la carga de los datos en el datawarehouse

# <<- hace que las variables sean globales
inicializarVariables <- function(){
  
  print("Inicializando variables...")
  
  #Diccionario de meses
  dicMeses <<- data.frame(numero = c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12), cadena = c("Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"))
  
  
  #Indices del csv, para temperaturas
  i_comunidad <<- 1
  i_anio <<- 2
  i_mes <- 3
  i_temp_med <<- 4
  i_temp_min <<- 5
  i_temp_max <<- 6
  i_pres <<- 7
  i_racha <<- 8
  
  #Indices del csv para acceder a los datos de turismo
  #1º Insertar numero de turistas, con comunidad y trimestre
  i_comunidad <<- 1
  i_tipo_dato <<- 2
  i_periodo <<- 3 # YYYYMXX; YYYY = año, XX = mes
  i_total <<- 4
  
}




cargarCSVs <- function(){
  print("Cargando CSVs...")
  pib <<- read.table("datasets/deuda.csv", skip = 0, header =TRUE, sep =",", encoding="UTF-8")
  temperaturas <<- read.table("datasets/temperaturasEspaña.csv", skip = 0, header =TRUE, sep =",", encoding="UTF-8")
  criminalidad <<- read.table("datasets/Criminalidad.csv", skip = 0, header =TRUE, sep =",", encoding="UTF-8")
  turismo <<- read.table("datasets/Turismo por Comunidades y Meses INE.csv", skip = 0, header =TRUE, sep =";", encoding="UTF-8")
  precio <<-read.table("datasets/Precio de Vivienda INE.csv", skip = 0, header =TRUE, sep =";", encoding="UTF-8")
  paro <<-read.table("datasets/paroComunidades.csv", skip = 0, header =TRUE, sep =",", encoding="UTF-8")
  ipc <<- read.table("datasets/IPC Por Comunidades y Meses.csv", skip = 0, header =TRUE, sep =";", encoding="UTF-8")
  comunidades <<- read.table("datasets/Comunidad.csv", skip = 0, header =TRUE, sep =";", encoding="UTF-8")
}


conectarBD <- function(){
  print("Conectando con la BD...")
  con <<- dbConnect(RMySQL::MySQL(), host = "localhost",dbname="min",user = "root", password = "")
}


#Cargar la tabla de dimension de tiempo
cargarTiempo <- function(){
  print("Cargando la dimensión de tiempo...")
  for(i in c(2000:2020)){ #Rango de Años de la Dimensión Tiempo
    for (j in c(1:12)) { #Rango de Meses
      trimestre <- floor((j-1)/3) + 1;
      #print(sprintf("Mes: %d, trimestre: %d", j, trimestre))
      sql <- sprintf("INSERT INTO `tiempo` (`ID Mes`, `Mes`, `Trimestre`, `Anio`) VALUES (NULL, '%d', '%d', '%d');",j, trimestre, i)
      rs <- dbSendQuery(con, sql)
      
    }
    #print(sprintf("Año %d terminado", i))
  }
}


#Cargar la tabla de dimension de comunidades
cargarComunidades <- function(){
  print("Cargando la dimension de comunidades...")
  for(i in 1:nrow(comunidades)){
    comunidad = comunidades[i, 1]
    #print(sprintf("La comunidad es %s", comunidad))
    sql <- sprintf("INSERT INTO `comunidad` (`ID Comunidad`, `NombreComunidad`) VALUES (NULL, '%s');",comunidad)
    rs <- dbSendQuery(con, sql)
  }
  
}

#Cargar la tabla de dimension de temperaturas
cargarTemperaturas <- function() {
  print("Cargando la dimension de temperaturas...")
  for(i in 1:nrow(temperaturas)){ #Recorremos las distintas filas de la tabla de temperaturas
    sql <- sprintf("INSERT INTO `temperatura` (`ID Temperatura`, `TempMedia`, `TempMax`, `TempMin`, `Racha`, `Presion`) VALUES (NULL, '%#.2f', '%#.2f', '%#.2f', '%#.2f', '%#.2f');", temperaturas[i, i_temp_med], temperaturas[i, i_temp_max], temperaturas[i, i_temp_min], temperaturas[i, i_racha],temperaturas[i, i_pres])
    #print(sql);
    rs <- dbSendQuery(con, sql)
  }
}

#Cargar la tabla de dimension de preciovivienda

cargarPrecioVivienda <- function() {
  print("Cargando la dimension de preciovivienda...")
  for(i in 1:nrow(precio)){
    if((precio[i,1] != "Nacional") && (precio[i, 3] == "Índice")) {
      a1 = precio[i,2]
      a2 = precio[i,5]
      auxSql <- sprintf("SELECT * FROM `preciovivienda` WHERE TipoVivienda = '%s' AND Indice = '%f'",a1,a2)
      duplicate = dbGetQuery(con, auxSql)
      if(nrow(duplicate) == 0){
        sql <- sprintf("INSERT INTO `preciovivienda` (`ID PrecioVivienda`, `TipoVivienda`, `Indice`) VALUES (NULL, '%s', '%#.3f');",a1,a2)
        rs <- dbGetQuery(con, sql)
      }
    }
  }
}

#Carga de la tabla de criminalidad
cargaCriminalidad <- function() {
  print("Cargando la dimensión de criminalidad...")
  for (k in  1:nrow(criminalidad)) {
    sql <- sprintf("SELECT * FROM `criminalidad` WHERE `TipoDelito` = '%s' and `NumDenuncias` = '%f';", criminalidad[k,4], criminalidad[k,5])
    rs <- dbGetQuery(con, sql)
    if (nrow(rs) == 0) {
      sql <- sprintf("INSERT INTO `criminalidad`(`ID Criminalidad`, `TipoDelito`, `NumDenuncias`) VALUES (NULL,'%s','%f');", criminalidad[k,4], criminalidad[k, 5])
      rs <- dbGetQuery(con, sql)
    }
  }
}


#Cargar la tabla de dimension de ipc
cargaIPC <- function() {
  print("Cargando la dimensión de IPC...")
  for (k in 1:nrow(ipc)) {
    if (ipc[k, 3] == 'Índice' & ipc[k,1] != 'Nacional') {
      sql <- sprintf("SELECT * FROM `ipc` WHERE `GrupoECOICOP` = '%s' and `Indice` = '%f';", ipc[k,2], ipc[k,5])
      rs <- dbGetQuery(con, sql)
      if (nrow(rs) == 0) {
        sql <- sprintf("INSERT INTO `ipc`(`ID IPC`, `GrupoECOICOP`, `Indice`) VALUES (NULL, '%s', '%f');",ipc[k,2], ipc[k,5])
        rs <- dbGetQuery(con, sql)
      }
    }
  }
}

#Carga la tabla de hechos

cargarTablaDeHechos <- function() {
  print("Cargando tabla de hechos...")
  idHechoIPC <- 0L ########################### Esto se actualiza en cada iteracion de turismo y se inserta en turismo como IPC  idHechoIPC <- idHechoIPC + 1
  idHechoCrim <- 0L
  
  for(i in 1:nrow(turismo)){ #Recorremos las distintas filas de la tabla de temperaturas
    
    periodo <- turismo[i, i_periodo] #el campo periodo tiene el siguiente formato YYYYMXX Siendo YYYY el año y XX el mes
    anio <- as.numeric(substr(periodo, 1, 4))
    mes <- as.numeric(substr(periodo, 6, 7))
    trimestre <- floor((mes-1)/3) + 1; # Crea el trimestre en el que se encuentra el mes
    periodoT <- paste(anio, "T", trimestre, sep = "")
    comunidad <- turismo[i, i_comunidad]
    num2mes <- dicMeses[mes,2] #Utilización de un diccionario para convertir el número en mes
    
    
    if(turismo[i, i_comunidad] != "Total" & turismo[i, i_tipo_dato] == "Dato base"){
      
      #print(periodo)
      #print(comunidad)
      
      #Id de turismo 
      idTurismo <- turismo[i, i_total]
      idCriminalidad <- "NULL"
      #Id del mes
      sql <- sprintf("SELECT * FROM `tiempo` WHERE tiempo.Mes=%d AND tiempo.Anio=%d", mes, anio)
      rs <- dbGetQuery(con, sql)
      idMes <-toString(rs[1]) #Id corresponde con el primer indice de la tabla de la dimension Mes, si se mira la variable rs se puede ver más en detalle
      
      #Id de la comunidad
      
      sql <- sprintf("SELECT * FROM comunidad WHERE comunidad.NombreComunidad='%s'", comunidad)
      rs <- dbGetQuery(con, sql)
      idComunidad <- toString(rs[1])
      
      #Id del IPC
      dataIPC <- ipc[which(ipc$Tipo.de.dato == "Índice" & ipc$Periodo == toString(periodo) & ipc$X.U.FEFF.Comunidades.y.Ciudades.Autónomas == toString(comunidad)),]
      for (j in 1:nrow(dataIPC)) {
        dataIPCConcreto <- dataIPC[j,]
        sql <- sprintf("SELECT * FROM `ipc` WHERE `GrupoECOICOP` = '%s' and `Indice` = '%f';", dataIPCConcreto[1, 2], dataIPCConcreto[1,5]) #Cogemos la columna 5 porque es el numero total
        rs <- dbGetQuery(con, sql)
        if(nrow(rs) != 0){
          idIPC <- rs[1]
          idIPCTurismo <- idHechoIPC
          sql <- sprintf("INSERT INTO `ipcids`(`Id`, `idHecho`, `idDatos`) VALUES (NULL,'%d','%d');", idHechoIPC, idIPC[1,1]) 
          rs <- dbGetQuery(con, sql)        
        }
        else{
          idIPCTurismo <- "NULL"
        }
        
      }
      
      #Id Criminalidad
      
      dataCRIM <- criminalidad[which(criminalidad$Comunidad == toString(comunidad) & criminalidad[2] == anio & criminalidad$Trimestre == trimestre),]
      dataCRIM
      for (k in 1:nrow(dataCRIM)) {
        dataCrimConcreto <- dataCRIM[k,]
        sql <- sprintf("SELECT * FROM `criminalidad` WHERE `TipoDelito` = '%s' and `NumDenuncias` = '%f';", dataCrimConcreto[1, 4], dataCrimConcreto[1,5])
        rs <- dbGetQuery(con, sql)
        if(nrow(rs) != 0){
          idCrim <- rs[1]
          idCriminalTurismo <- idHechoCrim
          sql <- sprintf("INSERT INTO `crimenids`(`Id`, `idHecho`, `idDatos`) VALUES (NULL,'%d','%d');", idHechoCrim, idCrim[1,1]) 
          rs <- dbGetQuery(con, sql)        
        }
        else{
          idCriminalTurismo <- "NULL"
        }
      }
      
      
      #Id del PrecioVivienda
      
      dataPrecioVivienda <- precio[which(precio$X.U.FEFF.Comunidades.y.Ciudades.Autónomas == toString(comunidad) & precio$Periodo == toString(periodoT) & precio$General..vivienda.nueva.y.de.segunda.mano == "General" & precio$Índices.y.tasas == "Índice"),]
      sql <- sprintf("SELECT * FROM `preciovivienda` WHERE TipoVivienda = '%s' AND Indice = '%f'",dataPrecioVivienda[1,2],dataPrecioVivienda[1,5])
      rs <- dbGetQuery(con, sql)
      if(nrow(rs) != 0){
        idPrecio <- toString(rs[1]) 
      }
      else{
        idPrecio <- "NULL"
      }
      #Id del NumParadas
      
      dataNumParadas <- paro[which(paro$Comunidad == toString(comunidad) & paro$Año == anio & paro$Mes == toString(num2mes)),]
      idNumParadas <- toString(dataNumParadas$Numero.Paradas)
      if(idNumParadas == ""){
        idNumParadas <- "NULL"
      }
      #Id del PIB
      
      dataPIB <- pib[which(pib$Comunidades == toString(comunidad) & pib[2] == anio & pib$Trimestre == trimestre),]
      if(nrow(dataPIB) != 0){
        idPIB <- toString(dataPIB$PIB)
      }
      else{
        idPIB <- "NULL"
      }
      #Id de la Temperatura
      
      dataTemperatura <- temperaturas[which(temperaturas$Comunidad == toString(comunidad) & temperaturas$Año == anio & temperaturas$Mes == toString(num2mes)),]
      if(nrow(dataTemperatura) != 0){
        sql <- sprintf("SELECT * FROM temperatura WHERE TempMedia = '%#.2f' AND TempMax = '%#.2f' AND TempMin = '%#.2f' AND Racha = '%#.2f' AND Presion = '%#.2f'", dataTemperatura$Temperatura.Media, dataTemperatura$Temperatura.Maxima,dataTemperatura$Temperatura.Minima, dataTemperatura$Racha, dataTemperatura$Presion.Maxima)
        rs <- dbGetQuery(con, sql)
        if(nrow(rs) != 0){
          idTemperatura <- toString(rs[1]) 
        }
        else{
          idTemperatura <- "NULL"
        }
      }
      else{
        idTemperatura <- "NULL"
      }
      
      
      #Insertar el datos de turismo con comunidad, mes y año
      sql <- sprintf("INSERT INTO `turismo` (`ID Mes`, `ID Comunidad`, `ID IPC`, `ID PrecioVivienda`, `ID Criminalidad`, `ID Temperatura`, `NumTurista`, `deudaPubPIB`, `NumParados`) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s);", idMes, idComunidad, idIPCTurismo, idPrecio, idCriminalTurismo, idTemperatura, idTurismo, idPIB, idNumParadas)
      #print(sql)
      rs <- dbGetQuery(con, sql)
      idHechoIPC <- idHechoIPC + 1
      idHechoCrim <- idHechoCrim + 1
    }
  }
  
}

#Función para cargar todas las dimensiones
cargarDimensiones <- function() {
  print("Cargando las dimensiones...")
  cargarTemperaturas()
  cargaIPC()
  cargaCriminalidad()
  cargarPrecioVivienda()
  cargarComunidades()
  cargarTiempo()
}


#Carga toda la información en el Datawarehouse
cargaDWH <- function(variables) {
  
  print("Cargando Datawarehouse")
  t1 = Sys.time()
  
  #Si no esta instalado el paquete lo instalamos y lo cargamos
  if (!is.installed("RMySQL")) {
    install.packages("RMySQL");
  }
  
  require(RMySQL) #if already installed
  
  #Praparar variables y CSVs
  inicializarVariables()
  cargarCSVs()
  
  #Conexión con la BD
  conectarBD()
  
  #Carga de las dimensiones y de la tabla de hechos en la BD
  cargarDimensiones()
  cargarTablaDeHechos()

  t2 = Sys.time() - t1
  print("Carga finalizada con éxito.")
  print(t2)
  
}
