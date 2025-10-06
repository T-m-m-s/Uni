<html>
    <head><title>.: pwlsGallery inserisci :.</title></head>
    <body>
        <?php
            require_once("config.php");
            require_once("funzioni.php");

            if (!isset($_FILES["nomefile"])) 
                die("File non ricevuto\n");

            $tmp_nome = $_FILES["nomefile"]["tmp_name"];
            $tipo = $_FILES["nomefile"]["type"];
            $nome = $_FILES["nomefile"]["name"];

            if (!controllaTipo($tipo)) 
                die("File di tipo sconosciuto\n");

            $immagine=DIR_IMMAGINI."/".$nome;
            if (move_uploaded_file($tmp_nome, $immagine)) { 
                switch($tipo) {
                    case "image/jpeg":
                        $im = @imagecreatefromjpeg($immagine);
                    break;
                    case "image/gif":
                        $im = @imagecreatefromgif($immagine);
                    break;
                    case "image/png":
                        $im = @imagecreatefrompng($immagine);
                    break;
                }

                $x=imagesx($im); 
                $y=imagesy($im);
                $thumbnail=imagecreatetruecolor(THUMB_X,THUMB_Y);
                imagecopyresized( $thumbnail, $im, 0, 0, 0, 0, THUMB_X, THUMB_Y, $x, $y);
                imagepng ($thumbnail, DIR_THUMB."/".$nome.".png"); ///// !!!!
                imagedestroy($im);
                imagedestroy($thumbnail);
                echo "<p>Inserimento effettuato, torna all'<a href=\"index.php\">indice</a></p>\n";
            }
            else
                echo "<p>Non sono riuscito a spostare il file, controlla i permessi </p>\n";
        ?>
    </body>
</html>