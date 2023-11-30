<?php
function exception_handler($exception) {
    echo "<h1>Failure</h1>";
    echo "Uncaught exception: " , $exception->getMessage();
    #echo "<h1>PHP Info for troubleshooting</h1>";
    #phpinfo();
}

set_exception_handler('exception_handler');

?>

<h1> Azure SQL / SQL Server Connection : </h1>

<?php
$conn = new PDO("sqlsrv:server=localhost; Database=tempdb; TrustServerCertificate=true", "sa", "A_STR0NG_Passw0rd!");
$conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
$query = "SELECT @@Version AS SQL_VERSION";
$stmt = $conn->query( $query );  

while ($row = $stmt->fetch( PDO::FETCH_ASSOC )) {
    echo $row['SQL_VERSION'] . PHP_EOL;
}  
?>