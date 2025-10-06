<?php
    //preliminari
    require 'vendor/autoload.php';
    use Aws\S3\S3Client;
    use Aws\Exception\AwsException;

    // credenziali
    $credentials = new Aws\Credentials\Credentials(
        'chiave',
        'segreto'
    );

    //Crea un client per S3
    $s3 = new Aws\S3\S3Client([
        'version' => 'latest',
        'region' => 'eu-south-1', //NB se avete usato Milano
        'credentials' => $credentials ]);

    $result = $s3->listBuckets();
    foreach ($result['Buckets'] as $bucket){
        print( "<p>".$bucket['Name'] . ":" . $bucket['CreationDate']."</p>");
        print_r($bucket);
    }
?>