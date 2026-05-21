<?php
    session_start();
    include("intestazione.php"); 
    include("menu.php");
?>
<div id="contenuto">
<?php
    if (isset($_SESSION["autenticato"]))
    {
        echo "Questo contenuto pu&ograve; essere visualizzato<br/>";
        echo "Il tuo login &egrave;: " . $_SESSION["login"];
    }
    else
    {
        echo "Il contenuto non pu&ograve; essere visualizzato, effettua il <a href=\"form.php\">login</a>";
    }
?>
</div>
<?php
    include("piepagina.php");
?>

