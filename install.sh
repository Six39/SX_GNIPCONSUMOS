#!/bin/bash

####################### SCRIPT DE INSTALACION #######################
# Cualquier cambio, asegurarse que esta modificado en "gniptwitter.sh"
# Ejecutar SOLO UNA VEZ para instalar dependencias de la aplicación

###########

echo "***** IMPORTANTE: Antes de continuar recuerda cambiar los parámetros no predeterminados para la correcta instalación y contar con LAMP previamente *****"
sleep 10s
echo "Se ha comenzado la instalación de dependencias del sistema, por favor espere..."
sleep 2s

echo " >>> 1 de 5 -- Instalando dependencias primarias ---"
####### Instala dependencias de aplicaciones en caso de no estar instaladas (core Debian)

# CURL
apt-get install curl                   # parametriza y captura datos la página del sitio para explotarla
apt-get install gnome-web-photo        # necesario para capturar pantalla
apt-get install sendemail              # necesario para enviar correo


########### Agrega los datos de usuario y contraseña que has creado aquí, en gniptwitter.sh #############

Path_absolute="/"   # Ruta absoluta (absolute path), donde has clonado el repositorio o donde será el directorio del programa
Cron_time=30  # (5,10,30,60) Agrega el tiempo en que quieres que las consumos sean tomados --- esto se añadirá a tu cron

root_db=""      # Usuario con todos los permisos en la DB, puede ser ROOT
root_db_pass="" # Contraseña del usuario de la DB con todos los privilegios, puede ser ROOT
new_gnip_db="gnipconsumos_tw" # Nombre de la base de datos nueva --- Predeterminado
new_user_gnip_db="gnip_acceso" # Nombre del usuario que accederá a la base de datos -- Predeterminado
new_pass_gnip_db="Gn1p_p4sS" # Contraseña del nuevo usuario que accederá a la base de datos -- Predeterminado
new_table_gnip_db="gnip_consumos" # Tabla donde almacenará los datos --- Predeterminado

Path_site="/var/www/html"       #Path del sitio web --- predeterminado con APACHE
Nom_site="gnipconsumos" # Nombre del sitio, recuerda agregarlo a gniptwitter.sh en caso de ser editado -- Predeterminado...
Host="localhost" # Dirección del sitio web --- predeterminado 

echo " >>> 2 de 5 -- Generando los directorios de trabajo ---"

mkdir -m777 ./"temp" # Crea carpeta de temporales
mkdir -m777 $Path_site/$Nom_site          #Genera el directorio del sitio
mkdir -m777 $Path_site/"assets" #Genera el directorio assets oara Css del sitio de twitter consumos
mkdir -m777 $Path_site/$Nom_site/"assets" #Genera el directorio assets del sitio
mkdir -m777 $Path_site/$Nom_site/"bin" #Genera el directorio bin del sitio ** a futuro se usará este directorio con más características
cp -a ./install_temp/. $Path_site/$Nom_site/"assets"  #Copia dependencias del sitio
mv $Path_site"/"$Nom_site"/assets/empty_temp/"* $Path_site/$Nom_site/  #Copia dependencias PHP del sitio
rm -r $Path_site"/"$Nom_site"/assets/empty_temp/"

echo " >>>>>>>>>>> Los directorios de trabajo han sido creados  <<<<<<<<<<<"
sleep 2s

# GENERA LA BASE DE DATOS

echo " >>> 3 de 5 -- Generando la base de datos---"

mysql -u $root_db -p$root_db_pass -e "CREATE database $new_gnip_db; GRANT ALL PRIVILEGES ON $new_gnip_db.* TO $new_user_gnip_db@localhost IDENTIFIED BY '$new_pass_gnip_db'"
mysql -u $new_user_gnip_db -p$new_pass_gnip_db -e "USE $new_gnip_db;"
mysql -p $new_gnip_db -u $new_user_gnip_db -p$new_pass_gnip_db -e "CREATE TABLE $new_table_gnip_db (
				
				id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
				fecha VARCHAR(10),
				hora VARCHAR(5),
				consumo INT(20),				
				diferencia INT(20)
				
				) ENGINE = INNODB DEFAULT CHARSET =utf8;"
				# fecha y hora = varchar, ya que solo es informativo				

echo " >>>>>>>>>>> La base de datos ha sido creada <<<<<<<<<<<"
sleep 2s

# GENERA EL ARCHIVO DE CONEXION DE PHP CON MARIA DB

echo " >>> 4 de 5 -- Generando la conexión de la base de datos para PHP---"
echo "GENERANDO EL ARCHIVO DE CONEXION DE PHP, EN CASO NECESARIO PUEDES EDITARLO EN LA RUTA DEL SITIO WEB \"\bin\conectar.php\""
sleep 5s


echo "<?php

\$server=\"$Host\";
\$user=\"$new_user_gnip_db\";
\$pass=\"$new_pass_gnip_db\";
\$base=\"$new_gnip_db\";
\$db_tabla=\"$new_table_gnip_db\";

\$con= new mysqli(\$server, \$user, \$pass, \$base) or die (\"Error\" . mysqli_error(\$con));

if (\$con->connect_errno){
	printf(\"Fallo la conexion\", \$con->connect_error);
	exit();
	
}

?>" > $Path_site"/"$Nom_site"/bin/"conectar.php

echo " >>>>>>>>>>> Se ha creado el archivo de conexión del sitio <<<<<<<<<<<"
sleep 2s

echo " >>> 5 de 5 -- Agregando la tarea programada y finalizando instalación"
######## AGREGANDO TAREA A CRON ##############
echo "Instalando tarea programada con el tiempo indicado en el fichero de instalación"
#Respaldando cron
sleep 2s
echo "Respaldando su configuración de cron (cron_backup)"
crontab -l >cron_backup
sleep 2s
echo "Respaldo generado en este directorio de instalación...completo"
crontab -l >cron_gnip
#Añadiendo tarea programada
echo "*/$Cron_time * * * * bash $Path_absolute/gniptwitter.sh" >>cron_gnip
crontab cron_gnip
rm cron_gnip
sleep 1s
echo "Se ha generado la tarea, puede modificarlo en cron según necesite (crontab -e)"
echo "Mostrando las tareas programadas en este equipo:"
crontab -l
sleep 1s
echo "SE HA TERMINADO LA INSTALACION, FAVOR DE VERIFICAR EL ARCHIVO gniptwitter.sh y configurar las variables"