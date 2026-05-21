<?php
require_once("config.php");
require 'vendor/autoload.php';
use Aws\DynamoDb\DynamoDbClient;
use Aws\Exception\AwsException;

$config = [
    'region'   => 'eu-south-1',
    'version'  => 'latest',
    'credentials' => [
        'key'    => 'your-access-key-id',
        'secret' => 'your-secret-access-key',
    ],
];
$dynamodb = new DynamoDbClient($config);
if (!isset($_GET['matricola']) || empty(trim($_GET['matricola']))) {
    die(json_encode([
        "matricola" => "-",
        "nome" => "-",
        "cognome" => "-",
        "data_nascita" => "-",
        "corso" => "-"
    ]));
}
$matricola = trim($_GET['matricola']);
try {
    $result = $dynamodb->getItem([
        'TableName' => 'studenti',
        'Key' => [
            'matricola' => ['S' => $matricola]
        ]
    ]);

    if (isset($result['Item'])) { //Converti dati in array associativo
        $item = $result['Item'];
        $data = [
            "matricola" => $item['matricola']['S'],
            "nome" => $item['nome']['S'],
            "cognome" => $item['cognome']['S'],
            "data_nascita" => $item['data_nascita']['S'],
            "corso" => $item['corso']['S']
        ];
    } else { //Nessun record trovato per la matricola
        $data = [
            "matricola" => "-",
            "nome" => "-",
            "cognome" => "-",
            "data_nascita" => "-",
            "corso" => "-"
        ];
    }
    header('Content-Type: application/json');//Emissione risultato JSON
    echo json_encode($data);
} catch (AwsException $e) {
    die(json_encode([
        "matricola" => "-",
        "nome" => "-",
        "cognome" => "-",
        "data_nascita" => "-",
        "corso" => "-"
    ]));
}
?>

















// Form 
<!DOCTYPE html>
<html>
<head>
    <title>Upload File</title>
</head>
<body>
    <h1>Carica il file dei libri</h1>
    <form action="process.php" method="post" enctype="multipart/form-data">
        Seleziona il file di testo:
        <input type="file" name="bookfile" accept=".txt">
        <input type="submit" value="Upload">
    </form>
</body>
</html>

<?php
require 'vendor/autoload.php';
require 'config.php';
use Aws\DynamoDb\DynamoDbClient;
use Aws\Exception\AwsException;

function validateFile($lines) {
    foreach ($lines as $line) {
        $columns = explode('#', $line);
        if (count($columns) != 6) {
            return false;
        }
    }
    return true;
}

function renderTable($lines) {
    echo '<h1>Elenco Libri</h1>';
    echo '<table border="1">';
    echo '<tr><th>ISBN</th><th>Titolo</th><th>Autore</th><th>Data di Pubblicazione</th><th>Editore</th><th>Numero di Pagine</th></tr>';
    foreach ($lines as $line) {
        $columns = explode('#', $line);
        echo '<tr>';
        foreach ($columns as $column) {
            echo '<td>' . htmlspecialchars($column) . '</td>';
        }
        echo '</tr>';
    }
    echo '</table>';
    echo '<form action="import.php" method="post">';
    echo '<input type="hidden" name="lines" value="' . htmlspecialchars(implode("\n", $lines)) . '">';
    echo '<input type="submit" name="action" value="Importazione">';
    echo '<input type="submit" name="action" value="Annulla">';
    echo '</form>';
}

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    if (isset($_FILES['bookfile']) && $_FILES['bookfile']['error'] == 0) {
        $fileTmpName = $_FILES['bookfile']['tmp_name'];
        $fileContent = file_get_contents($fileTmpName);
        $lines = explode("\n", $fileContent);
        $lines = array_filter($lines, 'trim'); // Rimuove le righe vuote

        if (!validateFile($lines)) {
            die("File non conforme");
        } else {
            renderTable($lines);
        }
    } else {
        die("Errore durante il caricamento del file.");
    }
}
?>
//DynamoDB 
<?php
require 'vendor/autoload.php';
require 'config.php';
use Aws\DynamoDb\DynamoDbClient;
use Aws\Exception\AwsException;

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    if ($_POST['action'] == 'Annulla') {
        echo "Importazione annullata.";
        exit;
    }
    $lines = explode("\n", $_POST['lines']);
    $lines = array_filter($lines, 'trim');
    // Configurazione del client DynamoDB
    $sdk = new Aws\Sdk([
        'region'   => AWS_REGION,
        'version'  => 'latest',
        'credentials' => [
            'key'    => AWS_ACCESS_KEY_ID,
            'secret' => AWS_SECRET_ACCESS_KEY,
        ]
    ]);
    $dynamoDbClient = $sdk->createDynamoDb();
    // Importazione dei dati
    $tableName = 'libreria';
    foreach ($lines as $line) {
        $columns = explode('#', $line);
        try {
            $dynamoDbClient->putItem([
                'TableName' => $tableName,
                'Item' => [
                    'ISBN' => ['S' => $columns[0]],
                    'Titolo' => ['S' => $columns[1]],
                    'Autore' => ['S' => $columns[2]],
                    'DataPubblicazione' => ['S' => $columns[3]],
                    'Editore' => ['S' => $columns[4]],
                    'NumeroPagine' => ['N' => $columns[5]],
                ]
            ]);
        } catch (AwsException $e) {
            echo "Errore durante l'importazione dei dati: " . $e->getMessage();
            exit;
        }
    }
    // Conta il numero di item nella tabella
    try {
        $result = $dynamoDbClient->scan(['TableName' => $tableName]);
        $itemCount = count($result['Items']);
        echo "Importazione completata. Numero totale di item presenti nella tabella: $itemCount";
    } catch (AwsException $e) {
        echo "Errore durante il conteggio degli item: " . $e->getMessage();
    }
}
?>

















