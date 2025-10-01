import numpy as np
import socket
import time

ADDR = "10.1.1.112"
PORT = 1234

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind(("", PORT))

command = np.zeros(2, np.uint64)

command[0] = (1 << 63) + 0

for i in range(10):
    command[1] ^= np.uint64(0b0101)
    sock.sendto(command, (ADDR, PORT))
    time.sleep(0.5)
