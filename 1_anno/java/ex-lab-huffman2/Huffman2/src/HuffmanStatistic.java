public class HuffmanStatistic {
    private static final int CHARS = 128; // Caratteri totali [0,127]
    private static int[] freq = new int[CHARS]; // Frequenze di caratteri

   
    private static int MaxCaratteri = 100000; // Numero massimo di parole di un ipotetico documento

    // Lunghezza media di una parola e di una frase
    private static final double LungMediaParola = 5.1;
    private static final double LungMediaFrase = 24.5;

    // MaxCaratteri di parole e di frasi presenti in un documento
    private static double parole = MaxCaratteri / LungMediaParola;
    private static double frasi = parole / LungMediaFrase;

    // Crea un nodo per le frequenze relative ai caratteri o ai segni di punteggiatura
    public static Node frequenze() {
        freqAltri();
        freqLettere();
        freqMaiuscole();
        freqPunti();
        freqSpazi();
        return Huffman.huffmanTree(freq); // Crea l'albero delle frequenze
    }

    // Ritorna il numero minimo di occorrenze di tutti gli altri caratteri (incluso le cifre ed il capolinea)
    private static void freqAltri() {
        int others = 1;
        for (int i = 0; i < 65; i++) {
            if (i != 34 && i != 39 && i != 44 && i != 46 && i != 58 && i != 59) { // I caratteri esclusi sono punto, apostrofo, ... 
                freq[i] = others; // Queste 33 celle hanno probabilità 1 su 100000
            }
        }

        for (int i = 91; i < 97; i++) { // Parentesi quadre, segni particolari
            freq[i] = others;
        }
        for (int i = 123; i < 128; i++) { // Parentesi graffe ecc...
            freq[i] = others;
        }
    }

    // Ritorna la frequenza percentuale delle lettere dell'alfabeto inglese nel documento
    private static void freqLettere() {
        freq[(int) 'a'] = (int) 8.167 * 1000;
        freq[(int) 'b'] = (int) 1.492 * 1000;
        freq[(int) 'c'] = (int) 2.782 * 1000;
        freq[(int) 'd'] = (int) 4.253 * 1000;
        freq[(int) 'e'] = (int) 12.702 * 1000;
        freq[(int) 'f'] = (int) 2.228 * 1000;
        freq[(int) 'g'] = (int) 2.015 * 1000;
        freq[(int) 'h'] = (int) 6.094 * 1000;
        freq[(int) 'i'] = (int) 6.966 * 1000;
        freq[(int) 'j'] = 153; 
        freq[(int) 'k'] = 772;
        freq[(int) 'l'] = (int) 4.025 * 1000;
        freq[(int) 'm'] = (int) 2.406 * 1000;
        freq[(int) 'n'] = (int) 6.749 * 1000;
        freq[(int) 'o'] = (int) 7.507 * 1000;
        freq[(int) 'p'] = (int) 1.929 * 1000;
        freq[(int) 'q'] = 95;
        freq[(int) 'r'] = (int) 5.987 * 1000;
        freq[(int) 's'] = (int) 6.327 * 1000;
        freq[(int) 't'] = (int) 9.056 * 1000;
        freq[(int) 'u'] = (int) 2.758 * 1000;
        freq[(int) 'v'] = 978;
        freq[(int) 'w'] = (int) 2.361 * 1000;
        freq[(int) 'x'] = 150;
        freq[(int) 'y'] = (int) 1.974 * 1000;
        freq[(int) 'z'] = 74;
    }

    // Si suppone che la distribuzione relativa (%) delle lettere maiuscole sia
    // analoga a quella delle lettere minuscole.
    private static void freqMaiuscole() {
        for (int i = (int) 'A'; i < (int) 'Z'; i++) { // Itera da A a Z
            freq[i] = freq[i + (int) 'a' - (int) 'A'] / 25; // Diviso la lunghezza media, problema di casting
        }
    }

    // Si suppone che ci siano tanti spazi bianchi quante parole
    private static void freqSpazi() {
        double percentuale = parole / MaxCaratteri * 100; // Frequenza delle parole (%)
        freq[32] = (int) percentuale * 1000; // Frequenza spazi bianchi
    }

    // Si suppone che le percentuali dei segni di interpunzione siano fisse, definite dal testo come:
    private static void freqPunti() {
        // Punto fermo
        double percPunto = frasi / MaxCaratteri * 100 * 1000;
        freq[(int) '.'] = (int) percPunto;

        // Virgola: 45% di virgole in ogni frase
        double percCom = percPunto * 45 / 100;
        freq[(int) ','] = (int) percCom;

        // Apostrofo: 40%
        double percApo = percPunto * 40 / 100;
        freq[(int) '\''] = (int) percApo;

        // Due punti: 5%
        double percDueP = percPunto * 5 / 100;
        freq[(int) ':'] = (int) percDueP;

        // Punto e virgola: 5%
        int percPuntoVrg = (int) percDueP;
        freq[(int) ';'] = percPuntoVrg;

        // Virgolette: 5%
        int percVirgolette = (int) percDueP;
        freq[(int) '"'] = percVirgolette;
    }

}
