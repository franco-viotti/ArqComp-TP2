numero = 32
num_bytes = numero.to_bytes((numero.bit_length() + 7) // 8, byteorder='big')
print(num_bytes)
