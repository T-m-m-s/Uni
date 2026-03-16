// Uso: java TCPUpperClient <server address> <port>

import java.io.*;
import java.net.*;

public class TCPUpperClient {
    public static void main(String argv[]) throws Exception {
		// creiamo un Reader dalla console
   		BufferedReader inFromUser = new BufferedReader(new InputStreamReader(System.in));

		// creiamo la socket (non connessa)
    	Socket clientSocket = new Socket();

		// si tenta la connessione al server (apertura attiva)
		// solleva eccezione se fallisce (p.e., Connection Refused)
		clientSocket.connect(new InetSocketAddress(argv[0], Integer.parseInt(argv[1])));  

		// otteniamo dalla socket i due oggetti per la comunicazione bidirezionale con il server
    	DataOutputStream outToServer = new DataOutputStream(clientSocket.getOutputStream()); // dal client al server
    	DataInputStream inFromServer = new DataInputStream(clientSocket.getInputStream());  // dal server al client

		while (true) {
    		// leggiamo una riga dall'utente 
    		System.out.print("Stringa da maiuscolare: ");
    		String sentence = inFromUser.readLine();

	    	if (sentence == null)
	    		break;

	    	// inviamo al server la stringa letta dall'utente
	    	outToServer.writeUTF(sentence);

	    	// leggiamo una riga dal server e stampiamola (deve terminare con "\n")
	    	String modifiedSentence = inFromServer.readUTF();
		    System.out.println("Risposta: " + modifiedSentence);
		}

		// pulizia: chiudiamo la connessione
		clientSocket.close(); 
		System.out.println("Ciao e torna presto!");

    }
}
