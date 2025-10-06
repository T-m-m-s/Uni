import puzzleboard.*;

public class App1 {
    // Metodo main per eseguire il codice
    public static void main(String[] args) {
        Puzzle pb = new Puzzle(4); // Matrice randomica
        PuzzleBoard gui = new PuzzleBoard(4); // Rappresentazione grafica della matrice

        while (!pb.isSorted()) // Finché la matrice non è ordinata
        {
            int[][] board = pb.getBoard(); // Visualizzo la matrice attraverso la gui

            // Itero sulle righe
            for (int i = 1; i <= 4; i++) {
                // Itero sulle colonne
                for (int j = 1; j <= 4; j++) {
                    gui.setNumber(i, j, board[i - 1][j - 1]); // Colloca in <i,j> il valore della matrice in
                                                              // posizione <i-1,j-1>
                }
            }

            gui.display(); // Visualizza la matrice

            int k = gui.get(); // Ottiene il valore preso con il click
            int[] posK = pb.posCasellaX(k);
            pb.Move(posK[0], posK[1]); // Scambia le caselle

        }

        if (pb.isSorted()) {
            System.out.print("Hai vinto! Complimenti");
        }
    }
}
