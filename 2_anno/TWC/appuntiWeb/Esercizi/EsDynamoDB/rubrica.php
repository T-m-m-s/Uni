<html>
    <head>
        <title>Rubrica DynamoDB</title>
    </head>
    <body>
        <?php
        require 'vendor/autoload.php';
        require 'config.php';
        use Aws\DynamoDb\DynamoDbClient;
        use Aws\Exception\AwsException;

        $credentials = new Aws\Credentials\Credentials('chiave', 'segreto');
        //Crea un client per DynamoDb
        $client = new Aws\DynamoDb\DynamoDbClient(['version' => 'latest', 'region' => 'eu-south-1', 'credentials' => $credentials ]);

        $table="rubrica"; //twc24
        $lista = $client->listTables();
        //print_r($lista);

        foreach ($lista['TableNames'] as $t) {
            echo $t . "\n";
        }

        $homer=array(
            'nome' => array('S'=>'Homer'), // tipo => dato
            'cognome' => array('S'=>'Simpson'),
            'indirizzo' => array('S'=>'742 Evergreen Terrace'),
            'luogo' => array('S'=>'Springfield'),
            'telefono' => array('N'=>'123456789')
            );

        $rs = $client->putItem(array('TableName' => $table, 'Item' => $homer));

        var_dump($rs);



        $marge=array(
            'nome' => array('S'=>'Marge'),
            'cognome' => array('S'=>'Bouvier'),
            'indirizzo' => array('S'=>'742 Evergreen Terrace'),
            'luogo' => array('S'=>'Springfield'),
            'cellulare' => array('N'=>'456789'),
            'email' => array('S'=>'marge@mail.com')
            );


        // Inserisci item nella tabella
        $rs = $client->putItem(array(
            'TableName' => $table, 
            'Item' => $marge)
        );

        // creo iterator per nome == Homer
        $iterator = $client->getIterator('Query', array(
            'TableName' => $table,
            'KeyConditions' => array(
                'nome' => array(
                    'AttributeValueList' => array(array('S' => 'Homer')),
                    'ComparisonOperator' => 'EQ' )
                )
            ));

        // ComparisonOperator: EQ|NE|IN|LE|LT|GE|GT|BETWEEN|NOT_NULL|NULL|CONTAINS| NOT_CONTAINS|BEGINS_WITH', // REQUIRED ],
        
        foreach ($iterator as $item) {
            echo $item['nome']['S'] . "\n";
            echo $item['cognome']['S'] . "\n";
            echo $item['indirizzo']['SS'] . "\n";
        }






        // Creare tabella
        try {
            $client->createTable(array(
                'TableName' => "nuovatabella",
                'AttributeDefinitions' => array(
                    array( 'AttributeName' => 'nome', 'AttributeType' => 'S' ),
                    array( 'AttributeName' => 'cognome', 'AttributeType' => 'S' )
                    ),
                'KeySchema' => array(
                    array( 'AttributeName' => 'nome', 'KeyType' => 'HASH' ),
                    array( 'AttributeName' => 'cognome', 'KeyType' => 'RANGE' )
                    ),
                'ProvisionedThroughput' => array( 'ReadCapacityUnits' => 5, 'WriteCapacityUnits' => 5 )
            ));
            // NB si può modificare a posteriori
        } catch(Aws\DynamoDb\Exception\DynamoDbException $e) {
            echo "Non posso creare la tabella : <br />";
            echo $e->getMessage() . "<br />";
        }





        // Estrarre dati da tabella
        $lista = $client->scan(array('TableName'=>$table));

        foreach($lista['Items'] as $i) 
            print_r($i);


        'ScanFilter' => array(
            'cognome' => array(
                'AttributeValueList' => array(array('S' => 'Simpson')),
                'ComparisonOperator' => 'CONTAINS' ),
            'nome' => array(
                'AttributeValueList' => array(array('S' => 'Bart')),
                'ComparisonOperator' => 'EQ' )
            );
        

        $filtro = array(
            'cognome' => array(
                'AttributeValueList' => array(array('S' => 'Simpson' ) ),
            'ComparisonOperator' => 'CONTAINS' ),
            // 'nome' => array(
            // 'AttributeValueList' => array(
            // array('S' => 'Homer')),
            // 'ComparisonOperator' => 'EQ' )
            );

        $lista = $client->scan(array('TableName'=>$table, 'ScanFilter'=>$filtro));

        foreach($lista['Items'] as $i) 
            print_r($i);
                
        
        ?>
    </body>
</html>
        