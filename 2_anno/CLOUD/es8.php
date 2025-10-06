<?php
    $saluto = "benvenuto";
    if(isset($_COOKIE["precedente"]))
        $saluto = "bentornato";
    setcookie("precedente", time(), time() + 120);
?>

<html>
    <head>
        <title>Esercizio 8</title>
    </head>
    <body>
        <?php
            echo "Data attuale:".date("d/m/Y H:i:s", time());
            if ($saluto=="Bentornato!") {
                echo "<br>Visita precedente: " .
                date( "d/m/Y H:i:s", $_COOKIE['precedente']);
            }
        ?>
    </body>
</html>