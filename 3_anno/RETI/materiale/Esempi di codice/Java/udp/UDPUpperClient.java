import java.io.*;
import java.net.*;

class UDPUpperClient {
    public static void main(String args[]) throws Exception
    {
	// creiamo un Reader dalla console
	BufferedReader inFromUser = new BufferedReader(new InputStreamReader(System.in));

	// prepariamo la socket per l'invio del messaggio
	DatagramSocket clientSocket = new DatagramSocket();
	// qui si può cambiare indirizzo e porta del server
	InetAddress IPAddress = InetAddress.getByName("localhost");
	int PortAddress = 9876;

	// prepariamo i due buffer per inviare e ricevere i dati 
	byte[] sendData = new byte[1024];
	byte[] receiveData = new byte[1024];

	while (true) {
	    // leggiamo una riga dall'utente 
	    System.out.print("Stringa da maiuscolare: ");
	    String sentence = inFromUser.readLine();
	    if (sentence == null) 
			break;
	    sendData = sentence.getBytes();
	    
	    // prepariamo ed inviamo il datagramma
	    DatagramPacket sendPacket = new DatagramPacket(sendData, sendData.length, IPAddress, PortAddress); 
	    clientSocket.send(sendPacket);

	    // e rimaniamo in attesa della risposta
	    DatagramPacket receivePacket = new DatagramPacket(receiveData, receiveData.length);
	    clientSocket.receive(receivePacket);

	    // estraiamo la stringa ricevuta nel datagramma di risposta
	    String modifiedSentence = new String(receivePacket.getData());

	    // e stampiamola sull'output
	    System.out.println("Risposta: " + modifiedSentence);
	}

	// pulizia
	clientSocket.close();
	System.out.println("Ciao e torna presto!");
    }
}
