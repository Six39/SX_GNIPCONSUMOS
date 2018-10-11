#!/bin/bash

# Establece display a :0 en caso de no estar establecido -- necesario para capturar pantalla como tarea programada
: ${DISPLAY:=:0}
export DISPLAY
######### CONSTANTES

dia=`date +"%Y-%m-%d"`
hora=`date +"%H:%M"`
path_sendemail="/usr/bin"
#--# Configuración de SMTP

user_mail="" # mail@domain
pass_mail="" #  password
server_mail="" # servidor de correo, ejemplo -- gmail: smtp.gmail.com
port_mail="" # puerto del servidor, ejemplo -- gmail: 587 (ssl)
use_tls=""  # yes / no  (usar tls/ssl?)

#--# Configuración del correo

subject_mail="Monitoreo de API Twitter $dia-$hora" # Subject del correo -- predeterminado
sender_mail="" # mail que se mostrará al recibir correo
receiver_email="" # mail destino

# Genera capturas de pantalla del sitio

gnome-web-photo $1://$2/$3/$4 $5/temp/apitwitter.png -d 3 &

echo "capturando pantalla para generar imagen Gráfica General"

sleep 2s

gnome-web-photo $1://$2/$3 $5/temp/graf_gentwitter.png -d 3 &


echo "capturando pantalla para generar imagen Gráfica Por dia"

sleep 2s

gnome-web-photo $1://$2/$3/graficos.php?date=$dia $5/temp/graf_diatwitter.png -d 3 &

sleep 1s

echo "imagenes capturada con éxito" 
echo "generando correo y realizando el envio del mismo"
sleep 5s
$path_sendemail"/"sendEmail -o tls=$use_tls -f $sender_mail -t $receiver_email -s $server_mail:$port_mail -xu $user_mail -xp $pass_mail -a $5/temp/apitwitter.png -a $5/temp/graf_gentwitter.png  -a $5/temp/graf_diatwitter.png -u $subject_mail < $5/bin/message
echo "SE HA REALIZADO EL ENVIO DEL CORREO CON EXITO"
echo "SE TERMINA PROCESO, ESPERANDO NUEVO CICLO..."


