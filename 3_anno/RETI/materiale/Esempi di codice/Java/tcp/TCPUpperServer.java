// Uso: java TCPUpperServer <address> <port>

import java.io.*;
import java.net.*;

public class TCPUpperServer {
    public static void main(String argv[]) throws Exception {
		// creiamo una socket di attesa per l'apertura passiva
    	ServerSocket welcomeSocket = new ServerSocket();

		// la leghiamo alla porta prescelta (solleva eccezione se errore)
		String address = argv[0];
		int port = Integer.parseInt(argv[1]);
		welcomeSocket.bind(new InetSocketAddress(address, port)); // si può specificare anche un backlog

        while (true) {
	    	// ci mettiamo in attesa della prossima connessione (apertura passiva)
	    	System.out.println("In attesa del prossimo client");
            Socket connectionSocket = welcomeSocket.accept();

	    	System.out.println("Nuova connessione da " + connectionSocket.getInetAddress() + ":" + connectionSocket.getPort());

	    	// otteniamo dalla socket aperta i due oggetti per la comunicazione bidirezionale con il client	    
            DataInputStream inFromClient = new DataInputStream(connectionSocket.getInputStream());
            DataOutputStream outToClient = new DataOutputStream(connectionSocket.getOutputStream());

	    	// entriamo nel loop di servizio al client
	    	try {
	    		while (true) {
					// leggiamo una linea di testo dal client
					String clientSentence = inFromClient.readUTF();	
		
					// altrimenti la elaboriamo
					String capitalizedSentence = clientSentence.toUpperCase();
		
					// e inviamo la risposta al client
					outToClient.writeUTF(capitalizedSentence);
				}	
	    	}
	    	catch (EOFException e) {
		    	// il client ha chiuso la connessione, chiudiamo anche noi e torniamo in attesa
		    	System.out.println("Connessione chiusa.");
	    		connectionSocket.close();
	    	}
		}
    }
}
