<!--
<html> 
    <head> <title>Esempio S3</title> </head>
    <body>
        <?php
            require 'vendor/autoload.php';
            use Aws\S3\S3Client;
            use Aws\Exception\AwsException;
            $credentials = new Aws\Credentials\Credentials('chiave', 'segreto');
            $s3 = new Aws\S3\S3Client([
                'version' => 'latest', 'region' => 'eu-south-1', 'credentials' => $credentials ]);
            
            $result = $s3->listBuckets();
            //variante base
            foreach ($result['Buckets'] as $bucket) {
                print("<p>". $bucket['Name']. ": ". $bucket['CreationDate']. "</p>\n");
                $elenco=$s3->ListObjects(array('Bucket' => $bucket['Name'])); // lista oggetti in $bucket['Name']

                if($elenco->get("Contents")) // controllo se ci sono oggetti in $bucket['Name']
                    foreach($elenco->get("Contents") as $object) // ciclo ogni oggetto
                        echo $object['Key'] . "\n";
            }
        ?>
    </body>
</html>
--> 
<html> 
    <head> <title>Esempio S3</title> </head>
    <body>
        <?php
            require 'vendor/autoload.php';
            use Aws\S3\S3Client;
            use Aws\Exception\AwsException;
            $credentials = new Aws\Credentials\Credentials('chiave', 'segreto');
            $s3 = new Aws\S3\S3Client([
                'version' => 'latest', 'region' => 'eu-south-1', 'credentials' => $credentials ]);
            
            $result = $s3->listBuckets();
            //variante iterator
            foreach ($result['Buckets'] as $bucket) {
                print("<p>". $bucket['Name']. ": ". $bucket['CreationDate']. "</p>\n");

                $iterator = $s3->getIterator('ListObjects', array('Bucket' => $bucket['Name'])); // ottengo un iteratore su $bucket['Name']
                foreach ($iterator as $object)
                    echo $object['Key'] . "\n”;
            }
        ?>
    </body>
</html>



