public class Board {
    // Genero delle istanze di tipo board (scacchiere)
    private static final String ROWS = " 123456789ABCDEF";
    private static final String COLS = " abcdefghijklmno";

    private final int size;
    private final int queens;
    // AGGIUNTA:
    // Invece di tenere 4 liste crea un'unica lista di liste:
    public SList<SList<Integer>> ListaListe; // Lista di liste di coordinate minacciate
    public String config; // Stringa che rappresenta le coordinate della regina sulla scacchiera

    public static final SList<Integer> NULL_INTLIST = new SList<Integer>(); // lista di interi vuota

    // Costruttore di scacchiera VUOTA di dimensione n
    public Board(int n) {
        size = n;
        queens = 0;
        ListaListe = new SList<SList<Integer>>();
        config = "";
    }

    // Costruttore di scacchiera uguale a quella passata aggiundendo una regina in
    // <i,j>
    public Board(Board b, int i, int j) {
        size = b.size;
        queens = b.queens + 1;
        ListaListe = b.ListaListe.cons(NULL_INTLIST.cons(j).cons(i));
        config = b.arrangement();
    }

    public int size() {
        // Restituisce la dimensione della scacchiera
        return size;
    }

    public int queensOn() {
        // Restituisce il numero di regine presenti nella scacchiera
        return queens;
    }

    public Board addQueen(int i, int j) {
        config = config + COLS.charAt(j) + ROWS.charAt(i) + " "; 
        // Ogni volta che aggiungo una regina la aggiungo alla configurazione
        return new Board(this, i, j);
    }

    public String arrangement() {
        // Restiuire la descrizione testuale della scacchiera, quindi devo restituire
        return config;
    }

    // MODIFICA

    public boolean underAttack(int i, int j, SList<SList<Integer>> ListaListe) {
        // Controllo prendendo in ingresso le coordinate della nuova regina <i,j>
        // e controllando la lista di coordinate minacciate.

        if (ListaListe.isNull()) {
            return false; 
        } else if (i == ListaListe.car().listRef(0) || j == ListaListe.car().listRef(1) ||
                i - j == ListaListe.car().listRef(0) - ListaListe.car().listRef(1) || 
                i + j == ListaListe.car().listRef(0) + ListaListe.car().listRef(1)) { 
            return true; // In questi casi la regina appena messa è sotto-minaccia
        } else { 
            // Continua il controllo finché ListaListe non è vuota
            return underAttack(i, j, ListaListe.cdr());
        }

    }

    // Restituisce una stringa di coppia che ci indicano la
    // disposizione delle regine sulla scacchiera
    public String disposizione() {
        return config;
    }
    public String toString() {

        return "( " + disposizione() + " )";
    }
} 
