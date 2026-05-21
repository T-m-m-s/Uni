<?php
    require_once("config.php");
    function caricaDirectory($dir) {
        $dh = opendir($dir) or die("Impossibile aprire la directory $dir");
        $comtenuto = array();
        while (($file  = readdir($dh)) != false)
            if(!is_dir($file) && controllaFormato($file))
                $comtenuto[] = $file;
        closedir($dh);
        return $comtenuto;
    }
    function controllaFormato($nomefile){
        global formati_immagine;
        foreach($formati_immagine as $formato)
            if (strpos($nomefile, $formato))
                return true;
        return false;
    }
    function controllaTipo($tipo) {
        global tipi_immagine;
        foreach($tipi_immagine as $tipo_immagine)
            if (strpos($tipo, $tipo_immagine) === 0)
                return true;
        return false;
    }
    function generaLinkImmagine($indice, $file) {
        return "<a href=\"visualizza.php?immagine=" . $indice ."\">"
        . "<img src=\"" . DIR_IMMAGINI . "/" . $file . "\" "
        . "\" width=\"80\" height = \"60\"/>" . "</a>";
    }
    function generaLinkTestuale($indice, $testo = ""){
        return "<a href=\"visualizza.php?immagine=" . $indice . "\">"
        . $testo . "</a>";
    }
?>