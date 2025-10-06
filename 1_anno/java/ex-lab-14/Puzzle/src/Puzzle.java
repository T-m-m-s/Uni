import java.util.Random;

public class Puzzle {

    private final int size; 
    private int[][] board;

    // Costruttore della tavola
    public Puzzle(int s) {
        size = s;
        board = randBoard(); // Rempimento in modo randomico
    }

    // Restituisce la tavola
    public int[][] getBoard() {
        return board;
    }

    // Riempie la matrice con 15 numeri messi in posizione casuale
    public int[][] randBoard() {
        int[] values = new int[] { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 };
        int[][] board = new int[size][size];
        Random rand = new Random(); 
        // Riempimento delle righe
        for (int i = 0; i < size; i++) {
            // Riempimento delle colonne
            for (int j = 0; j < size; j++) {
                // Numero casuale da 1 a 16
                int x = rand.nextInt(16);

                // Controlla se il valore nella posizione x contiene -1 o un altro numero
                if (values[x] != -1) {
                    board[i][j] = values[x]; // Mette tale numero in board[i][j]
                    // Sostituisce la posizione del numero appena scelto con -1 per non avere lo
                    // stesso numero due volte.
                    values[x] = -1; // Aggiorna values in modo che quel numero non venga ripescato
                } else {
                    while (values[x] == -1) {
                        // Genera numeri casuali finché non trova una posizione != da -1
                        x = rand.nextInt(16); 
                    }
                    // Una volta trovata mette il suo valore all'interno di board[i][j]
                    board[i][j] = values[x];
                    values[x] = -1; // E sostituisce tale numero con -1
                }

                // Reitera fino a riempire tutta la matrice, alla fine avremmo tutte le posizioni 
                // piene e una di queste conterrà il valore 0 che è il valore della "casella vuota"
            }
        }

        return board; // Restituisce la matrice randomizzata
    }

    // Verifica se la tavola è ordinata, indica la fine del gioco
    public boolean isSorted() {
        int[] values = new int[] { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 };
        int value = 0;
        // Il gioco termina se lo 0 arriva all'ultima casella
        if (board[size - 1][size - 1] == 0) // Quindi se lo 0 è nell'ultima casella
        {
            // Itero su ogni riga della matrice
            for (int i = 0; i < size; i++) {
                // Itero su ogni colonna della matrice
                for (int j = 0; j < size; j++) {
                    /**
                     * //controllo se
                     * if(i==size-1 && j==size-1){ //se arrivo all'ultima cella e non sono mai
                     * uscito dalla funzione vuol dire che i valori sono ordinati
                     * return true;
                     * 
                     * }
                     * if(board[i][j] != value){
                     * return false;
                     * value = value + 1;
                     * }
                     */

                    if (board[i][j] == values[value]) {
                        value++;
                        if(value == 15) return true;
                    } else {
                        return false;
                    }

                }
            }
        }
        return false;

    }

    // Verifica se il pezzo in posizione <i,j> può muoversi
    private boolean CanMove(int i, int j)
    {
        if (board[i][j] == 0) { // Non si può spostare la casella vuota
            return false;
        } else {
            // PRIMA RIGA
            if (i == 0) {
                if (j == 0) // Prima colonna -> matrix[0][0]
                {
                    if (board[i][j + 1] == 0 || board[i + 1][0] == 0) {
                        return true;
                    } else {
                        return false;
                    }
                }

                if (j == size - 1) // Ultima colonna -> matrix[0][3]
                {
                    if (board[0][j - 1] == 0 || board[1][j] == 0) {
                        return true;
                    } else {
                        return false;
                    }
                }

                if ((j != 0) && (j != size - 1)) // Colonne centrali
                {
                    if (board[i][j + 1] == 0 || board[i + 1][j] == 0 || board[i][j - 1] == 0) {
                        return true;
                    } else {
                        return false;
                    }
                }
            }

            // ULTIMA RIGA
            if (i == size - 1) {
                if (j == 0) // Prima colonna -> matrix[3][0]
                {
                    if (board[i - 1][0] == 0 || board[i][1] == 0) {
                        return true;
                    } else {
                        return false;
                    }
                }

                if (j == size - 1) // Ultima colonna -> matrix[3][3]
                {
                    if (board[i - 1][j] == 0 || board[i][j - 1] == 0) {
                        return true;
                    } else {
                        return false;
                    }
                }

                if ((j != 0) && (j != size - 1)) // Colonne centrali
                {
                    if (board[i][j + 1] == 0 || board[i - 1][j] == 0 || board[i][j - 1] == 0) {
                        return true;
                    } else {
                        return false;
                    }
                }
            }

            // PRIMA COLONNA
            if (j == 0) { // Righe centrali (vertici controllati prima)
                if (board[i - 1][j] == 0 || board[i][j + 1] == 0 || board[i + 1][j] == 0) {
                    return true;
                } else {
                    return false;
                }
            }

            // ULTIMA COLONNA
            if (j == size - 1) { // Righe centrali
                if (board[i - 1][j] == 0 || board[i][j - 1] == 0 || board[i + 1][j] == 0) {
                    return true;
                } else {
                    return false;
                }
            }

            // COLONNE CENTRALI
            if (board[i - 1][j] == 0 || board[i][j - 1] == 0 || board[i + 1][j] == 0 || board[i][j + 1] == 0) {
                return true;
            }

        }
        return false;
    }

    // Restituisce la configurazione della matrice come stringa unica
    public String config() {
        String config = "";
        // attraverso le righe
        for (int i = 0; i < size; i++) {
            // attraverso le colonne
            for (int j = 0; j < size; j++) {
                // se in posizione <i,j> c'è lo 0 allora concateno "[]"
                if (board[i][j] == 0) {
                    config += "[  ] ";
                } else {
                    config += "[ " + board[i][j] + " ] "; // sennò concateno il numero che è presente in quella cella
                }
            }
            config += "\n"; // a fine riga metto il segno dell'a capo in modo da riconoscere dove finisce la
                            // riga
        }
        return config;
    }

    // Controlla dove si trova un determianto valore
    public int[] posCasellaX(int x)
    {
        int[] coordinate = new int[2]; // Array di due posizioni, vettore del tipo [i][j] = coordinate

        // Itera sulle righe
        for (int i = 0; i < size; i++) {
            // Itera sulle colonne
            for (int j = 0; j < size; j++) {
                // Se in <i,j> c'è x allora inserisce i,j nell'array 
                if (board[i][j] == x)
                    coordinate = new int[] { i, j };
            }
        }
        return coordinate; // Restituisce le coordinate
    }

    // Sposta una determianta cella se questa si può spostare
    public void Move(int i, int j) {
        if (CanMove(i, j)) { 
            int[] posZero = posCasellaX(0); // Coordinate dello spazio vuoto
            int x = board[i][j]; // Salava il valore da scambiare di posto
            board[i][j] = 0; // Sposta la casella vuota nella vecchia casella
            board[posZero[0]][posZero[1]] = x; // Sposta la casella vecchia dove c'era la casella vuota

        } else
            System.out.print("Cella selezionata non valida! Riprova" + "\n");
    }
}