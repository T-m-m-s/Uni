public class Board1 {
    private final int size;
    private final int queens;

    // Aggiunguamo 4 liste di indici di tipo SList<Integer> (rappresentano le
    // codifiche numeriche
    // delle righe, colonne, diagonali, minacciate da una regina collocata sulla
    // scacchiera)
    public SList<Integer> rows;
    public SList<Integer> cols;
    public SList<Integer> diagA;
    public SList<Integer> diagD;

    // Variabile che restituisce la configurazione della scacchiera
    private final String config;

    // Costruttore di Scacchiera vuota:
    public Board1(int n) { // Passaggio come parametro: dimensione scacchiera
        size = n;
        queens = 0;
        rows = new SList<Integer>();
        cols = new SList<Integer>();
        diagA = new SList<Integer>();
        diagD = new SList<Integer>();
        // Configurazione vuota in quanto nessuna regina collocata
        config = "";
    }

    // Costruttore di scacchiera NON vuota:
    public Board1(Board1 b, int i, int j) { // Passaggio come parametri: Scacchiera, coordinate per
                                            // posizionare nuova regina
        size = b.size; // dimensione = dimensione scacchiera b
        queens = b.queens + 1; // regine = regine precedenti + 1
        rows = b.rows.cons(i); // rows = aggiunta di i alla lista di righe
        cols = b.cols.cons(j); // cols = aggiunta di j alla lista di colonne
        diagA = b.diagA.cons(i - j); // diagA = aggiunta di i-j alla lista di diagonali ascendenti
        diagD = b.diagD.cons(i + j); // diagB = aggiunta di i+j alla lista di diagonali discendenti
        config = b.disposition(); // config = disposition()
    }

    // Indica la dimensione della scacchiera
    public int size() {
        return size;
    }

    // Indica il numero di regine presenti sulla scascchiera
    public int queensOn() {
        return queens;
    }

    // Restituisce una nuova scacchiera aggiungendo una regina in posizione <i,j>
    public Board1 addQueen(int i, int j) {
        return new Board1(this, i, j); // Aggiunge la regina a se stessa
    }

    // Codifica testuale della configurazione
    public String disposition() { // Restiuire la descrizione testuale della scacchiera
        return config;
    }

    // Controlla se la posizione <i,j> è minacciata
    public boolean underAttack(int i, int j, SList<Integer> rows, SList<Integer> cols, SList<Integer> diagA, SList<Integer> diagD) {
        if (rows.isNull()) {
            return false;
        } else if (i == rows.car() || j == cols.car() || i - j == diagA.car() || i + j == diagD.car()) { 
            // Contralla se le coordinate della nuova regina appartengono alla lista che
            // definisce le posizioni minacciate
            return true;
        } else {
            return underAttack(i, j, rows.cdr(), cols.cdr(), diagA.cdr(), diagD.cdr());
        }

    }

}
