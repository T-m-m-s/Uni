import socket
import signal
import sys

HOST = '127.0.0.1'
PORT = 2222
CHUNKSIZE = 2048
shutdown=False

def printDataBuffer(dataBuffer):
	for d in dataBuffer:
		str=d.decode('ascii').rstrip('\n')
		if len(str.strip())>0:
			print(str,flush=True)

def signal_handler(signal, frame):
	global shutdown
	shutdown = True
	print('You pressed Ctrl+C!\nExiting...', file=sys.stderr)

signal.signal(signal.SIGINT, signal_handler)
print('Press Ctrl+C to stop and exit!', file=sys.stderr)

s=socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect((HOST, PORT))

dataBuffer=[]

while not shutdown:
	data = s.recv(CHUNKSIZE)
	dataBuffer.append(data)
	if not data or data.decode('ascii').endswith('\n'):
		printDataBuffer(dataBuffer)
		dataBuffer=[]

s.close()
