<?php
    require_once("config.php");
    require_once("funzioni.php");
?>
<html>
    <head><title>.: pwlsGallery Indice :.</title></head>
    <body>
        <h1>pwlsGallery: indice delle fotografie</h1>
        <?php
            $lista_file = caricaDirectory(DIR_IMMAGINI);
            if (count($lista_file) > 0) {
                echo "<table>\n", "\t<tr>\n",
                "\t\t<td>", generaLinkImmagine(0, $lista_file[0]),
                "</td>\n";
                for ($i = 1; $i < count($lista_file); $i++) {
                    if ($i % $immagini_per_riga == 0)
                    echo "\t</tr>\n\t<tr>\n";
                    echo "\t\t<td>",
                    generaLinkImmagine($i, $lista_file[$i]), "</td>\n";
                }
                echo "\t</tr>\n </table>\n";
            } else
                echo "\t<p>Non &egrave; presente alcuna immagine</p>\n";
        ?>
        <hr/>
        <?php
            include("pie_pagina.php");
        ?>
    </body>
</html>