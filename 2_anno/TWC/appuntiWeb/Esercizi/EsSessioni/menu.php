<div id="menu">
    <ul>
    <li><a
    href="visualizza_contenuto_protetto.php">Visualizza Contenuto</a></li>
    <?php if (isset($_SESSION["autenticato"])) {?>
        <li>
            <a href="logout.php">Effettua il Logout</a>
        </li>
    <?php } ?>
    </ul>
</div>