<?php
require("config.php");
require("funzioni.php");
?>
<html>
    <head>
        <title><?php echo $NOMENEGOZIO; ?></title>
        <link rel="stylesheet" type="text/css" href="stile.php" />
    </head>
    <body>
        <div id="intestazione">
            <h1><?php echo $NOMENEGOZIO; ?></h1>
            <h2>di <?php echo $AZIENDA; ?></h2>
            <div id="menu">
                <a href="indice.php">Home</a>
                <a href="inserisci.php">Inserisci</a>
                <a href="prodotti.php">Tutti i prodotti</a>
            </div>
        </div>
        <div id="negozio">
            <h1>Magazzino dei prodotti</h1>
            <?php
                $numero = numeroProdotti();
                $pagine = ceil($numero / $NPRODOTTI);
                if (!isset($_GET["pagina"])) {
                    $pagina = 1;
                } else {
                    $pagina = $_GET["pagina"];
                }
                $contenuto = leggi(($pagina - 1) * $NPRODOTTI + 1, $NPRODOTTI);
                if (count($contenuto) > 0) {
                    foreach ($contenuto as $prod) {
                        $img = "<img src='" . $prod[5] . "' height='80' />";
                        echo "<div class=\"prodotto\">\n<h3>", $prod[2],
                            "</h3>\n";
                        echo "<p> $img <em>Descrizione:</em>", $prod[3],
                            "</p>\n";
                        echo "<p><em>Prezzo:</em>", $prod[4], " - ";
                        echo "<p class=\"info\">Inserito il: ", $prod[1],
                            " da ", $AZIENDA, "</p>\n</div>\n";
                    }
                }
            ?>
            <p>Pagine:
            <?php
                for ($i = 1; $i <= $pagine; $i++) {
                    echo "<a href=\"", $_SERVER["PHP_SELF"],
                    "?pagina=", $i, "\">", $i, "</a> ";
                }
            ?>
            </p>
        </div>
        <hr/>
    </body>
</html>
