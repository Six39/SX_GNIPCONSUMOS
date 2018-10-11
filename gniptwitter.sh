#!/bin/bash

#### Revisar la función "inserta_dato (l.127)" y editar según zona horaria (PREDETERMINADO para México GTM -6)
######### VARIABLES:

Path_absolute="/"   # Ruta absoluta (absolute path), donde has clonado el repositorio/ directorio de trabajo 

# -- # INGRESAR credenciales de acceso a GNIP TWITTER

gnipuser=""          # usuario/correo página GNIP TWITTER
gnippass=""       # contraseña página GNIP TWITTER
gnipsite="https://console.gnip.com/users/sign_in"       # URL DE GNIP TWITTER --- predeterminado
gnipsite_usage="https://console.gnip.com/usage/daily"   # URL DE GNIP TWITTER CONSUMOS "USAGE" -- predeterminado
gnipcookie="galleta_apitwitter"   # RUTA DE LA COOKIE GENERADA --- predeterminado

# -- # INGRESAR DATOS DE TU SERVIDOR WEB -- predeterminado en caso de usar instalador

ssh="http" # ingresar http (80) https (443), según sea la salida de TU SERVIDOR
Path_site="/var/www/html"       #Path del sitio web --- predeterminado con APACHE
Home_Page="index.html" # Nombre de la página principal que mostrara los consumos del mes-- predeterminado
GNIP_Page="consumo.html"  # Nombre de la página que muestra la descarga del sitio oficial de consumos GNIP --- predeterminado
Nom_site="gnipconsumos"  # Nombre del SITIO que configuraste en SETUP --- predeterminado
host="localhost"         # parametro de ruta del host -- predeterminado

# -- # INGRESA DATOS DE LA BASE DE DATOS QUE ALBERGA EL SISTEMA -- validar que el usuario y pass, sea correcto

DB_user="gnip_acceso"                   # usuario de la base de datos (predeterminado en instalador)
DB_pass="Gn1p_p4sS"              # Contraseña de la base de datos (predeterminado en instalador)
DB_base="gnipconsumos_tw"              # Nombre de la base de datos --- predeterminado
DB_tabla="gnip_consumos"           # Nombre de la tabla de DB --- predeterminado

# -- # Configuración de notificaciones

# El tiempo en que capturará los consumos lo modificas con crontab -e
# EL tiempo de envio de notificación debe ser cada 120, 60, 30, 15, 10 o 5 minutos // SIEMPRE MAYOT al tiempo de ejecución del programa
send_mail_notification="N" # Y = yes/si N= no 
notification_time=60 # cada 5 minutos (5,10,15,30,60) ** no usar separaciones ni espacios en blanco -- SE RECOMIENDA QUE EL TIEMPO DE NOTIFICACION SEA MAYOR AL DE EJECUCIÓN.
					 # cada 15 minutos será necesario que el script se ejecute en cron cada 5, 15, 30... min, considerar la prioridad de ejecución será el script antes que la notificación.	 

# Comprobando la hora de GNIP, por zona horaria de españa, en México a las 20 hrs marcará cero
################# CONSTANTES (no editar):

fecha=`date +"%Y-%m-%d"` # obtiene fecha
hora=`date +"%H:%M"`     # obtiene la hora
diasmes=`cal $MONTH $YEAR | awk 'NF {DAYS = $NF}; END {print DAYS}'` # Día del mes
h=`date +"%H"`           # TOMA LA HORA solamente, sin minutos, para evalúar si son las 20 horas y mandar diferencia a cero / notificaciones
m=`date +"%M"`			 # TOMA EL MINUTO solamente, para evaluar notificaciones
m2=$(printf $m | tail -c 1) #Toma EL ULTIMO VALOR del minuto, para evaluar notificaciones
# -- # Tiempo de inicio del script, posterior a CRON
sleep_captura_pag=10  # Se recomienda 10 segundos
sleep_ingreso_db=10 # Se recomienda 10 segundos

######## PASO 1. Descargar página para obtener los datos

