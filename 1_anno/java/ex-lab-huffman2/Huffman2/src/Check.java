import huffman_toolkit.*;

public class Check {

    public static String TextChecker(String File1, String File2) {

        InputTextFile FileIniziale = new InputTextFile(File1); 
        InputTextFile FileDecompresso = new InputTextFile(File2);

        int[] freq1 = Huffman.charHistogram(File1); 
        Node root1 = Huffman.huffmanTree(freq1); 
        int count1 = root1.weight();

        int[] freq2 = Huffman.charHistogram(File2); 
        Node root2 = Huffman.huffmanTree(freq2); 
        int count2 = root2.weight();

        if (count1 == count2) {
            while (FileIniziale.textAvailable()) { 
                if (FileIniziale.readChar() == FileDecompresso.readChar()) {
                    return "Dal confronto risulta che i file decompressi sono identici"; 
                } else {
                    return "Dal confronto risulta che i file decompressi sono diversi";
                }
            }
        }
        return "I file hanno lunghezza diversa: Confronto impossibile";
    }

    public static int CharCounter(String File1) {
        InputTextFile FileIniziale = new InputTextFile(File1);
        int k = 0;
        while (FileIniziale.textAvailable()) {
            FileIniziale.readChar();
            k++;
        }
        return k;
    }
}