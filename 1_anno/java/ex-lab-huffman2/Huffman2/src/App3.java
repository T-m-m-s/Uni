public class App3 {
    public static void main(String[] args) throws Exception {
        String File = "C:\\Projects\\java\\ex-lab-huffman2\\Huffman2\\src\\Testo2.txt";
        //Metodo di compressione fatto in classe
        Huffman.compress(File,"FileCompresso.txt"); 
        Huffman.decompress("FileCompresso.txt","FileDecompresso.txt");
        
        //Metodo di compressione fatto con Statistics
        Huffman.compressStat(File,"FileComStats.txt"); 
        Huffman.decompressStat("FileComStats.txt","FileDeStats.txt");
        
        //Confronto tra i due file: 
        System.out.print(Check.TextChecker("FileDecompresso.txt", "FileDeStats.txt") + "\n"); 
        System.out.print("Il file originale ha: " + Check.CharCounter(File) + " caratteri" + "\n"); 
        System.out.print("Il file compresso con il metodo in classe ha: " + Check.CharCounter("FileCompresso.txt") + " caratteri" +  "\n"); 
        System.out.print("Il file compresso con il metodo Statistics ha: " + Check.CharCounter("FileComStats.txt") + " caratteri" + "\n"); 
    }
}
