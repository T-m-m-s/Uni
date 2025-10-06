public class App2 {
    public static void main(String[] args) {
        RandomText.RandomT("Test.txt");
        Huffman.compress("Test.txt","FileCompresso.txt");
        Huffman.decompress("FileCompresso.txt","FileDecompresso.txt");
        System.out.print("\n" + Check.TextChecker("Test.txt","FileDecompresso.txt") + "\n");
    }
}
