
public class LIS {
//---- PROGRAMMA BASE -----------------------------------------------------------------------------------------------------------------------
    public static int llisRic(int[] s) {
        return llisRecRic(s, 0, 0);
    }

    private static int llisRecRic(int[] s, int i, int t) {
        if (i == s.length) { // i = n : coda vuota
            return 0;
        } else if (s[i] <= t) { // x = s[i] ≤ t : x non può essere scelto
            return llisRecRic(s, i + 1, t);
        } else { // x>t: x può essere scelto o meno
            return Math.max(1 + llisRecRic(s, i + 1, s[i]), llisRecRic(s, i + 1, t));
        }

    }

//---- SEMPLICE ---------------------------------------------------------------------------------------------------------------------------

    // Posto di memoria non occupato
    private final static int UNKNOWN = -1;

    public static int llis(int[] s) {
        int n = s.length; // lunghezza della sequenza s
        int[] mem = new int[n + 1]; // mem: struttura di memoria che serve per salvare i risultati, una sola dimensione,
                                    // quindi un array di lunghezza n+1 per evitare il problema dello 0 nella conta
                                    // delle posizioni 
        for (int i = 0; i < n; i++) {
            mem[i] = UNKNOWN; // Riempimento di valori sconosciuti
        }
        return llisRec(s, 0, 0, mem);
    }

    private static int llisRec(int[] s, int i, int t, int[] mem) {
        // Se non conosciamo il valore di soglia t:
        if (mem[t] == UNKNOWN) {
            if (i == s.length) { // i = n : la coda di s è vuota
                mem[t] = 0; // quindi la lunghezza sarà 0
            } else if (s[i] <= t) { // x = s[i] ≤ t : x non può essere scelto
                mem[t] = llisRec(s, i + 1, t, mem); // Non scegliamo x e calcoliamo spostando l'indice
            } else { // x > t : x può essere scelto o meno
                mem[t] = Math.max(1 + llisRec(s, i + 1, s[i], mem), llisRec(s, i + 1, t, mem)); 
                // Facciamo il calcolo di entrambi i casi e scegliamo il più lungo
            }
        }
        return mem[t]; // Restituiamo il valore trovato
    }

//---- GENERALE -----------------------------------------------------------------------------------------------------------------------------

    public static int llisGen(int[] s) {
        int n = s.length;
        int[] mem = new int[n + 1];
        for (int i = 0; i < mem.length; i++) {
            mem[i] = UNKNOWN; // Riempimento di valori sconosciuti
        }
        return llisRecGen(s, 0, n, mem);
    }

    private static int llisRecGen(int[] s, int i, int j, int[] mem) {
        int n = s.length;
        int t; // Valore di soglia al quale dobbiamo risalire

        // t = s[j] se 0 ≤ j < n, oppure t = 0 se j = n
        if (j == n) { t = 0; } else { t = s[j]; }

        // Se non conosciamo il valore di soglia t:
        if (mem[j] == UNKNOWN) {
            if (i == s.length) { // i = n : coda di s vuota
                mem[j] = 0; // allora llis è 0
            } else if (s[i] <= t) { // x = s[i] ≤ t : x non può essere scelto
                mem[j] = llisRecGen(s, i + 1, j, mem); 
                // Avanziamo con l'indice e calcoliamo per la sottosequenza successiva
            } else { // x > t : x può essere scelto o meno
                mem[j] = Math.max(1 + llisRecGen(s, i + 1, i, mem), llisRecGen(s, i + 1, j, mem));
                // Facciamo il calcolo di entrambi i casi e scegliamo il più lungo
            }
        }
        return mem[j]; // Restituiamo il valore trovato
    }

    // Metodo main per eseguire il codice
    public static void main(String[] args) {
        int[] n =  {10, 11, 12, 6, 7, 8, 9, 1, 2, 3, 4, 5};
        System.out.print("\n" + "LLIS con ricorsione semplice:" + LIS.llisRic(n) + "\n");
        System.out.print("LLIS con top-down casi semplificati:" + LIS.llis(n) + "\n");
        System.out.print("LLIS con top-down casi generali:" + LIS.llisGen(n) + "\n");
    }
}