sleep $sleep_captura_pag"s"  # DETIENE EL SCRIPT UNOS SEGUNDOS ANTES DEL TIEMPO DESEADO en lo que cambia valor gnip twitter

# CAPTURANDO LA COOKIE DE SESIÓN

curl -X POST -F user[email]=$gnipuser -F user[password]=$gnippass $gnipsite -c $Path_absolute/temp/$gnipcookie

echo "Sesión capturada..."
echo "Ingresando a los consumos con la sesión capturada"
sleep 2s
echo "descargando la página que se mostrará"

# CON ESTE USO LA COOKIE PARA INGRESAR AL SITIO DE CONSUMOS GNIP
# DESCARGO LA PAGINA Y MANDO A SITIO LOCAL PARA SU CONSULTA

curl  $gnipsite_usage -b $Path_absolute/temp/$gnipcookie  > $Path_site/$Nom_site/$GNIP_Page
echo "se ha descargado la página con éxito"


######## PASO 2. SELECCIONAR LOS DATOS E INGRESAR A LA BASE DE DATOS

sleep $sleep_ingreso_db"s" # DETIENE EL SCRIPT UNOS SEGUNDOS ANTES DEL PROCESO DE OBTENCION DE DATOS E INCERSIÓN EN LA DB


## FUNCIONES CON PROCESOS ESPECIFICOS


	function obtener_consumo { # Obtengo los datos de la tabla
		grep -v '<td class="activity number">0</td>' $Path_site/$Nom_site/$GNIP_Page > $Path_absolute/temp/tabla_temp.txt
		# Borro los ceros de la tabla
		grep -v '<td class="number">0</td>' $Path_site/$Nom_site/$GNIP_Page > $Path_absolute/temp/sumatoria_temp.txt
		# Obtengo los parametros de actividad por dia según la plataforma
		grep -F "activity number"  $Path_absolute/temp/tabla_temp.txt > $Path_absolute/temp/activity_temp.txt
		awk -F'[<>]' '{print $3}' $Path_absolute/temp/activity_temp.txt > $Path_absolute/temp/activity_temp2.txt
		sed 's/,//g' $Path_absolute/temp/activity_temp2.txt > $Path_absolute/temp/activity.txt
		# Obtener ultimo resultado del monitoreo
		   #hasta insertar IF
		# Obtener sumatoria
		grep -w 'class="number"'  $Path_absolute/temp/sumatoria_temp.txt > $Path_absolute/temp/sumatoria_temp2.txt
		awk -F'[<>]' '{print $3}' $Path_absolute/temp/sumatoria_temp2.txt > $Path_absolute/temp/sumatoria.txt
	}

	function obtener_fecha_general { # manda a guardar fechas
	grep -F "date center"  $Path_absolute/temp/tabla_temp.txt > $Path_absolute/temp/date_temp.txt
	awk -F'[<>]' '{print $3}' $Path_absolute/temp/date_temp.txt > $Path_absolute/temp/date.txt
	}

	function checar_consumo {
		# funcion de consulta de consumos # solo para test
		# De prueba para conexión con base de datos
		# SE= seleccionar el puro resultado E= selecciona tambien campo
	query="SELECT consumo FROM $DB_tabla WHERE fecha='$fecha'"
	query_consulta=$(mysql -u $DB_user -p$DB_pass -D $DB_base -se "$query")
	#echo "CONSUMO POR FECHA $query_consulta"

	query="SELECT diferencia FROM $DB_tabla WHERE fecha='$fecha'"
	query_consulta=$(mysql -u $DB_user -p$DB_pass -D $DB_base -se "$query")
	#echo "DIFERENCIA POR FECHA $query_consulta"
	}

	function penultimo {
		# SE= seleccionar el puro resultado E= selecciona tambien campo
		#query="SELECT consumo FROM $tabla ORDER BY id DESC  LIMIT 1,1"
	query="SELECT consumo FROM $DB_tabla ORDER BY id DESC  LIMIT 1"
	query_consulta=$(mysql -u $DB_user -p$DB_pass -D $DB_base -se "$query")
	penultimo=$query_consulta

	query="SELECT diferencia FROM $DB_tabla ORDER BY id DESC  LIMIT 1"
	query_consulta2=$(mysql -u $DB_user -p$DB_pass -D $DB_base -se "$query")
	penultima=$query_consulta2

	}

	function inserta_dato { # DIFERENCIA NUMERICA
		# Pasando las 19 horas la diferencia es el total acumulado de diferencia, ya que el contador de la página se reestablece a cero en consumos
		# Las 19 horas, por eso el delay de ejecución 10 segundos antes de cada hora, esto depende de la zona horaria
		# Dependiendo de la zona horaria estableceremos este valor. Para México, a las 20 hrs marcará cero
		
		if ([ $h -eq 19 ] && [ $m -eq 00 ]); then
			echo "DIFERENCIA FINAL DEL DIA"
			echo $h
			ultimo=$(tail -2 $Path_absolute/temp/activity.txt | head -1) # para asignar cuando son las 20 hrs
			diferencia=`expr $ultimo - $penultimo`

		elif ([ $h -eq 19 ] && ([ $m2 -eq 5 ] || [ $m -ge 10 ])); then
			if [ $penultima == 0 ]; then
				echo "DIFERENCIA NORMAL DE LAS 19"
				ultimo=$(tail -1 $Path_absolute/temp/activity.txt | head -1)
				echo "ultimo dn: "$ultimo
				diferencia=`expr $ultimo - $penultimo`
				
			else
				echo "DIFERENCIA A CERO 19 hrs"
				ultimo=$(tail -1 $Path_absolute/temp/activity.txt | head -1)
				echo "ultiummo: "$ultimo
				echo "dif_penutlima: "$penultima
				diferencia=0
			fi

		else
			echo "DIFERENCIA RESTADA"
			ultimo=`awk END{print} $Path_absolute/temp/activity.txt`
			#ultimo=$(tail -1 $Path_absolute/temp/activity.txt | head -1)
			echo "ultiummo: "$ultimo
			diferencia=`expr $ultimo - $penultimo`
		fi
		echo "DIFERENNCIA CONPR: $diferencia"
		if [ $diferencia -lt 0 ]; then  # si la diferencia es negativa, se convertira en cero
			echo "ES MENOR A CERO"
			diferencia=0
		else
			echo "NO ES MENOR A CERO"
			echo "diferencia: $diferencia"
		fi


	echo "Se inserta dato"
	#echo "HORA::: $hora"
	query="INSERT into $DB_tabla (fecha,hora,consumo,diferencia) VALUES ('$fecha','$hora','$ultimo','$diferencia')"
	query_consulta=$(mysql -u $DB_user -p$DB_pass -D $DB_base -se "$query")
	sleep 1s
	
}

	function obtener_css { # El sitio cambia constantemente su CSS, de esta forma obtenemos el nuevo nombre y lo aplicamos

	  mkdir -m777 $Path_site/"assets" #Genera el directorio assets para Css del sitio de twitter consumos SI NO EXISTE 
	  grep -F '<link href="/assets/' $Path_site/$Nom_site/$GNIP_Page > $Path_absolute/temp/stylesheet_name_temp1.txt
	  #awk '{print $2}' ./temp/stylesheet_name_temp1.txt
	  awk -F'["]' '{print $2}' $Path_absolute/temp/stylesheet_name_temp1.txt > $Path_absolute/temp/stylesheet_name_temp2.txt
	  awk -F'[/]' '{print $3}' $Path_absolute/temp/stylesheet_name_temp2.txt > $Path_absolute/temp/stylesheet_name.txt
	  name_css="$(cat $Path_absolute/temp/stylesheet_name.txt)"
	  rm -rf $Path_site"/assets/"* #Borra el anterior CSS para pantalla de Twitter consumos de GNIP 
	  cp $Path_absolute/bin/css_twitter.css $Path_site/"assets/"$name_css  #Copia CSS para pantalla de Twitter Consumos de GNIP
	  
	}

	function enviar_mail {
		echo "Permite envío de notificaciones cada: $notification_time"
		#seg=`expr $notification_time \* 60`
		#echo "se ejecutara dentro de $notification_time minutos"  # descontinuado
		#sleep $seg
		echo $h":"$m
		case $notification_time in
			5 ) # Cada 5 minutos
			echo "Enviar correo cada 5 minutos posterior a la ejecución del programa"
			echo $m2

				if [ $m2 == 5 ] || [ $m2 == 0 ];then
					echo "Se manda correo cada 5 minutos" #> $Path_absolute/temp/manda.txt
					bash $Path_absolute/notificaciones.sh $ssh $host $Nom_site $GNIP_Page $Path_absolute 2>&1
				else
					echo "el minuto/tiempo no es válido"

				fi
			;;
			10 ) # Cada 10 minutos
			echo "Enviar correo cada 10 minutos posterior a la ejecución del programa"
			echo $m2

				if [ $m2 == 0 ];then
					echo "Se manda correo cada 10 minutos"
					bash $Path_absolute/notificaciones.sh $ssh $host $Nom_site $GNIP_Page $Path_absolute 2>&1
				else

					echo "el minuto/tiempo no es válido"

				fi
			;;
			15 ) # Cada 15 minutos
			echo "Enviar correo cada 15 minutos posterior a la ejecución del programa"
			echo $m

				if [ $m == 00 ] || [ $m == 15 ] || [ $m == 30 ] || [ $m == 45 ];then
					echo "Se manda correo cada 15 minutos"
					bash $Path_absolute/notificaciones.sh $ssh $host $Nom_site $GNIP_Page $Path_absolute 2>&1
				else
					echo "el minuto/tiempo no es válido"

				fi
			;;
			30 ) # Cada 30 minutos
			echo "Enviar correo cada 30 minutos posterior a la ejecución del programa"
			echo $m

				if [ $m == 00 ] || [ $m == 30 ];then
					echo "Se manda correo cada 30 minutos"
					bash $Path_absolute/notificaciones.sh $ssh $host $Nom_site $GNIP_Page $Path_absolute 2>&1
				else
					echo "el minuto/tiempo no es válido"

				fi
			;;
			60 ) # Cada 60 minutos
			echo "Enviar correo cada 60 minutos posterior a la ejecución del programa"
			echo $m

				if [ $m == 00 ];then
					echo "Se manda correo cada 60 minutos"
					bash $Path_absolute/notificaciones.sh $ssh $host $Nom_site $GNIP_Page $Path_absolute 2>&1
				else
					echo "el minuto/tiempo no es válido"

				fi
			;;
			* )
			echo "has ingresado un tiempo NO valido o disponible" 
			;;
		esac
	}

