public class StringSList {
    private final boolean empty;
    private final String first;
    private final StringSList rest;

    public StringSList() {
        empty = true;
        first = null;
        rest = null;
    }

    public StringSList(String e, StringSList sl) {
        empty = false;
        first = e;
        rest = sl;
    }

    public boolean isNull() {
        return empty;
    }

    public String car() {
        if (isNull()) {
            throw new IllegalStateException("car called on an empty list");
        }
        return first;
    }

    public StringSList cdr() {
        if (isNull()) {
            throw new IllegalStateException("cdr called on an empty list");
        }
        return rest;
    }

    public StringSList cons(String e) {
        return new StringSList(e, this);
    }

    public int length() {
        if (isNull()) {
            return 0;
        } else {
            return 1 + rest.length();
        }
    }

    public String listRef(int k) {
        if (k < 0) {
            throw new IndexOutOfBoundsException("Index must be non-negative");
        }
        if (isNull()) {
            throw new IndexOutOfBoundsException("Index out of bounds");
        }
        if (k == 0) {
            return car();
        } else {
            return cdr().listRef(k - 1);
        }
    }

    public boolean equals(StringSList s) {
        if (isNull() && s.isNull()) {
            return true;
        }
        if (!isNull() && !s.isNull() && car().equals(s.car())) {
            return cdr().equals(s.cdr());
        }
        return false;
    }

    public StringSList append(StringSList s) {
        if (isNull()) {
            return s;
        } else {
            return cdr().append(s).cons(car());
        }
    }

    public StringSList reverse() {
        return reverseHelper(new StringSList());
    }

    private StringSList reverseHelper(StringSList s) {
        if (isNull()) {
            return s;
        } else {
            return cdr().reverseHelper(s.cons(car()));
        }
    }
    @Override
    public String toString() {
        if (isNull()) {
            return "()";
        } else {
            StringBuilder sb = new StringBuilder("(");
            sb.append(car());
            StringSList current = cdr();
            while (!current.isNull()) {
                sb.append(", ").append(current.car());
                current = current.cdr();
            }
            sb.append(")");
            return sb.toString();
        }
    }

    // Esempio di utilizzo
    public static void main(String[] args) {
        StringSList list = new StringSList().cons("c").cons("b").cons("a");
        System.out.println("Lista originale: " + list);
        System.out.println("Lista dopo cons('d'): " + list.cons("d"));
        System.out.println("Elemento all'indice 1: " + list.listRef(1));
        System.out.println("Lunghezza della lista: " + list.length());
        System.out.println("Lista invertita: " + list.reverse());
        System.out.println("Liste uguali?: " + list.equals(new StringSList().cons("c").cons("b").cons("a")));
    }
}
