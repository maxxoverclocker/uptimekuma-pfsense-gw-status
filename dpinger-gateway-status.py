#!/usr/local/bin/python3.8

import glob, os, socket

DPINGER_SOCK_PATH = "/var/run/"

os.chdir(DPINGER_SOCK_PATH)

for sock_name in glob.glob("dpinger*.sock"):
    sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    sock_path = DPINGER_SOCK_PATH+sock_name
    s = sock.connect(sock_path)
    line = sock.recv(1024).decode().split('\n', 1)[0]
    values = line.split()
    print(values[0]+" "+str(round(int(values[1])/1000))+" "+str(round(int(values[3]))))
    sock.close()
