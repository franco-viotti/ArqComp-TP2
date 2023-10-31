import serial

ser = serial.Serial('COM3', 19200)  # Reemplaza 'COM3' y 9600 con los valores adecuados

data_to_send = bytes([0x01, 0x02, 0x03])
ser.write(data_to_send)

# Espera un tiempo suficiente para que Arduino procese y responda
import time
time.sleep(1)  # Ajusta el tiempo según tus necesidades

# Lee la respuesta de Arduino
response = ser.read(1)  # Lee un byte como respuesta
print(f'Resultado de la suma: {response}')

ser.close()
