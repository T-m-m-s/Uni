public class Queens1 {

    public static int numberOfSolutions(int n) {
        return numberOfCompletions(new Board1(n));
    }

    private static int numberOfCompletions(Board1 b) {

        int n = b.size();
        int q = b.queensOn();
        
        // se le regine sono uguali alla dimensione allora ce n'è una in ogni riga
        // quindi il gioco è terminato e restituiamo 1 = 1 unico modo
        if (q == n) { 
            return 1;
        } else {
            // indice della prima riga vuota dall'alto verso il basso (ci sono q regine che
            // occupano le righe, quindi la prima riga vuota è quella successiva all'ultima
            // occupata)
            int i = q + 1;   
            int count = 0;

            for (int j = 1; j <= n; j++) {
                // questo if ora cambia = è da contrallare se b è sotto attacco ma il nuovo
                // underAttacck non contiene più solo i,j ma anche i riferimenti
                // alle liste che indicato le coordinate minacciate (di riga,colonna,diagonali)
                if (!b.underAttack(i, j, b.rows, b.cols, b.diagA, b.diagD)) {
                    // si crea una nuova situazione, devo vedere in quanti modi posso completarla 
                    // essendo una situazione aggiornata rispetto alla precedente
                    count = count + numberOfCompletions(b.addQueen(i, j)); 
                }
            }
            return count;
        }
    }

    // Metodo main per eseguire il codice
    public static void main(String args[]) {
        String frase1 = "\n" + "Il numero di soluzioni per n=" + 1 + " è: "; 
        System.out.print(frase1 + Queens1.numberOfSolutions(1));
        String frase2 = "\n" + "Il numero di soluzioni per n=" + 2 + " è: "; 
        System.out.print(frase2 + Queens1.numberOfSolutions(2));
        String frase3 = "\n" + "Il numero di soluzioni per n=" + 3 + " è: "; 
        System.out.print(frase3 + Queens1.numberOfSolutions(3));
        String frase4 = "\n" + "Il numero di soluzioni per n=" + 4 + " è: "; 
        System.out.print(frase4 + Queens1.numberOfSolutions(4));
        String frase5 = "\n" + "Il numero di soluzioni per n=" + 5 + " è: "; 
        System.out.print(frase5 + Queens1.numberOfSolutions(5));
        String frase6 = "\n" + "Il numero di soluzioni per n=" + 6 + " è: "; 
        System.out.print(frase6 + Queens1.numberOfSolutions(6));
        String frase7 = "\n" + "Il numero di soluzioni per n=" + 7 + " è: "; 
        System.out.print(frase7 + Queens1.numberOfSolutions(7));
        String frase8 = "\n" + "Il numero di soluzioni per n=" + 8 + " è: "; 
        System.out.print(frase8 + Queens1.numberOfSolutions(8));
        String frase9 = "\n" + "Il numero di soluzioni per n=" + 9 + " è: "; 
        System.out.print(frase9 + Queens1.numberOfSolutions(9));
        String frase10 = "\n" + "Il numero di soluzioni per n=" + 10 + " è: "; 
        System.out.print(frase10 + Queens1.numberOfSolutions(10));
    }
}
