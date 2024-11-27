#!/usr/local/bin/python3.11

import glob
import os
import socket

DPINGER_SOCK_PATH = "/var/run/"  # Define the path where dpinger sockets are located

for sock_name in glob.glob("/var/run/dpinger*.sock"):  # Iterate through all the dpinger sockets in the path
    try:
        with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as sock:  # Create a Unix domain socket
            sock_path = os.path.join(DPINGER_SOCK_PATH, sock_name)  # Get the full path of the current socket
            sock.settimeout(2)  # Set a timeout for socket operations (2 seconds)
            sock.connect(sock_path)  # Connect to the dpinger socket
            line = sock.recv(1024).decode().split('\n', 1)[0]  # Receive data from the socket and decode it
            values = line.split()  # Split the received data into a list of values
            # Print the extracted values as formatted string, including gateway name, round-trip time (in seconds), and packet loss percentage
            print(f"{values[0]} {round(int(values[1])/1000)} {round(int(values[3]))}")
    except Exception as e:
        print(f"Error accessing dpinger socket: {e}")  # Print error message if an exception occurs during socket operations
