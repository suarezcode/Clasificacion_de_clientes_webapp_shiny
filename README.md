# Clasificacion_de_clientes_webapp_shiny
Creacción de una aplicación web utilizando programación reactiva con Shiny webapp de Rstudio

En esta oportunidad comparto el desarrollo de una aplicación web con programación reactiva utilizando el paquete Shiny WebApp de Rstudio, 
el modelo de clasificación implementado en la aplicación, así como su diseño, concepción, desarrollo, pruebas y validación se encuentran ya descritos
y explicados en el proyecto que lleva por nombre <a href=https://github.com/suarezcode/Clasificacion-de-clientes-por-tiempos-de-pago>Clasificación de clientes por tiempos de pago</a>,
el <a href=https://github.com/suarezcode/Clasificacion-de-clientes-por-tiempos-de-pago>link</a> anterior les llevará al repositorio del proyecto.

El proceso de desarrollo de la aplicación puede dividirse en las siguientes etapas:

## 1- Creación de la Aplicación Shiny Web App: 
    * Para crear una aplicación shiny debemos descargar e instalar previamente el paquete shiny, posterirmente en el menú principal seleccionamos la opción de crear un nuevo archivo 
    Shiny web app:
    </br>
    <div align="center">
    <img width="80%" src="./doc/images/Imagen1.png" alt='1'>
    </div>
    </br>
    * Asignamos un nombre a la aplicación 
    <div align="center">
    <img width="80%" src="./doc/images/Imagen2.png" alt='2'>
    </div>
    * Rstudio automáticamente genera dos archivos, server.R y ui.r:
    <div align="center">
    <img width="80%" src="./doc/images/Imagen3.png" alt='3'>
    </div>
    </br>
    <div align="center">
    <img width="80%" src="./doc/images/Imagen4.png" alt='4'>
    </div>
    </br>
    * En al archivo server.R escribimos el código para generar el modelo de clasificación, este correrá una vez, server.R constituye el "servidor" de la aplicación, el códgo incluye
    la conexión con la base de datos para obtener los datos primarios, la construción de los datasets y la ejecución de las operacines del modelo propiamente dichas declaradas dentro
    de una función con entradas y salidas, que a su vez está incluida dentro de la función shinyServer.
    </br>
    <div align="center">
    <img width="80%" src="./doc/images/Imagen5.png" alt='5'>
    </div>
    </br>  
    * Por su parte el archivo ui.R (User Interface) como su nombre sugiere, representa el la interfaz de usuario para manipluar la aplicación, en este archivo se incluye el código
    para generar widgets, plots, tablas y demás elementos que le permitiran al usuario manipular la aplicación y consumir la información
    </br>
    <div align="center">
    <img width="80%" src="./doc/images/Imagen6.png" alt='6'>
    </div>
   
