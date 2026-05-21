<?php
    session_start();
    include("intestazione.php");
    include("menu.php");
    function autentica_da_file($l, $p) {
        $file = file("C:/Users/Utente/Desktop/utenti.txt");
        foreach ($file as $riga){
            if ($l . ":" . $p == trim($riga)){
                return TRUE;
            }
        }
        return FALSE;
    }
?>
<div id="contenuto">
    <?php
        $login = $_REQUEST["login"];
        $password = $_REQUEST["password"];
        if (autentica_da_file($login, $password)) {
            $_SESSION["autenticato"] = TRUE;
            $_SESSION["login"] = $login;
            echo "Benvenuto " . $login . "<br/>";
            echo "<a href=\"visualizza_contenuto_protetto.php\"> Prosegui</a>";
        }
        else {
            echo "Accesso non consentito";
        }
    ?>
</div>
<?php
    include("piepagina.php");
?>