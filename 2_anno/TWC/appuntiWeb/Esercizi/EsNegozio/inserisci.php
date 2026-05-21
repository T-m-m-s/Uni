<?php
    require_once("config.php");
    require_once("funzioni.php");
?>
<html>
    <head>
        <title><?php echo $TITOLO?></title>
        <link rel="stylesheet" type="text/css" href="stile.php"/>
    </head>
    <body>
        <?php if ($_SERVER["REQUEST_METHOD"] == "GET") { ?>
            <h1>Aggiungi un prodotto</h1>
            <form method="post" <?php echo "action=\"", $_SERVER["PHP_SELF"], "\""; ?> >
                Username: <input type="text" name="utente" size="10"/>
                Password: <input type="password" name="password" size="10"/>
                <br/> <hr/>
                Nome prodotto: <input type="text" name="prodotto" size="50"/>
                <br />Descrizione: : <br/>
                <textarea name="descrizione" rows="10" cols="60"></textarea>
                <br/>
                Prezzo: <input type="text" name="prezzo" size="10"/><br/>
                URI immagine: <input type="text" name="immagine"
                size="200"/><br/>
                <input type="submit" value="Inserisci"/>
            </form>
        <?php
        } else {
            if (!utenteValido($_POST["utente"], $_POST["password"])) {
                ?>
                <h2>Errore</h2>
                <p>Non sei autorizzato all’inserimento. Torna al <a href="index.php">negozio</a>.</p>
                <?php
            } else {
                registra($_POST["prodotto"], $_POST["descrizione"], $_POST["prezzo"], $_POST["immagine"]);
                echo "<p>Il prodotto &egrave; stato inserito. Torna al <a href=\"index.php\">negozio</a>.</p>";
            }
        }
        ?>
    </body>
</html>
