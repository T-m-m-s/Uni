<?php
function registra($nome, $descrizione, $prezzo,
$immagine)
{
    global $MAGAZZINO;
    $contenuto = file($MAGAZZINO);
    $penultimo = explode("#", $contenuto[0]);
    $ultimo = $penultimo[0]+1;
    $fp = fopen($MAGAZZINO, "w");
    $nome = rendiConforme($nome);
    $descrizione = rendiConforme($descrizione);
    $prod = $ultimo ."#".date("Y-m-d, G:i") . "#". $nome .
"#" . $descrizione . "#" . $prezzo . "#" . $immagine.
"\n";
    fwrite($fp, $prod);
    if (count($contenuto) > 0)
        foreach ($contenuto as $prod)
            fwrite($fp, $prod);
    fclose($fp); // chiudo il file
}

function rendiConforme($testo)
{
    $testo =
    nl2br(htmlentities(stripslashes($testo)));
    $testo = str_replace(array("\n","\r"), "",
    $testo);
    $testo=str_replace("#","&hash;",$testo);
    return $testo;
}

function leggi($da, $quanti = NULL)
{
    global $MAGAZZINO;
    $risultato = array();
    $contenuto = file($MAGAZZINO); // leggo il contenuto
    if (is_null($quanti))
        $quanti = count($contenuto);
    for ($i = $da; ($i - $da < $quanti) && ($i <=
    count($contenuto)); $i++)
    {
        // estraggo un prodotto dal file e lo aggiungo
        // all'array $risultato
        $prodotto = explode("#", trim($contenuto[$i - 1]));
        $risultato[] = $prodotto;
    }
    return $risultato;
}

function numeroProdotti()
{
    global $MAGAZZINO;
    $prod = file($MAGAZZINO);
    // restituisco il numero di righe del file
    return count($prod);
}

function utenteValido($utente, $password)
{
    global $AZIENDA, $PASSWORD;
    return ($utente == $AZIENDA && $password ==
    $PASSWORD);
}
?>