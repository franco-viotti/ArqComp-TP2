"""
    Script para comunicacion serial con FPGA

    Parameters:
    port (str): Puerto a utilizar

    Returns:
    Resultado de la operación entre dos operandos
"""
import sys
import serial

if len(sys.argv) < 2 or not sys.argv[1].isdigit():
    raise ValueError("El número de puerto serial es inválido.")

port_number = sys.argv[1]
#PORT = f'/dev/ttyUSB{int(port_number)}'
PORT = f'COM{int(port_number)}'

# Configurar el puerto serial
# Si se le pasa el puerto (port!=None), se abre el puerto serial
serial_port = serial.Serial(
    port=PORT,
    baudrate=19200,
    bytesize=serial.EIGHTBITS,
    parity=serial.PARITY_NONE,
    stopbits=serial.STOPBITS_ONE,
    timeout=0
)

def send_data(data):
    """
    Función para enviar un dato a la FPGA

    Parameters:
    data (bytes): Dato a enviar a la FPGA

    Returns:
    None
    """
    serial_port.write(int(data).to_bytes(1, "big"))

def read_data(size):
    """
    Función para recibir datos de la FPGA

    Parameters:
    size (int): Cantidad de bytes a leer de la FPGA

    Returns:
    str: Datos recibidos de la FPGA decodificados con utf-8
    """
    return serial_port.read_until(size).decode('utf-8')

def code_to_bin(code):
    """
    Función que transforma en binario el código de operación

    Parameters:
    code (str): Código de operación a transformar en binario

    Returns:
    str: Código de operación en binario
    """
    return {
        'ADD': 0b100000,
        'SUB': 0b100010,
        'AND': 0b100100,
        'OR' : 0b100101,
        'XOR': 0b100110,
        'SRA': 0b000011,
        'SRL': 0b000010,
        'NOR': 0b100111
    }.get(code, None)

# Se limpian las pilas de datos no leídos o escritos pero no enviados
serial_port.flushInput()
serial_port.flushOutput()

try:
    # Pedir datos al usuario
    valid_ops = ["ADD", "SUB", "AND", "OR", "XOR", "SRA", "SRL", "NOR"]
    op_code = input("Ingrese uno de los siguientes códigos de operación: \
                    ADD, SUB, AND, OR, XOR, SRA, SRL, NOR ")

    # Verificar si el código de operación es válido y transformar en binario
    if op_code not in valid_ops:
        raise ValueError("Operación inválida. Intente de nuevo.")
    op_code = code_to_bin(op_code)

    # Solicitar y verificar los operandos
    data_a = int(input("Ingrese el primer operando: "))
    if data_a < -128 or data_a > 127:
        raise ValueError("El primer operando debe ser un número\
                          entero representable con 8 bits signados.")

    data_b = int(input("Ingrese el segundo operando: "))
    if data_b < -128 or data_b > 127:
        raise ValueError("El segundo operando debe ser un número\
                          entero representable con 8 bits signados.")

    # Enviar cada dato a la FPGA
    send_data(op_code)
    print(f'Enviando código de operación: {int(op_code).to_bytes(1, "big")}')
    print(f'Opcode sin formateo: {op_code}')
    print(f'Opcode formateado en bytes: {op_code.to_bytes(1, "big")}')
    send_data(data_a)
    print(f'Enviando primer operando: {int(data_a).to_bytes(1, "big")}')
    send_data(data_b)
    print(f'Enviando segundo operando: {int(data_b).to_bytes(1, "big")}')

    # Leer el resultado de la FPGA
    result = read_data('1')
    print(f"El resultado de {data_a} {op_code} {data_b} es: {result}")

except ValueError as ve:
    print(ve)

except serial.SerialException as e:
    print('Error al abrir el puerto serial:', e)

finally:
    serial_port.close()