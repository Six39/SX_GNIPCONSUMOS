<?php

session_start();
$fecha=$_SESSION["fecha"];

include "./bin/conectar.php";

// Revisar conexión
if ($con->connect_error) {
    die("Connection failed: " . $con->connect_error);
} 

$sql = "SELECT * FROM $db_tabla WHERE fecha='$fecha' order BY hora";
$result = $con->query($sql);

if ($result->num_rows > 0) {
    // salida de resultados de cada fila
	$obj = array();
    while($row = $result->fetch_assoc()) {
		$element = array($row["hora"],$row["diferencia"]);
       	array_push($obj,$element);
	}
	echo json_encode($obj);
} else {
    echo "0 results";
}
$con->close();

?>