<?php
// Imposta il cookie
setcookie("virus", "pericoloso", time() + (17 * 60), "/");
// Verifica se il cookie è stato impostato
if(isset($_COOKIE["virus"])) {
    echo "Cookie impostato: " . $_COOKIE["virus"];
} else {
    echo "Cookie non impostato.";
}
?>




<?php
// Nome del cookie
$cookie_name = "virus";

// Valore del cookie
$cookie_value = "pericoloso";

// Durata del cookie in secondi (17 minuti)
$cookie_duration = time() + (17 * 60);

// Imposta il cookie
setcookie($cookie_name, $cookie_value, $cookie_duration, "/");

// Verifica se il cookie è stato impostato
if(isset($_COOKIE[$cookie_name])) {
    echo "Il cookie '$cookie_name' è stato impostato con valore: " . $_COOKIE[$cookie_name];
} else {
    echo "Il cookie '$cookie_name' non è stato impostato.";
}
?>










<?php
require 'vendor/autoload.php';
include('config.php');
use Aws\S3\S3Client;
use Aws\Exception\AwsException;

if (!isset($_FILES['file']) || filesize($filename) == 0) {
    die("Errore: file non presente o vuoto.");
}
if (!isset($_POST['CODICE'])) {
    die("Errore: codice utente non presente.");
}
$codiceUtente = $_POST['CODICE'];
$file = $_FILES['file'];
$originalFileName = $file['name'];
$tempFilePath = $file['tmp_name'];

$bucket = 'VAULT';
$newFileName = $codiceUtente . '-' . $originalFileName; // Nome file da caricare
try {
    $credentials = new Aws\Credentials\Credentials('chiave', 'segreto');
    $s3 = new Aws\S3\S3Client([ // Crea client S3
        'version' => 'latest', 
        'region' => 'eu-south-1', 
        'credentials' => $credentials 
    ]);
    $result = $s3->putObject([   // Carica il file nel bucket
        'Bucket' => $bucket,
        'Key'    => $newFileName,
        'SourceFile' => $tempFilePath,
        'ACL'    => 'public-read', // Opzionale: rendi il file pubblico
    ]);
    $fileUrl = $result['ObjectURL']; // URL del file caricato
    echo "Il file originale è: $originalFileName<br>";
    echo "Il file è stato caricato come: <a href=\"$fileUrl\">$newFileName</a>";
} catch (AwsException $e) {
    echo "Errore durante il caricamento del file: " . $e->getMessage();
}
?>









<?php
require 'vendor/autoload.php';
include('config.php');
use Aws\S3\S3Client;
use Aws\Exception\AwsException;

if (!isset($_FILES['file']) || filesize($filename) == 0) {
    die("Errore: file non presente o vuoto.");
}
if (!isset($_POST['CODICE'])) {
    die("Errore: codice utente non presente.");
}
$codiceUtente = $_POST['CODICE'];
$file = $_FILES['file'];
$originalFileName = $file['name'];
$tempFilePath = $file['tmp_name'];

// Nome del file da caricare su S3
$newFileName = $codiceUtente . '-' . $originalFileName;
try {
    $credentials = new Aws\Credentials\Credentials('chiave', 'segreto');
    $s3 = new Aws\S3\S3Client([ // Crea client S3
        'version' => 'latest', 
        'region' => 'eu-south-1', 
        'credentials' => $credentials 
    ]);
    $result = $s3Client->putObject([   // Carica il file nel bucket S3
        'Bucket' => $config['s3']['bucket'],
        'Key'    => $newFileName,
        'SourceFile' => $tempFilePath,
        'ACL'    => 'public-read', // Opzionale: rendi il file pubblico
    ]);
    // URL del file caricato
    $fileUrl = $result['ObjectURL'];
    echo "Il file originale è: $originalFileName<br>";
    echo "Il file è stato caricato come: <a href=\"$fileUrl\">$newFileName</a>";
} catch (AwsException $e) {
    echo "Errore durante il caricamento del file: " . $e->getMessage();
}
?>


<?php
session_start();
if (!isset($_SESSION['SUPERUSER'])) {
    die('Errore: La variabile di sessione SUPERUSER non esiste.');
} elseif ($_SESSION['SUPERUSER'] <= 3) {
    header("Location: utentenormale.php");
    exit();
} else {
    echo "Accesso consentito.";
}
?>

