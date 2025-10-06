public class RoundTable {
    private IntSList knights;

    // Inizializzazione dei cavalieri
    public RoundTable(int n) {
        knights = IntSList.NULL_INTLIST;
        for (int i = n; i >= 1; i--) {
            knights = knights.cons(i);
        }
    }

    // Restituisce il numero di cavalieri ancora seduti al tavolo
    public int numberOfKnights() {
        return knights.length();
    }

    // Restituisce la coppia di cavalieri che possono servire o servirsi
    public IntSList servingKnights() {
        if (numberOfKnights() <= 2) {
            return knights;
        } else {
            int secondLast = knights.listRef(numberOfKnights() - 2);
            int last = knights.listRef(numberOfKnights() - 1);
            return new IntSList(secondLast, new IntSList(last, IntSList.NULL_INTLIST));
        }
    }

    // Rimuove il cavaliere che ha appena bevuto e si alza
    public void serveNeighbour() {
        if (numberOfKnights() > 2) {
            knights = removeElement(knights, 2);
        }
    }

    // Passa la brocca al prossimo cavaliere
    public void passJug() {
        if (numberOfKnights() > 1) {
            int first = knights.car();
            int second = knights.listRef(1);
            knights = knights.cdr().cdr().append(new IntSList(first, IntSList.NULL_INTLIST));
            knights = knights.append(new IntSList(second, IntSList.NULL_INTLIST));
        }
    }

    // Metodo helper per rimuovere un elemento da IntSList
    private IntSList removeElement(IntSList list, int index) {
        if (index == 0) {
            return list.cdr();
        } else {
            return new IntSList(list.car(), removeElement(list.cdr(), index - 1));
        }
    }

    // Metodo principale per ottenere i due cavalieri finali
    public static IntSList josephus(int n) {
        RoundTable rt = new RoundTable(n);
        while (rt.numberOfKnights() > 2) {
            rt.serveNeighbour();
            rt.passJug();
        }
        return rt.servingKnights();
    }

    
    // Metodo main per eseguire il codice
    public static void main(String[] args) {
        System.out.println(josephus(2));   
        System.out.println(josephus(3));   
        System.out.println(josephus(4));   
        System.out.println(josephus(5));   
        System.out.println(josephus(6));  
        System.out.println(josephus(7));  
        System.out.println(josephus(8));   
        System.out.println(josephus(12)); 
        System.out.println(josephus(1500)); 
    }
}
