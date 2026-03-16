import java.io.*;
import java.net.*;

class UDPUpperServer {
    public static void main(String argv[]) throws Exception
    {
	DatagramSocket serverSocket = new DatagramSocket(9876);
	byte[] sendData = new byte[1024];
	byte[] receiveData = new byte[1024];
	
	while (true) {
	    // puliamo il buffer di input
	    for (int i=0; i<1024; i++)
		receiveData[i] = 0;

	    // creiamo l'oggetto dove ricevere il datagramma
	    DatagramPacket receivePacket = new DatagramPacket(receiveData, receiveData.length);

	    // riceviamo il prossimo datagramma
	    serverSocket.receive(receivePacket);
	    
	    // ora estraiamo la stringa ricevuta
	    String sentence = new String(receivePacket.getData());
	    InetAddress IPAddress = receivePacket.getAddress();  // Indirizzo IP e porta del mittente
	    int port = receivePacket.getPort();
	    System.out.println("RECEIVED '" + sentence + "' FROM " + IPAddress + ":" + port);

	    // elaboriamo la risposta
	    String capitalizedSentence = sentence.toUpperCase();
	    sendData = capitalizedSentence.getBytes();

	    // prepariamo il pacchetto di risposta (notare IP e porta del destinatario)
	    DatagramPacket sendPacket = new DatagramPacket(sendData, sendData.length, IPAddress, port);

	    // inviamo la risposta
	    serverSocket.send(sendPacket);
	}
    }
}
