a) lo script riceve in input in modalità GET il parametro cf che identifica un dipendente;
b) se il parametro cf non è presente oppure risulta vuoto, l’esecuzione termina e mostra una
segnalazione di errore;
c) altrimenti lo script stabilisce una connessione con S3 su AWS (per semplicità, il config.php è da
considerarsi già impostato),
d) Per ogni dipendente esiste un bucket il cui nome è dato dalla concatenazione di “stipendi-“ e il
parametro cf. Per semplicità, il bucket risulta accessibile in lettura con le chiavi già presenti nel
config.php.
e) lo script legge il contenuto del bucket, e mostra (in HTML) la lista dei file in esso contenuti, ma del solo
tipo PDF (quindi con estensione .pdf).
f) Ognuno dei file nella lista è “cliccabile”, ed il link permette di scaricare il file stesso.
g) Al termine dell’importazione si deve far comparire un messaggio che dice quanti stipendi sono
presenti in tutto nel repository del dipendente.




<html>
    <head><title>Dipendenti inserisci</title></head>
    <body>
        <?php
        require 'vendor/autoload.php';
        require_once("config.php");
        use Aws\S3\S3Client;
        use Aws\Exception\AwsException;

        if (!isset($_GET['cf']) || empty($_GET['cf'])) 
            die("Errore: Parametro cf non presente\n");

        $cf = $_GET['cf'];
        
        $credentials = new Aws\Credentials\Credentials('chiave', 'segreto');
        $s3 = new Aws\S3\S3Client([
            'version' => 'latest', 
            'region' => 'eu-south-1', 
            'credentials' => $credentials 
        ]);

        $bucketName = "stipendi-" . $cf;
        $objectsList  = $s3->listObjectsV2(['Bucket' => $bucketName]);
        $pdfFiles = [];
        if (isset($objectsList['Contents'])) {
            foreach ($objectsList['Contents'] as $object){
                if(mime_content_type($object) == 'application/pdf'){ //if(substr($object['Key'], -4) === '.pdf')
                    $pdfFiles[] = $object['Key'];
                }
            }
        }

        echo "<h1>Lista dei file PDF per il dipendente con CF: $cf</h1>";
        echo "<ul>";
        foreach ($pdfFiles as $file) {
            $fileUrl = $s3->getObjectUrl($bucketName, $file);
            echo "<li><a href=\"$fileUrl\" download>$file</a></li>";
        }
        echo "</ul>";
        echo "<p>Numero totale di stipendi presenti: " . count($pdfFiles) . "</p>";
        ?>
    </body>
</html>
