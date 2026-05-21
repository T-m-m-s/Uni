<?php
    include("intestazione.php");
    include("menu.php");
?>
<div id="contenuto">
<form action="autentica.php" method="post">
    Login: <input name="login" type="text"/><br/>
    Password: <input name="password" type="password"/>
    <br/>
    <input type="submit" value="Accedi"/>
</form>
</div>
<?php
    include("piepagina.php");
?>