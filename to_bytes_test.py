# Entero que quieres convertir a bytes
numero = 32

# Cantidad de bytes (en este caso, 1 byte)
num_bytes = numero.to_bytes(1, byteorder='big')

# Imprime el resultado
print(num_bytes)
