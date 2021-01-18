#Libera memoria
rm(list=ls())


#Funcion para comprobar si un paquete esta instalado
is.installed <- function(mypkg){ is.element(mypkg, installed.packages()[,1])}


#Si no esta instalado el paquete lo instalamos y lo cargamos
if (!is.installed("RMySQL")) {
  install.packages("RMySQL");
}

require(RMySQL) #if already installed


#A veces puede fallar porque no se encuentra en el directorio adecuado, si falla puede deberse a que intenta acceder a datos que no estan
#en el directorio actual, en estos casos parece que la mejor opción es reiniciar RStudio para que se cargue en el directorio adecuado
getwd()

source("procesosCarga.R", encoding="UTF-8")#Script con las funciones de carga

#Función que carga todo la información de los CSV en el datawarehouse, código en procesosCarga.R
cargaDWH() #7min