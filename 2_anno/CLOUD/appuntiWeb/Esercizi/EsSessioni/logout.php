<?php
    // recupera il riferimento alla sessione
    session_start();
    // distrugge la sessione
    session_destroy();
    // redirezione automatica a form.php
    header("Location: form.php");
?>