public class BtrFunc {

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

    public static StringSList btrRange(String btr, int n) {
        StringSList result = new StringSList();
        String current = btr;

        for (int i = 0; i < n; i++) {
            result = result.cons(current);
            current = btrSucc(current);
        }

        return result.reverse();
    }

    // Metodo main per eseguire il codice
    public static void main(String[] args) {
        String btr = "+-";
        int n = 5;
        StringSList btrs = btrRange(btr, n);

        System.out.println("Lista generata: " + btrs);

        StringSList result1 = btrs.append(btrs.reverse().cdr());
        System.out.println("Risultato append(reverse(cdr())): " + result1);

        String lastBtr = btrs.listRef(btrs.length() - 1);
        StringSList result2 = btrs.append(btrRange(btrSucc(lastBtr), btrs.length()));
        System.out.println("Risultato append(btrRange(btrSucc(last), length())): " + result2);
    }
}
