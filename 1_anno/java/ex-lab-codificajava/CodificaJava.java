public class CodificaJava {
    //Parte 1---------------------------------------------------------------------------------------
    public static String btrSucc(String btr) {
        int n = btr.length();
        char lsb = btr.charAt(n - 1);

        if (n == 1) {
            return lsb == '+' ? "+-" : "+";
        } else {
            String pre = btr.substring(0, n - 1);
            if (lsb == '+') {
                return btrSucc(pre) + "-";
            } else {
                return pre + (lsb == '-' ? "." : "+");
            }
        }
    }

    //Parte 2---------------------------------------------------------------------------------------
    public static String bitComplement(String bit) {
        if (bit.equals("0")) {
            return "1";
        } else {
            return "0";
        }
    }

    public static String onesComplement(String bin) {
        if (bin.equals("")) {
            return "";
        } else {
            String rest = onesComplement(bin.substring(0, bin.length() - 1));
            String lastBitComplement = bitComplement(bin.substring(bin.length() - 1));
            return rest + lastBitComplement;
        }
    }

    //Esempio di utilizzo-------------------------------------------------------------------------------------------------------
    public static void main(String[] args) {
        System.out.println(btrSucc("."));    // +
        System.out.println(btrSucc("+"));    // +-
        System.out.println(btrSucc("+-"));   // +.
        System.out.println(btrSucc("+."));   // ++
        System.out.println(btrSucc("++-"));  // ++.
        System.out.println(onesComplement("1101")); // "0010"
        System.out.println(onesComplement("0000")); // "1111"
        System.out.println(onesComplement("101010")); // "010101"
    }
}
