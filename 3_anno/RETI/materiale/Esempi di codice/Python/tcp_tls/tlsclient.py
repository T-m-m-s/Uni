import socket
import ssl

def client_program():
    host = socket.gethostname()  # as both code is running on same pc
    port = 1234  # socket server port number

    client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)  # instantiate
    client_socket.connect((host, port))  # connect to the server

    context = ssl.SSLContext(ssl.PROTOCOL_TLSv1_2)
    context.check_hostname = False # for using self-signed certificates
    context.verify_mode = ssl.CERT_NONE # for using self-signed certificates
    client_socket = context.wrap_socket(client_socket, server_hostname=host)

    print(client_socket.version)
    print(client_socket.cipher())

    message = input(" -> ")  # take input

    while message.lower().strip() != 'bye':
        client_socket.send(message.encode())  # send message
        data = client_socket.recv(1024).decode()  # receive response
        print('Received from server: ' + data)  # show in terminal
        message = input(" -> ")  # again take input

    client_socket.close()  # close the connection


if __name__ == '__main__':
    client_program()
