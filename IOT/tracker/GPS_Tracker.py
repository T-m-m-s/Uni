'''
    GPS Data Tracking Service:
      un semplice socket server multi-thread
        con connessione seriale al dispositivo GPS.
'''
import os
import socket
import json
import threading
import serial
import signal
import sys
import datetime
import time

serials=[]
serial_threads=[]
serial_data=[]
DEVICE_NAME="Kendau GPS"
SERIAL_PORT="COM17"
BAUDRATE=9600
shutdown = False
entity_name='Test'
GPS_LOG='gps_tracking_log.txt'
HOST = ''   # La stringa vuota sta ad indicare qualunque indirizzo valido della macchina
GPS_PORT = 4545 # Porta non privilegiata per la connessione dei client
gps_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

# Una classe per rappresentare le coordinate GPS di un oggetto
class coordinates:
	def __init__(self,label,lat,latdir,lon,londir):
		self.label=label
		self.lat=lat
		self.latdir=latdir
		self.lon=lon
		self.londir=londir

	def print_json(self):
		return '{"entity_name": "'+self.label+\
		        '", "lat": "'+str(self.lat)+\
		        '", "latdir": "'+str(self.latdir)+\
		        '", "lon": "'+str(self.lon)+\
   		        '", "londir": "'+str(self.londir)+'"}'

# Variabile per memorizzare l'ultima posizione valida dell'oggetto tracciato.
last_position = coordinates(entity_name,'unknown','unknown','unknown','unknown')

class serial_port:
	def __init__(self,label,port_number,baudrate):
		self.label = label
		self.port = serial.Serial()
		self.port.port = port_number
		self.port.baudrate=baudrate
		self.open=False
		self.port.bytesize=serial.EIGHTBITS
		self.port.parity=serial.PARITY_NONE
		self.port.stopbits=serial.STOPBITS_ONE
		self.port.timeout=20         # Leggeremo una linea per volta: il timeout (in secondi) serve a non rimanere bloccati in caso di assenza di dati dal dispositivo
		self.port.xonxoff = False    # disabilita il flusso di controllo software
		self.port.rtscts = False     # disabilita il flusso di controllo hardware (RTS/CTS)
		self.port.dsrdtr = False     # disabilita il flusso di controllo hardware (DSR/DTR)

	def open_connection(self):
		if not self.open:
			print('('+self.label+') opening connection')
			self.port.open()
			self.open = True

	def read_line(self):
		try:
			line = str(self.port.readline().decode('ascii')).strip()
		except:
			line=''
		return line

	def close_connection(self):
		if self.open:
			print('('+self.label+') closing connection')
			self.port.close()
			self.open = False

	def __del__(self):
		if self.open:
			self.port.close()
			self.open = False

# Mutex per evitare race condition sulle strutture dati.
serial_data_lock = threading.Lock()

def signal_handler(signal, frame):
	    global shutdown
	    shutdown = True
	    print('You pressed Ctrl+C!\nExiting...')

	    print('Closing server...')
	    try: # connessione dummy per svegliare il server, se è rimasto bloccato in stato di accept
	    	s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	    	s.connect(("localhost",GPS_PORT))
	    	bytes_recv=0
	    	while True:
	    		bytes_recv = s.recv(4096).decode()
	    		if not bytes_recv:
	    			break
	    except:
	    	pass

def filter(s):
    return s.startswith('$GNRMC') or s.startswith('$GPRMC')

gps=serial_port(DEVICE_NAME,SERIAL_PORT,BAUDRATE)
serials.append(gps)

def tokenize(line):
	return line.split(',')

def serial_reader(s):
	global shutdown
	s.open_connection()
	while not shutdown:
		new_data=s.read_line()
		if len(new_data)>0 and filter(new_data):
			serial_data_lock.acquire()
			serial_data.append(new_data)
			fields=tokenize(new_data)
			if fields[2]=='A' : # se i dati sono validi
				last_position.lat=fields[3]
				last_position.latdir=fields[4]
				last_position.lon=fields[5]
				last_position.londir=fields[6]
			serial_data_lock.release()
	s.close_connection()

signal.signal(signal.SIGINT, signal_handler)
print('Press Ctrl+C to stop and exit!')

for port in serials:
	new_thread=threading.Thread(target=serial_reader,args=(port,))
	serial_threads.append(new_thread)
	new_thread.start()

# Funzione per la gestione delle connessioni dei client. Ogni client sarà gestito da un thread diverso.
def handleGPSClient(conn):
	conn.sendall(last_position.print_json().encode())
	conn.close()
	print('Data sent, closed client connection!')

def gps_tracking_server(gps_socket):
	global shutdown
	gps_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
	print('GPS Socket created')

	# Lega la socket al localhost ed alla porta del servizio GPS
	try:
		gps_socket.bind((HOST, GPS_PORT))
	except socket.error as msg:
		print('(GPS port) Bind failed. Error Code : ' + str(msg[0]) + ' Message ' + msg[1])
		sys.exit(1)
     
	print('(GPS port) Socket bind complete')
 
	# Inizia l'ascolto sulla socket del servizio GPS
	gps_socket.listen(10)
	print('GPS Socket now listening')
 
	# Ciclo per l'accettazione e la gestione dei client.
	while not shutdown:
		# Attende una richiesta di connessione - la chiamata è bloccante!
		conn, addr = gps_socket.accept()
		print('Connected with ' + addr[0] + ':' + str(addr[1]))
     
		# Fa partire un nuovo thread per gestire il client connesso.
		gps_client_thread=threading.Thread(target=handleGPSClient,args=(conn,))
		gps_client_thread.start()
 
	gps_socket.close()
	print('Server closed')

gps_server_thread=threading.Thread(target=gps_tracking_server,args=(gps_socket,))
gps_server_thread.start()

def file_logger(filename):
	global shutdown
	print('File logger started!')
	out_file = open(filename,"a")
	while not shutdown:
		time.sleep(30)
		print('Logging to %s' % (filename))
		serial_data_lock.acquire()
		serial_data_copy=serial_data.copy()
		serial_data.clear()
		serial_data_lock.release()
		for line in serial_data_copy:
			out_file.write(line+'\n')
		print('Finished logging to %s' % (filename))
		out_file.flush()
	out_file.close()

logger_thread=threading.Thread(target=file_logger,args=(GPS_LOG,))
logger_thread.start()

while not shutdown:
	pass

for t in serial_threads:
	t.join()
print('Reader threads exited!')

gps_server_thread.join()

print('Server thread exited!')

print('Closing logger (30s)...')
logger_thread.join()
print('Logger thread exited!')

sys.exit(0)
