<?php
    // Imposta l'intestazione del contenuto per JPEG
    header('Content-Type: image/jpeg');
    // Crea un'immagine di esempio
    $width = 200;
    $height = 100;
    $image = imagecreatetruecolor($width, $height);
    // Imposta un colore di sfondo
    $backgroundColor = imagecolorallocate($image, 255, 255, 255); // Bianco
    imagefill($image, 0, 0, $backgroundColor);
    // Invia l'immagine al browser
    imagejpeg($image);
    // Libera la memoria
    imagedestroy($image);
?>








<?php
    require 'funzioni.php';
    class LogService {
        public function log($pagina, $ip, $quando) {
            return salvaLog($pagina, $ip, $quando);
        }
        public function datiAccesso($id) {
            return recuperaLog($id);
        }
    }
    // Creazione del server SOAP
    $options = array('uri' => "http://ws.it/log.wsdl");
    $server = new SoapServer("http://ws.it/log.wsdl", $options);
    $server->setClass("LogService");
    $server->handle();
?>










<?php
require 'vendor/autoload.php';
require 'config.php';
use Aws\DynamoDb\DynamoDbClient;
use Aws\DynamoDb\Exception\DynamoDbException;

function log_accessi() {
    $query_string = $_SERVER['QUERY_STRING'];
    $remote_addr = $_SERVER['REMOTE_ADDR'];
    $request_time = $_SERVER['REQUEST_TIME'];
    $http_user_agent = $_SERVER['HTTP_USER_AGENT'];

    $chiave = $remote_addr . '_' . rand();
    $dynamodb = new DynamoDbClient([
        'version' => 'latest',
        'region' => 'us-west-2',
        'credentials' => [
            'key' => AWS_ACCESS_KEY_ID, // Definito in config.php
            'secret' => AWS_SECRET_ACCESS_KEY, // Definito in config.php
        ]
    ]);
    // Dati da inserire nella tabella
    $item = [
        'chiave' => ['S' => $chiave],
        'query_string' => ['S' => $query_string],
        'remote_addr' => ['S' => $remote_addr],
        'request_time' => ['N' => (string)$request_time],
        'http_user_agent' => ['S' => $http_user_agent],
    ];
    try {
        $result = $dynamodb->putItem([
            'TableName' => 'ACCESSI',
            'Item' => $item
        ]);
        return $chiave;
    } catch (DynamoDbException $e) {
        echo "Errore DynamoDB: " . $e->getMessage();
        return null;
    }
}?>




























<html>
    <head><title>.: Cassaforte inserisci :.</title></head>
    <body>
        <?php
        require 'vendor/autoload.php';
        require_once("config.php");
        use Aws\S3\S3Client;
        use Aws\Exception\AwsException;
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            if (!isset($_FILES["nomefile"]) || filesize($filename) === 0) 
                die("File non ricevuto\n");

            $credentials = new Aws\Credentials\Credentials('chiave', 'segreto');
            $s3 = new Aws\S3\S3Client([
                'version' => 'latest', 
                'region' => 'eu-south-1', 
                'credentials' => $credentials 
            ]);

            $file = $_FILES['file'];
            $originalFileName = $file['name'];
            $bucket = 'CAVEAU';
            $codice = $_POST['CODICE'];
            $time = time();
            $newName = $codice . "_" . $time;

            try {
                $result = $s3->putObject(array(
                    'Bucket' => $bucket,
                    'Key' => $newName,
                    'SourceFile' => $file['tmp_name']//get original path
                    )
                );
                echo "Il file originale '$originalFileName' è stato caricato come '$newName'.";
            } catch (AwsException $e) {
                die("Errore caricamento file AWS: " . $e->getMessage());
            }
        }
        ?>
    </body>
</html>



