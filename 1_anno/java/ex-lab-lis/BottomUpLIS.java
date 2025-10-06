import java.util.Arrays;

public class BottomUpLIS {
    public static int llisDP(int[] s) { // Calcola la lunghezza della LIS
        int n = s.length; // Lunghezza della sequenza vista come array
        int[][] mem = new int[n + 1][n + 1];
        // Matrice: valori delle ricorsioni di llisRec relativi a diversi valori degli argomenti
        // Dimensioni n+1 per evitare il problema dello 0 nella conta delle posizioni 

        // Riempiamo la matrice di 0 per inizializzarla
        for (int j = 0; j <= n; j = j + 1) {
            mem[n][j] = 0;
        }

        // Iterazione sulle colonne dall'ultima alla prima
        for (int i = n - 1; i >= 0; i = i - 1) {
            // Iterazione sulle righe dalla prima all'ultima
            for (int j = 0; j <= n; j = j + 1) {

                // t = s[j] se 0 ≤ j < n, oppure t = 0 se j = n
                int t = (j == n) ? 0 : s[j];

                if (s[i] < t) {
                    mem[i][j] = mem[i + 1][j];
                    // Avanziamo con l'indice e calcoliamo per la sottosequenza successiva
                } else {
                    mem[i][j] = Math.max(1 + mem[i + 1][i], mem[i + 1][j]);
                    // Facciamo il calcolo di entrambi i casi e scegliamo il più lungo
                }
            }
        }
        return mem[0][n]; // Ritorna l'ultimo valore in basso come nel disegno
    }

    // Restituisce la LIS
    public static int[] lisDP(int[] s) { 
        int n = s.length;
        int[][] mem = new int[n + 1][n + 1];

        // 1. Matrice: valori delle ricorsioni di llisRec calcolati esattamente come per llisDP

        // ------------------------------------------------
        // Replica qui il codice del corpo di llisDP
        // che registra nella matrice i valori
        // corrispondenti alle ricorsioni di llisRec
        // ------------------------------------------------

        // Riempiamo la matrice di 0 per inizializzarla
        for (int j = 0; j <= n; j = j + 1) {
            mem[n][j] = 0;
        }

        // Iterazione sulle colonne dall'ultima alla prima
        for (int i = n - 1; i >= 0; i = i - 1) {
            // Iterazione sulle righe dalla prima all'ultima
            for (int j = 0; j <= n; j = j + 1) {
                
                // t = s[j] se 0 ≤ j < n, oppure t = 0 se j = n
                int t = (j == n) ? 0 : s[j];

                if (s[i] < t) {
                    mem[i][j] = mem[i + 1][j]; // mem assume il valore che si trova nella posizione i+1 e j
                } else {
                    mem[i][j] = Math.max(1 + mem[i + 1][i], mem[i + 1][j]);
                    // Facciamo il calcolo di entrambi i casi e scegliamo il più lungo
                }
            }
        }

        // 2. Cammino attraverso la matrice per ricostruire un esempio di LIS

        // ----------------------------------------------------
        // Inserisci di seguito l'elemento della matrice
        // il cui valore corrisponde a llis(s) (cio� il risultato dell'elaborazione di
        // llis) :
        // ----------------------------------------------------
        
        int m = mem[0][n]; // Ritorna l'ultimo valore in basso come nel disegno
        
        int[] r = new int[m]; // Possibile LIS

        // ----------------------------------------------------
        // Introduci e inizializza qui gli indici utili
        // per seguire un cammino attraverso la matrice e
        // per assegnare gli elementi della sottosequenza r
        // ----------------------------------------------------

        int i = 0; // Indice di lunghezza della sotto-sequenza, parte da 0
        int j = n; // Indice che usiamo al posto di t, inizialmente è n perché percorriamo le righe
                   // al contrario
        int count = 0; // Contatore lunghezza della LIS

        while (mem[i][j] > 0) { // quando mem[i][j] = 0 sto confrontado una sottosequenza di lunghezza 1

            // t = s[j] se 0 ≤ j < n, oppure t = 0 se j = n
            int t = (j == n) ? 0 : s[j]; 

            // --------------------------------------------------
            // Inserisci qui strutture di controllo e comandi
            // per scegliere e seguire un percorso appropriato
            // attraverso la matrice in modo da ricostruire in
            // r una possibile LIS relativa alla sequenza s
            // --------------------------------------------------

            // Gli elementi della sottosequenza devono essere strettamente maggiori del
            // valore di un parametro aggiuntivo t che funge da soglia
            // Se l'elemento x nella posizione iniziale i (s[i]) non soddisfa il
            // vincolo x > t, allora non può far parte della sottosequenza
            
            if (s[i] > t) {
                if (mem[i + 1][j] >= mem[i + 1][i] + 1) {
                    // Se il valore a destra è maggiore allora prendo il valore che si trova 
                    // a destra ovvero mi muovo con i = i + 1;
                    i = i + 1;
                } else {
                    // Se invece il valore a destra è minore allora s[i] è maggiore della soglia,
                    // quindi può far parte della LIS
                    r[count] = s[i]; 
                    // ci si muove come in 1+llisRec(s,i+1,i,mem) ricordando che llisRec(s,i,j,mem)
                    j = i; // quindi j diventa i
                    i = i + 1; // ci si sposta avanti nella sequenza s
                    count = count + 1;
                }
            } else {
                i = i + 1;
            }
        }
        return r; // Ritorna LIS relativa alla sequenza s
    }

    // Metodo main per eseguire il codice
    public static void main(String[] args) {
        int[] s = { 9, 46, 54, 71, 60, 47, 1, 32, 25, 61 };
        System.out.print("La lunghezza della sottosequenza crescente più lunga (LLIS)= " + BottomUpLIS.llisDP(s));
        String frase = "\n" + "La sottosequenza crescente più lunga (LIS) è: ";
        System.out.print(frase + Arrays.toString(BottomUpLIS.lisDP(s)) + "\n");
    }
} 
