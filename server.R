#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny);
library(RODBC);
library(writexl);
library(dplyr);
library(rpart);
library(rpart.plot);


##########CONEXIÃÂN A BASE DE DATOS##############
options(scipen=999)

conexion_repositorio<- odbcDriverConnect('driver={SQL Server};
                                         server=DLYSERVER;
                                         database=datamart_cobranzas_sql;
                                         UID=sa;
                                         PWD=');
########### CONSULTA PRIMARIA DE DATOS##############
options(scipen=999)
consulta_repositorio<- sqlQuery(conexion_repositorio,paste0("SELECT PAGO_ID, PAGO_FECHA, PAGO_MONTO, FACTURA_ASOCIADA, FACTURA_FECHA, CODIGO_CLIENTE, NOMBRE_CLIENTE, CODIGO_VENDEDOR, NOMBRE_VENDEDOR, DIAS_DE_COBRO  FROM dbo.REGISTRO_PAGOS  WHERE FACTURA_FECHA >= '31/03/2019' AND ANULADO_COBRANZA = 0 AND ANULADO_POSTEO = 0 AND REVERSADO_COBRANZA = '' AND REVERSADO_POSTEO = '' AND DIAS_DE_COBRO >0  ")) ;

vendedores_repositorio<- sqlQuery(conexion_repositorio,paste0("SELECT CODIGO_VENDEDOR, NOMBRE_VENDEDOR  FROM dbo.REGISTRO_PAGOS  WHERE FACTURA_FECHA >= '31/03/2019' AND ANULADO_COBRANZA = 0 AND ANULADO_POSTEO = 0 AND REVERSADO_COBRANZA = '' AND REVERSADO_POSTEO = '' AND DIAS_DE_COBRO >0 GROUP BY CODIGO_VENDEDOR, NOMBRE_VENDEDOR ")) 
odbcClose(conexion_repositorio);
todos<-data.frame("CODIGO_VENDEDOR"= as.character("00AAA00"),"NOMBRE_VENDEDOR"=as.character("TODOS"))
vendedores_repositorio<-rbind(todos,vendedores_repositorio)
vendedores_repositorio<- vendedores_repositorio[order(vendedores_repositorio$CODIGO_VENDEDOR,vendedores_repositorio$NOMBRE_VENDEDOR),]
vendedores_repositorio$SELECCION<-paste(vendedores_repositorio$CODIGO_VENDEDOR,vendedores_repositorio$NOMBRE_VENDEDOR)
vendedores_repositorio$ID<-row.names(vendedores_repositorio)

evelyn.cristina<-function(inicio,vendedorSelect){



vendedorf<-vendedores_repositorio[vendedores_repositorio$SELECCION==vendedorSelect,]
fecha.inicio<-as.Date(inicio)


########### PRIMERA CLASIFICACIÃÂN GENERAL DE PAGOS###########

ifelse(vendedorSelect=="00AAA00 TODOS",agrupamientof<-as.data.frame(consulta_repositorio),agrupamientof<-as.data.frame(consulta_repositorio[as.character(consulta_repositorio$CODIGO_VENDEDOR)==as.character(vendedorf$CODIGO_VENDEDOR) & as.character(consulta_repositorio$NOMBRE_VENDEDOR)==as.character(vendedorf$NOMBRE_VENDEDOR),]));
agrupamiento<-group_by_all(agrupamientof[as.Date(agrupamientof$FACTURA_FECHA)>=fecha.inicio,c(6:10)])
clasificacion<- agrupamiento;
clasificacion$GRUPO <- ifelse(clasificacion$DIAS_DE_COBRO <= 5, "5 dias"
                              , ifelse(clasificacion$DIAS_DE_COBRO > 5 & clasificacion$DIAS_DE_COBRO <=9, "de 6 a 9 dias"
                                       , ifelse(clasificacion$DIAS_DE_COBRO >9 & clasificacion$DIAS_DE_COBRO <=11, "de 10 a 11 dias"
                                                , ifelse(clasificacion$DIAS_DE_COBRO >11 & clasificacion$DIAS_DE_COBRO <=15, "de 12 a 15 dias"
                                                         , ifelse(clasificacion$DIAS_DE_COBRO >15 &  clasificacion$DIAS_DE_COBRO <=18, "de 16 a 18 dias" ,"mas de 18 dias")))));


##########SEGUNDA CLASIFICACIÃÂN GENERAL DE PAGOS###########
clasificacion$CINCO_DIAS <- ifelse(clasificacion$DIAS_DE_COBRO <=5, 1,0);
clasificacion$NUEVE_DIAS <- ifelse(clasificacion$DIAS_DE_COBRO <=9,1,0);
clasificacion$ONCE_DIAS <- ifelse(clasificacion$DIAS_DE_COBRO <=11,1,0);
clasificacion$QUINCE_DIAS <- ifelse(clasificacion$DIAS_DE_COBRO <=15, 1,0);
clasificacion$DIECIOCHO_DIAS <- ifelse(clasificacion$DIAS_DE_COBRO <=18, 1,0);
clasificacion$MAS_DIECIOCHO_DIAS <- ifelse(clasificacion$DIAS_DE_COBRO !=0,1,0);


clasificacion2<-clasificacion[,-c(5,6)];
select_datos<- clasificacion2[,-c(5:10)];


##########AGRUPAMIENTO Y TOTALIZACIÃÂN#############

clasificacion_5dias<- clasificacion2[clasificacion2$CINCO_DIAS==1,-c(6:10)];
agrupamiento_5dias<-group_by(clasificacion_5dias, CODIGO_CLIENTE, NOMBRE_CLIENTE, CODIGO_VENDEDOR,  NOMBRE_VENDEDOR, CINCO_DIAS);
pagos_5dias<- summarise(agrupamiento_5dias, N_PAGOS_5DIAS = n());
pagos_5dias<- pagos_5dias[,-5];

clasificacion_9dias<- clasificacion2[clasificacion2$NUEVE_DIAS==1,c(1:4,6)];
agrupamiento_9dias<-group_by(clasificacion_9dias, CODIGO_CLIENTE, NOMBRE_CLIENTE, CODIGO_VENDEDOR,  NOMBRE_VENDEDOR, NUEVE_DIAS);
pagos_9dias<- summarise(agrupamiento_9dias, N_PAGOS_9DIAS = n());
pagos_9dias<- pagos_9dias[,-5];

clasificacion_11dias<- clasificacion2[clasificacion2$ONCE_DIAS==1,c(1:4,7)];
agrupamiento_11dias<-group_by(clasificacion_11dias, CODIGO_CLIENTE, NOMBRE_CLIENTE, CODIGO_VENDEDOR,  NOMBRE_VENDEDOR, ONCE_DIAS);
pagos_11dias<- summarise(agrupamiento_11dias, N_PAGOS_11DIAS = n());
pagos_11dias<- pagos_11dias[,-5]

clasificacion_15dias<- clasificacion2[clasificacion2$QUINCE_DIAS==1,c(1:4,8)];
agrupamiento_15dias<-group_by(clasificacion_15dias, CODIGO_CLIENTE, NOMBRE_CLIENTE, CODIGO_VENDEDOR,  NOMBRE_VENDEDOR, QUINCE_DIAS);
pagos_15dias<- summarise(agrupamiento_15dias, N_PAGOS_15DIAS = n());
pagos_15dias<- pagos_15dias[,-5]

clasificacion_18dias<- clasificacion2[clasificacion2$DIECIOCHO_DIAS==1,c(1:4,9)];
agrupamiento_18dias<-group_by(clasificacion_18dias, CODIGO_CLIENTE, NOMBRE_CLIENTE, CODIGO_VENDEDOR,  NOMBRE_VENDEDOR, DIECIOCHO_DIAS);
pagos_18dias<- summarise(agrupamiento_18dias, N_PAGOS_18DIAS = n());
pagos_18dias<- pagos_18dias[,-5]

clasificacion_mas18dias<- clasificacion2[clasificacion2$MAS_DIECIOCHO_DIAS==1,c(1:4,10)];
agrupamiento_mas18dias<-group_by(clasificacion_mas18dias, CODIGO_CLIENTE, NOMBRE_CLIENTE, CODIGO_VENDEDOR,  NOMBRE_VENDEDOR, MAS_DIECIOCHO_DIAS);
pagos_mas18dias<- summarise(agrupamiento_mas18dias, N_PAGOS_MAS18DIAS = n());
pagos_mas18dias<- pagos_mas18dias[,-5]

agrupamiento_totales<-group_by(clasificacion2, CODIGO_CLIENTE, NOMBRE_CLIENTE, CODIGO_VENDEDOR,  NOMBRE_VENDEDOR);

totales<- summarise(agrupamiento_totales, TOTAL_PAGOS = n());


##########DETERMINACIÃÂN DE LA FRECUENCIA RELATIVA DE LOS GRUPOS DE PAGOS POR CLIENTE###########
select_datos2<-totales[,-5];
clasificacion_final<- merge(x = select_datos2, y =  pagos_5dias,  all.x = TRUE );
clasificacion_final<- merge(x = clasificacion_final, y = pagos_9dias, all.x = TRUE);
clasificacion_final<- merge(x = clasificacion_final, y = pagos_11dias, all.x = TRUE);
clasificacion_final<- merge(x = clasificacion_final, y = pagos_15dias, all.x = TRUE);
clasificacion_final<- merge(x = clasificacion_final, y = pagos_18dias, all.x = TRUE);
clasificacion_final<- merge(x = clasificacion_final, y = pagos_mas18dias, all.x = TRUE);
clasificacion_final<- merge(x = clasificacion_final, y = totales, all.x = TRUE);

clasificacion_final$N_PAGOS_5DIAS[is.na(clasificacion_final$N_PAGOS_5DIAS)] <- 0;
clasificacion_final$N_PAGOS_9DIAS[is.na(clasificacion_final$N_PAGOS_9DIAS)] <- 0;
clasificacion_final$N_PAGOS_11DIAS[is.na(clasificacion_final$N_PAGOS_11DIAS)] <- 0;
clasificacion_final$N_PAGOS_15DIAS[is.na(clasificacion_final$N_PAGOS_15DIAS)] <- 0;
clasificacion_final$N_PAGOS_18DIAS[is.na(clasificacion_final$N_PAGOS_18DIAS)] <- 0;
clasificacion_final$N_PAGOS_MAS18DIAS[is.na(clasificacion_final$N_PAGOS_MAS18DIAS)] <- 0;

clasificacion_final$PROPORCIONpagos_5dias <-round((clasificacion_final$N_PAGOS_5DIAS/ clasificacion_final$TOTAL_PAGOS),2);
clasificacion_final$PROPORCIONpagos_9dias <- round((clasificacion_final$N_PAGOS_9DIAS/ clasificacion_final$TOTAL_PAGOS),2);
clasificacion_final$PROPORCIONpagos_11dias <- round((clasificacion_final$N_PAGOS_11DIAS/ clasificacion_final$TOTAL_PAGOS),2);
clasificacion_final$PROPORCIONpagos_15dias <- round((clasificacion_final$N_PAGOS_15DIAS/ clasificacion_final$TOTAL_PAGOS),2);
clasificacion_final$PROPORCIONpagos_18dias <- round((clasificacion_final$N_PAGOS_18DIAS/ clasificacion_final$TOTAL_PAGOS),2);
clasificacion_final$PROPORCIONpagos_mas18dias <-round((clasificacion_final$N_PAGOS_MAS18DIAS/ clasificacion_final$TOTAL_PAGOS),2);

#CLASIFICACIÃÂN FINAL DE CLIENTES DE ACUERDO AL 95% DE SUS PAGOS#
clasificacion_final$TIPO_CLIENTE <- ifelse(clasificacion_final$PROPORCIONpagos_5dias >= 0.95, "Cliente A: a 5 dias"
                                           , ifelse(clasificacion_final$PROPORCIONpagos_5dias < 0.95 & clasificacion_final$PROPORCIONpagos_9dias >=0.95, "Cliente B: a 9 dias"
                                                    , ifelse(clasificacion_final$PROPORCIONpagos_9dias < 0.95 & clasificacion_final$PROPORCIONpagos_11dias >=0.95, "Cliente C: a 11 dias"
                                                             , ifelse(clasificacion_final$PROPORCIONpagos_11dias < 0.95 & clasificacion_final$PROPORCIONpagos_15dias >=0.95, "Cliente D: a 15 dias"
                                                                      , ifelse(clasificacion_final$PROPORCIONpagos_15dias < 0.95 & clasificacion_final$PROPORCIONpagos_18dias >=0.95, "Cliente E: a 18 dias","Cliente F: mas de 18 dias")))));



####### MODELO DE ÃÂRBOL DE CLASIFICACIÃÂN GENERAL#########
data_arbol<- clasificacion_final[,c(12:18)];
modelo_arbol<- rpart(TIPO_CLIENTE~.,method = "class", data = data_arbol, minsplit = 2, minbucket = 1);
clasificacion_final_salida<-as.data.frame(subset (clasificacion_final, select=c(18,2,1,4,3,5,6,7,8,9,10,11,12,13,14,15,16,17)))
salida<-list(clasificacion_final_salida,modelo_arbol)
return(salida)
}



shinyServer(function(input, output) {
   
  output$distPlot <- renderPlot({
    grafico<-evelyn.cristina(input$FechaInicio,input$Vendedor)
    rpart.plot(grafico[[2]], type = 5, digits = 2, roundint=FALSE)
    
  })
  
  output$disttable<- renderTable({
    tabla<-evelyn.cristina(input$FechaInicio,input$Vendedor)
    tabla[[1]][order(tabla[[1]][1],tabla[[1]][2],tabla[[1]][4]),];

    
  })
  
})
