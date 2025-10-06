public class App {
    // Metodo main per eseguire il codice
    public static void main(String[] args)
    { 
        SList<Board> sol = Queens.listOfAllSolutions(8);
        Queens.view( sol );    
    }
}
