<?php
// Creazione bucket 
// Upload di file

    require 'vendor/autoload.php';
    use Aws\S3\S3Client;
    use Aws\Exception\AwsException;

    $credentials = new Aws\Credentials\Credentials('chiave', 'segreto');
    $s3 = new Aws\S3\S3Client([
        'version' => 'latest', 'region' => 'eu-south-1', 'credentials' => $credentials ]);

    //dati da passare
    $bucket='nomedelbucket';
    $file="prova.jpg"; // un file disponibile localmente

    //creo il bucket
    if(!$s3->doesBucketExist($bucket)) { // se non esiste già un bucket lo creo
        print($res=$s3->createBucket(array('Bucket' => $bucket, 'LocationConstraint' => 'eu-south-1')));
        $s3->waitUntil('BucketExists',array('Bucket' => $bucket));
    }
    //NB se esiste ma non è mio, poi comunque non posso usarlo

    //upload del file
    $result = $s3->putObject(array(
        'Bucket' => $bucket,
        'Key' => $file, // basename($file)
        'SourceFile' => $file,
        'Metadata' => array(
        'Content-Type' => 'image/jpeg',
        )
    ));
    print_r($result);
?>