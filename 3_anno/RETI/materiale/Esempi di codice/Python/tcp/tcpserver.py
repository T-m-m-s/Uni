import socket


def server_program():
    port = 1234  # let's choose a port, above 1024

    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)  # get socket instance
    server_socket.bind(('', port))  # bind socket to "any" host address and port

    # configure how many client the server can listen simultaneously
    server_socket.listen(2)

    while True: # we will serve clients forever
        conn, address = server_socket.accept()  # accept new connection
        print("Opened connection from: " + str(address))
        while True: # let's enter the service loop for this client
            # receive data stream. it won't accept data packet greater than 1024 bytes
            data = conn.recv(1024).decode()
            if not data:
                # if no data is received, end service loop
                break
            print("from connected user: " + str(data)) # echo data on terminal
            data = input(' -> ') # get data to be sent to the client, from the terminal
            conn.send(data.encode())  # send data to the client
        conn.close()  # close the connection
        print("Closed connection from: " + str(address))



if __name__ == '__main__':
    server_program()