############# EJECUCIÓN DE LAS FUNCIONES E INVOCACIÓN DE CREADOR DE SITIO BASE ##################
		obtener_consumo
			obtener_fecha_general
				penultimo
					inserta_dato
						obtener_css
							sleep 5s # suspende un momento el script (5s) para evalúar el envío por correo, si es que se esta usando:
								# DEPENDENCIAS para enviar mail o notificación gnome-web-photo Y sendEmail

									if [ $send_mail_notification == Y ]; then
										enviar_mail

									else 
										echo "No esta configurado para enviar mail"

									fi
			
			# Algunas comprobaciones finales

				echo "Valor de H= "$h
				echo "Valor de M= "$m
				echo "PENULTIMO REGISTRO $penultimo"
				echo "ULTIMO RESULTADO: $ultimo"
				echo "DIFERENCIA: $diferencia"


# MANDA AL BASH QUE GENERA LA PAGINA DE INICIO "index.html" con la gráfica de consumo del mes en curso

bash $Path_absolute/bin/asignados.sh $Path_site $Nom_site $Home_Page $Path_absolute 2>&1
echo "SE HA GENERADO EL SITIO PARA REVISAR EL CONSUMO"

# En caso de requerir envio de notificación por correo, configurar los parámetros al inicio de "notificaciones.sh"

