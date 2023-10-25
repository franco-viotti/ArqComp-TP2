import serial

# Configurar el puerto serial
# Si se le pasa el puerto (port!=None), se abre el puerto serial
serial_port = serial.Serial(
                                port="/dev/ttyUSB0",
                                baudrate=19200,
                                bytesize=8,
                                parity="PARITY_NONE",
                                stopbits="STOPBITS_ONE")  # Reemplazar '/dev/ttyUSB0' con el puerto serial apropiado

# Función para enviar un dato a la FPGA
def send_data(data):
    serial_port.write(data)

# Función para recibir datos de la FPGA
def read_data(size):
    return serial_port.read_until(size)

# Función que transforma en binario el código de operación
def code_to_bin(op_code):
    return {
        'ADD': "100000",
        'SUB': "100010",
        'AND': "100100",
        'OR': "100101",
        'XOR': "100110",
        'SRA': "000011",
        'SRL': "000010",
        'NOR': "100111"
    }.get(op_code, None)

# Función que transforma en binario un operando
def int_to_bin8(operand):
    if operand < -128 or operand > 127:
        raise ValueError("El operando debe estar en el rango de -128 a 127 para ser representado con 8 bits signados.")
    if operand >= 0:
        return bin(operand)[2:].zfill(8)
    else:
        return bin(256 + operand)[2:]

try:
    # Pedir datos al usuario
    valid_ops = ["ADD", "SUB", "AND", "OR", "XOR", "SRA", "SRL", "NOR"]
    op_code = input("Ingrese el código de operación: ")

    # Verificar si el código de operación es válido y transformar en binario
    if op_code not in valid_ops:
        raise ValueError("Operación inválida. Las operaciones válidas son ADD, SUB, AND, OR, XOR, SRA, SRL, NOR. Intente de nuevo.")
    op_code = code_to_bin(op_code)

    # Solicitar y verificar los operandos
    data_a = int(input("Ingrese el primer operando: "))
    if data_a < -128 or data_a > 127:
        raise ValueError("El primer operando debe ser un número entero representable con 8 bits signados.")
    data_a = int_to_bin8(data_a)

    data_b = int(input("Ingrese el segundo operando: "))
    if data_b < -128 or data_b > 127:
        raise ValueError("El segundo operando debe ser un número entero representable con 8 bits signados.")
    data_b = int_to_bin8(data_b)

    # Enviar cada dato a la FPGA
    serial_port.send_data(op_code)
    serial_port.send_data(data_a)
    serial_port.send_data(data_b)

    # Leer la respuesta de la FPGA
    result = serial_port.read_data(8)  # Lee 8 bits de datos de la FPGA
    print('Datos recibidos de la FPGA:', result)

except ValueError as ve:
    print(ve)

except serial.SerialException as e:
    print('Error al abrir el puerto serial:', e)

finally:
    serial_port.close()
