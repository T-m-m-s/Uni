import huffman_toolkit.OutputTextFile;

public class RandomText {
    private static final int MaxLength = 1500; // per specificare la lunghezza massima del file

    /** Inserisci il nome del File nel quale creare del testo casuale */
    public static void RandomT(String FileName) {

        OutputTextFile FileRandom = new OutputTextFile(FileName); // apre il file di testo chiamato File e lo associa
                                                                  // alla variabile FileRandom

        int FileLength = (int) (Math.random() * MaxLength + 1); // definisce una lunghezza del file randomica in modo da
                                                                // creare sempre file di testo casuali
                                                                // dove anche la stessa lunghezza sia casuale, un modo
                                                                // più bello per non avere sempre file
                                                                // della stessa dimensione, sfrutta la funzione random
                                                                // di math:

        for (int i = 0; i < FileLength; i++) { // scriviamo caratteri casuali uno alla volta partendo da 0 fino a
                                               // FileLength che sarà la lunghezza casuale del file

            FileRandom.writeChar((char) (128 * Math.random())); // questa invocazione scrive un carattere causale alla
                                                                // volta

        }

        FileRandom.close(); // chiudiamo il file una volta che abbiamo finito di scrivere caratteri
        System.out.println("File creato correttamente");
    }
}
