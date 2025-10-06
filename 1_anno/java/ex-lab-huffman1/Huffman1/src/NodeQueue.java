//PUNTO II: 

//Definisci una classe NodeQueue che possa sostituire PriorityQueue<Node> in Huffman
//offrendo le stesse funzionalità ma usando solo gli array.
//Per farlo avrai bisogno di: 

//  - public NodeQueue(): costruttore: creazione della coda di nodi vuota
//  - public int size(): restituisce il numero di elementi contenuti nella coda
//  - public Node peek() : restituisce l’elemento con “peso minore” (senza rimuoverlo dalla coda)
//  - public Node poll() : restituisce e rimuove dalla coda l’elemento con “peso minore”
//  - public void add( Node n ) : aggiunge un nuovo elemento n alla coda

//Verifica infine se funziona utilizzandola all'interno di Huffman.

public class NodeQueue {
    
    Node[] Coda; //Coda di nodi su cui lavorare: Array di nodi messi in uno specifico ordine
    int dimensione; //Dimensione della coda: dimensione dell' array contenente i nodi
    
    //Costruttore della coda di nodi vuota
    public NodeQueue() {
        
        dimensione = 0; //dimensione 0 
        Coda = new Node[0]; //array di dimensione 0 
    }
    
    //Metodo che restituisce il numero di elementi presenti dentro la coda
    public int size() {
        return dimensione;
    }
    
    //Metodo che restituisce l'elemento dal peso minore senza andare a rimuoverlo dalla coda
    public Node peek() {
        
        Node PeekNode = null; //Il nodo inizialmente è nullo, poi andremmo a meterci dentro il risultato che ci interessa
        
        if(dimensione > 0) { //se la dimensione della coda è maggiore di 0             
            PeekNode = Coda[dimensione-1]; //il nodo result diventa il penultimo elemento e restituisce un nodo che contiene
            //solo il penultimo elemento, questo perché il nodo con peso minore sta in cima quindi sarà il primo da estrarre dalla pila
        }
        
        return PeekNode;
    }
    
    //Metodo che estrae l'ultimo elemento, lo restituisce e lo elimina dall'array di Nodi 
    public Node poll() {
        
        Node PollNode = null; //nodo risultato, il quale conterrà al suo interno il nodo di peso minore
        
        if(dimensione > 0) {  //se l'array di nodi ha dimensione maggiore di 0 
            
            PollNode = Coda[dimensione-1]; //allora restituiamo l'ultimo elemento dell'array (quello con peso minore) 
            dimensione = dimensione - 1; //e diminuiamo la dimensione dell'array in quanto tale elemento esce
        }
        return PollNode; //restituiamo il nuovo nodo
    }
    
    //Metodo che aggiunge un Nodo alla Coda di Nodi 
    //Imponendo che all'aggiunta di un elemento:
    //  - se questa pesa più degli altri: allora va all'inizio 
    //  - se pesa meno di tutti gli altri: va alla fine 
    //poi fare il peek e poll e facile perché l'elemento di peso minore sarà sempre alla fine 
    //dell'array
    public void add(Node n) {
        
        int Cdim = Coda.length; 
            
        //creo una nuova coda che ha una dimensione in più 
        Node[] NuovaCoda = new Node[Cdim + 1];
            
        //e la riempio con tutti gli elementi che erano presenti dentro la coda 
        for(int i=0; i < Cdim; i++) {
            NuovaCoda[i] = Coda[i];
        }
            
        Coda = NuovaCoda; //questa nuova coda prende il posto della vecchia
                          //avrà quindi tutti gli elementi tranne l'ultimo uguali alla prima
                          //ha quindi uno spazio vuoto alla fine 
        
       //per i che va da 0 alla dimensione della coda  
        for(int i=0; i < dimensione; i++) {
            
            //se il nuovo elemento che stiamo aggiungendo ha un peso maggiore dell'
            //elemento in posizione i con i che cresce fino alla dimensione allora
            //vogliamo andare a metterlo all'inizio della coda così da essere l'ultimo
            //a uscire 
            if(n.compareTo(Coda[i]) == 1) {
                //allora spostiamo tutti gli elementi della coda 
                for(int k=dimensione; k>i; k--) {
                    Coda[k] = Coda[k-1];
                //lasciando così vuoto lo spazio in posizione i
                }
                
                Coda[i] = n; //andiamo quindi a inserire il nuovo elemento in posizione i  
                dimensione = dimensione + 1; //e ad aumentare il contatore della dimensione
                //siccome ora la coda contiene un nuovo elemento 
                //se trovo un elemento di peso maggiore di un altro e lo metto davanti è inutile che continuo
                //con il ciclo quindi devo uscire dal ciclo che non deve continuare a controllare 
                //perché il lavoro l'ho già fatto
                return; //quindi uso un return vuoto per uscire 
            }
        }
        
        //se nulla di cioò accade allora l'elemento ha un peso minore di tutti gli altri elementi
        //presenti nella coda quindi lo possiamo semplicemente inserire nell'ultima posizione 
        Coda[dimensione] = n; //lo inseriamo in ultima posizione della nuova coda
        dimensione = dimensione + 1; //aumentiamo il contatore delle posizioni
        
    }
    
}  // class NodeQueue