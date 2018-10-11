<?php
session_start();
include "./bin/conectar.php";
$_SESSION["fecha"]=$_GET['date'];
$fecha=$_SESSION["fecha"];
$suma_consumo=$suma_diferencia=0;

// ALGUNOS TIPOS DE GRAFICOS: area, bar, bubble, column, doughnut, line, pie, spline, scatter
// stacked area, stacked bar, pyramid, funnel, waterfall, error, etc.. en documentacion de canvas están
$result = $con->query("SELECT * FROM $db_tabla WHERE fecha='$fecha' order BY hora");
$result3 = $con->query("SELECT SUM(diferencia) AS suma_diferencia FROM $db_tabla WHERE fecha='$fecha'");

	while ($y = $result3->fetch_assoc()){
		$suma_diferencia=$y['suma_diferencia'];

	}

?>

<head>
<meta charset="utf-8">
  <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
  <script type="text/javascript" src="./assets/canvasjs.min.js"></script>
  <script type="text/javascript" src="./assets/jquery.canvasjs.min.js"></script>
		<!-- BOOTSTRAP 4 -->
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css" integrity="sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm" crossorigin="anonymous">
  <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/js/bootstrap.min.js" integrity="sha384-JZR6Spejh4U02d8jOt6vLEHfe/JQGiRRSQQxSfFWpi1MquVdAyjUar5+76PVCmYl" crossorigin="anonymous"></script>

<script type="text/javascript">
window.onload = function () {
	var chart = new CanvasJS.Chart("chartContainer",{
		theme: 'light2',
		animationEnabled: true,
		title:{
			text:"Consumos en el intervalo"
	}, 
	data: [
	{
			type: "column",
			dataPoints : [],
		},
		
		]
	});
		
	$.getJSON("consumos_feed.php", function(data) {  
		$.each((data), function(key, value){
			chart.options.data[1].dataPoints.push({label: value[0], y: parseInt(value[2])});

		});
		chart.render();
		updateChart();
	});

	function updateChart() {
		$.getJSON("consumos_feed.php", function(data) {		
			chart.options.data[0].dataPoints = [];
			$.each((data), function(key, value){
				chart.options.data[0].dataPoints.push({label: value[0], y: parseInt(value[1])});
			});
			
			chart.render();
		});
	}
	
	setInterval(function(){updateChart()}, 1000);

// SEGUNDA GRAFICA

	var chart2 = new CanvasJS.Chart("chartContainer2",{
		theme: 'light2',
		animationEnabled: true,
		title:{
			text:"Diferencia en el intervalo"
	}, 
	data: [
	{
			type: "area",
			dataPoints : [],
		},
		
		]
	});
		
	$.getJSON("diferencia_feed.php", function(data) {  
		$.each((data), function(key, value){
			chart2.options.data[1].dataPoints.push({label: value[0], y: parseInt(value[2])});

		});
		chart2.render();
		updateChart2();
	});

	function updateChart2() {
		$.getJSON("diferencia_feed.php", function(data) {		
			chart2.options.data[0].dataPoints = [];
			$.each((data), function(key, value){
				chart2.options.data[0].dataPoints.push({label: value[0], y: parseInt(value[1])});
			});
			
			chart2.render();
		});
	}
	
	setInterval(function(){updateChart2()}, 1000);
}



// ACTUALIZA TABLA

$(document).ready (function() {
	var updater = setInterval (function() {
		$('div#tabla').load (location.href+" #tabla>*","");
	}, 15000);


});


</script>
</head>

  <body>
	<div id="chartContainer" style="height: 370px; max-width: 920px; margin: 0px auto;"></div>
	<div id="chartContainer2" style="height: 370px; max-width: 920px; margin: 0px auto;"></div>
	<div align ="center" id="Regresar">
		<a class="btn btn-dark btn-md" href="./">Regresar</a>
	</div>

	<div align="center"><strong><?php echo $_GET['date']; ?></strong></div>
	<div class="container" id="tabla" ><h5>TABLA DE CONSUMO/DIFERENCIA DIARIO</h5>
		<table class="table table-striped">
		  <thead class="thead-dark text-center">
		    <tr>
			<th scope="col">Fecha</th>
			<th scope="col">Hora</th>
			<th scope="col">Consumo</th>
			<th scope="col">Diferencia</th>
	            </tr>
		  </thead>	

	<?php while ($u = $result->fetch_assoc()){ ?>

	        <tbody>
	            <tr>
			<td align="center"><?php echo $u["fecha"]; ?></td>
			<td align="center"><?php echo $u["hora"]; ?></td>
			<td align="center"><?php echo $u["consumo"]; ?></td>
			<td align="center"><?php echo $u["diferencia"]; ?></td>
	           </tr>
	        </tbody>
	<?php } ?>
		</table>

 
		<table class="table table-striped">
		  <thead class="thead-dark text-center">
		    <tr>
			<th scope="col">Sumatoria de Diferencia del día</th>
	            </tr>
		  </thead>	
	    
                <tbody>
	            <tr>
  			<td align="center"><?php echo $suma_diferencia; ?></td>

	            </tr>
	        </tbody>
	        </table>
	</div>
  </body>
</html>
