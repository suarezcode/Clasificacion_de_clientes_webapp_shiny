#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(RODBC);
library(writexl);
library(dplyr);
library(rpart);
library(rpart.plot);


##########CONEXIÓN A BASE DE DATOS##############
options(scipen=999)

conexion_repositorio<- odbcDriverConnect('driver={SQL Server};
                                         server=DLYSERVER;
                                         database=datamart_cobranzas_sql;
                                         UID=sa;
                                         PWD=');
########### CONSULTA PRIMARIA DE DATOS##############
options(scipen=999)
vendedores_repositorio<- sqlQuery(conexion_repositorio,paste0("SELECT CODIGO_VENDEDOR, NOMBRE_VENDEDOR  FROM dbo.REGISTRO_PAGOS  WHERE FACTURA_FECHA >= '31/03/2019' AND ANULADO_COBRANZA = 0 AND ANULADO_POSTEO = 0 AND REVERSADO_COBRANZA = '' AND REVERSADO_POSTEO = '' AND DIAS_DE_COBRO >0 GROUP BY CODIGO_VENDEDOR, NOMBRE_VENDEDOR ")) ;
odbcClose(conexion_repositorio);
todos<-data.frame("CODIGO_VENDEDOR"= as.character("00AAA00"),"NOMBRE_VENDEDOR"=as.character("TODOS"))
vendedores_repositorio<-rbind(todos,vendedores_repositorio)
vendedores_repositorio<- vendedores_repositorio[order(vendedores_repositorio$CODIGO_VENDEDOR,vendedores_repositorio$NOMBRE_VENDEDOR),]
vendedores_repositorio$SELECCION<-paste(vendedores_repositorio$CODIGO_VENDEDOR,vendedores_repositorio$NOMBRE_VENDEDOR)
vendedores_repositorio$ID<-row.names(vendedores_repositorio)


shinyUI(fluidPage(
  fluidRow(
    column(width = 12, tags$h1("Clasificación de Clientes por tiempos de pago 'Mantis'") )
   
  ),
  fluidRow(
    column(width = 5,
      dateInput("FechaInicio","Introduzca una fecha de inicio para clasificar los pagos",value = "2019-03-31"),
      selectInput("Vendedor","Selecciona un Vendedor",choices=vendedores_repositorio$SELECCION)
     ),
    column(width=7,tags$h1("Gráfico", alig="center"),
           plotOutput("distPlot")
  )),
  fluidRow(column(width=12,tags$h1("Detalle"),
                  tableOutput("disttable")))
))






