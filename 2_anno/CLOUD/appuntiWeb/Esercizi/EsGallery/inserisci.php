<html>
    <head><title>.: pwlsGallery inserisci :.</title></head>
    <body>
        <?php
        require_once("config.php");
        require_once("funzioni.php");
        if($_POST['user']!=$USER || $_POST['password']!=$PASSWORD)
            die("Non puoi!");
        if (!isset($_FILES["nomefile"])) 
            die("File non ricevuto\n");
        $tmp_nome = $_FILES["nomefile"]["tmp_name"];
        $tipo = $_FILES["nomefile"]["type"];
        $nome = $_FILES["nomefile"]["name"];
        if (!controllaTipo($tipo) || !controllaFormato($nome))
            die("File di tipo sconosciuto\n");
        if (move_uploaded_file($tmp_nome, DIR_IMMAGINI . "/" . $nome))
            echo "<p>Inserimento effettuato, torna all'<a href=\"index.php\">indice</a></p>\n";
        else
            echo "<p>Non sono riuscito a spostare il file, controlla i permessi </p>\n";
        ?>
    </body>
</html>

