import socket
import ssl

def server_program():
    # get the hostname
    host = socket.gethostname()
    port = 1234  # initiate port, above 1024

    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)  # get instance

    # Wrap the socket in TLS
    context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
    context.load_cert_chain('server.crt', 'server.key')
    server_socket = context.wrap_socket(server_socket)

    server_socket.bind((host, port))  # bind host address and port together

    # configure how many client the server can listen simultaneously
    server_socket.listen(2)
    conn, address = server_socket.accept()  # accept new connection
    print("Connection from: " + str(address))
    while True:
        # receive data stream. it won't accept data packet greater than 1024 bytes
        data = conn.recv(1024).decode()
        if not data:
            # if data is not received break
            break
        print("from connected user: " + str(data)) # echo data on terminal
        data = input(' -> ') # get data to be sent to the client, from the terminal
        conn.send(data.encode())  # send data to the client

    conn.close()  # close the connection


if __name__ == '__main__':
    while True:
        server_program()