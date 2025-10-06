import queens.*;

public class Queens {

    // Rtorna il numero di soluzioni possibili con una scacchiera di dimensione n (quindi di tutte le scacchiere che la compongono)
    public static int numberOfSolution(int n) {
        return numberOfCompletions(new Board(n));
    }

    // Ritorna invece il numero di soluzioni per un'unica scacchiera
    private static int numberOfCompletions(Board b) {
        int n = b.size();
        int q = b.queensOn();

        if (q == n) {
            return 1;
        } else {
            int i = q + 1; // Prima riga vuota dall'alto verso il basso
            int count = 0;

            for (int j = 1; j <= n; j++) {
                if (!b.underAttack(i, j, b.ListaListe)) { // Se la casella non è minacciata inserisco la regina
                    count = count + numberOfCompletions(b.addQueen(i, j)); 
                    // Si crea una nuova situazione, devo vedere in quanti modi posso completarla
                }
            }
            return count;
        }
    }

    public static final SList<Board> NULL_BOARDLIST = new SList<Board>(); // Lista di scacchiere vuota

    // Restituisce una lista di scacchiere che contiene le possibili soluzioni per una scacchiera di dimensione n
    public static SList<Board> listOfAllSolutions(int n) {
        return listOfAllCompletions(new Board(n));
    }

    // Restituisce la lista di completamenti per una determinata scacchiere di n dimensioni
    private static SList<Board> listOfAllCompletions(Board b) {
        int n = b.size();
        int q = b.queensOn();

        if (q == n) {
            return (NULL_BOARDLIST.cons(b));
        } else {
            int i = q + 1;
            SList<Board> solutions = NULL_BOARDLIST;

            // Itera per tutte le colonne e controlla quali sono libere
            for (int j = 1; j <= n; j = j + 1) {
                if (!b.underAttack(i, j, b.ListaListe)) {
                    // Appena trova un posto libero ricorsivamente calcola le soluzioni mettendo la regina in <i,j>
                    solutions = solutions.append(listOfAllCompletions(b.addQueen(i, j)));
                }
            }
            return solutions; // restituisce una lista di soluzioni
        }
    }

    // Strumento di visualizzazione grafica della scacchiera attraverso la GUI
    public static ChessboardView view(SList<Board> bL) { // bL definisce la lista di tutte le possibili soluzioni di una
                                                         // scacchiera di dimensione n
        if (bL.isNull()) { // Se non ci sono soluzioni
            String s = ""; // La configurazione è vuota
            ChessboardView gui = new ChessboardView(3); // Usa un indicatore di dimensione relativo
            gui.setQueens(s); // Imposta il visual della configurazione di '()
            return view(bL);
        }

        int n = bL.car().size(); // Prende la prima combinazione di soluzioni,  la dimensione di tale stringa rappresenta la dimensione della scacchiera

        ChessboardView gui = new ChessboardView(n); // Rappresenta la grafica di una scacchiera nxn (vuota) (da 1 a 15)

        gui.setQueens(bL.car().arrangement()); // Visualizza la configurazione della scacchiera (disposizione di regine)

        return view(bL.cdr()); // Ricorsivamente calcola anche la grafica delle altre soluzioni
    }
}
