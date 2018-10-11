#!/bin/bash


############ ASIGNA RESULTADOS
# No es la mejor manera, pero se mejorará en siguientes versiones

a=0 a1=0 a2=0 a3=0 a4=0 a5=0 a6=0 a7=0 a8=0 a9=0 a10=0 a11=0
a12=0 a13=0 a14=0 a15=0

a16=0 a17=0 a18=0 a19=0 a20=0 a21=0 a22=0 a23=0 a24=0 a25=0
a26=0 a27=0 a28=0 a29=0 a30=0

while IFS='' read -r line || [[ -n "$line" ]]; do
#    echo "Valor es: $line"
#     a=$line
     eval "a$c=$line"
     c=$((c+1))
#done < "$1"
done < "$4/temp/activity.txt"

################ ASIGNA FECHAS
# No es la mejor manera, pero se mejorará en siguientes versiones

d=0 d1=0 d2=0 d3=0 d4=0 d5=0 d6=0 d7=0 d8=0 d9=0 d10=0 d11=0
d12=0 d13=0 d14=0 d15=0

d16=0 d17=0 d18=0 d19=0 d20=0 d21=0 d22=0 d23=0 d24=0 d25=0
d26=0 d27=0 d28=0 d29=0 d30=0

while IFS='' read -r line || [[ -n "$line" ]]; do
     eval "d$k=$line"
     k=$((k+1))
done < "$4/temp/date.txt"


###### SUMATORIA

while IFS='' read -r line || [[ -n "$line" ]]; do
	echo "La suma de los consumos es: $line"
        suma=$line
done < "$4/temp/sumatoria.txt"




echo "
<!DOCTYPE HTML>
<html>
<head>
<meta http-equiv='refresh' content='600'>
<script type='text/javascript'>
window.onload = function () {

var chart = new CanvasJS.Chart('chartContainer', {
	theme: 'light1', // puedes cambiar a los siguientes temas: 'light2', 'dark1', 'dark2'
	animationEnabled: true, // puedes cambiar a false (para desactivar animación)		
	title:{
		text: 'Consumos de API Twitter Mensuales: $suma'
	}, 
	data: [
	{
		// Puedes cambiar el tipo de gráfico a 'column', 'bar', 'area', 'spline', 'pie',etc." > $1"/"$2"/"$3

echo "type: 'column',
		dataPoints: [
			{ label: '"$d"',  y: "$a"  },
			{ label: '"$d1"', y: "$a1"  },
			{ label: '"$d2"', y: "$a2"  },
			{ label: '"$d3"',  y: "$a3"  },
			{ label: '"$d4"',  y: "$a4"  },
			{ label: '"$d5"',  y: "$a5"  },
			{ label: '"$d6"',  y: "$a6"  },
			{ label: '"$d7"',  y: "$a7"  },
			{ label: '"$d8"',  y: "$a8"  },
			{ label: '"$d9"',  y: "$a9"  },
			{ label: '"$d10"',  y: "$a10"  },
			{ label: '"$d11"',  y: "$a11"  },
			{ label: '"$d12"',  y: "$a12"  },
			{ label: '"$d13"',  y: "$a13"  },
			{ label: '"$d14"',  y: "$a14"  },
			{ label: '"$d15"',  y: "$a15"  },
			{ label: '"$d16"',  y: "$a16"  },
			{ label: '"$d17"',  y: "$a17"  },
			{ label: '"$d18"',  y: "$a18"  },
			{ label: '"$d19"',  y: "$a19"  },
			{ label: '"$d20"',  y: "$a20"  },
			{ label: '"$d21"',  y: "$a21"  },
			{ label: '"$d22"',  y: "$a22"  },
			{ label: '"$d23"',  y: "$a23"  },
			{ label: '"$d24"',  y: "$a24"  },
			{ label: '"$d25"',  y: "$a25"  },
			{ label: '"$d26"',  y: "$a26"  },
			{ label: '"$d27"',  y: "$a27"  },
			{ label: '"$d28"',  y: "$a28"  },
			{ label: '"$d29"',  y: "$a29"  },
			{ label: '"$d30"',  y: "$a30"  }

		]	
        }
	]
});
chart.render();

}
</script>">> $1"/"$2"/"$3


echo '</head>
<body>
<div id="chartContainer" style="height: 370px; max-width: 920px; margin: 0px auto;"></div>
<script src="https://canvasjs.com/assets/script/canvasjs.min.js"> </script>
<link rel="stylesheet" href="https://formden.com/static/cdn/bootstrap-iso.css" /> 
<link rel="stylesheet" href="https://formden.com/static/cdn/font-awesome/4.4.0/css/font-awesome.min.css" />
<style>.bootstrap-iso .formden_header h2, .bootstrap-iso .formden_header p, .bootstrap-iso form{font-family: Arial, Helvetica, sans-serif; color: black}.bootstrap-iso form button, .bootstrap-iso form button:hover{color: white !important;} .asteriskField{color: red;}</style>

<div class="bootstrap-iso">
 <div class="container-fluid">
  <div class="row">
   <div class="col-md-6 col-sm-6 col-xs-12">
    <form class="form-horizontal" method="get" action="graficos.php">
     <div class="form-group ">
      <label class="control-label col-sm-6 requiredField" for="date">
       Por dia:
       <!--<span class="asteriskField">
        * 
       </span> -->
      </label>
      <div class="col-sm-6">
       <div class="input-group">
        <div class="input-group-addon">
         <i class="fa fa-calendar">
         </i>
        </div>
        <input class="form-control" id="date" name="date" placeholder="AAAA-MM-DD" type="text" required/>
       </div>
      </div>
     </div>
     <div class="form-group">
      <div class="col-sm-6 col-sm-offset-6">
       <button class="btn btn-primary " name="submit" type="submit">
        Enviar
       </button>
      </div>
     </div>
    </form>
   </div>
  </div>
 </div>
</div>
<script type="text/javascript" src="https://code.jquery.com/jquery-1.11.3.min.js"></script>
<script type="text/javascript" src="./assets/datepicker.js"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-datepicker/1.4.1/css/bootstrap-datepicker3.css"/>
'>> $1"/"$2"/"$3
echo '
<script>
	$(document).ready(function(){
		var date_input=$("input[name='date']");
		var container=$(".bootstrap-iso form").length>0 ? $(".bootstrap-iso form").parent() : "body";
		date_input.datepicker({
			format: "yyyy-mm-dd",
			container: container,
			todayHighlight: true,
			autoclose: true,
		})
	})
</script>
</body>
</html>
'>> $1"/"$2"/"$3




