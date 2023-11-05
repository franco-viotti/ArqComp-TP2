"""
Programa para comunicarse con una FPGA a traves de un puerto serial.
"""

import sys
import time
import signal
import serial
import serial.tools.list_ports


# Obtener una lista de todos los puertos seriales disponibles
ports = list(serial.tools.list_ports.comports())

# Guardar el puerto en una variable
if ports:
    port = ports[0].device
else:
    print("No se encontro ningun puerto serial disponible.")
    sys.exit(1)

serial_port = serial.Serial(port=port,
                            baudrate=19200,
                            parity=serial.PARITY_NONE,
                            stopbits=serial.STOPBITS_ONE,
                            bytesize=serial.EIGHTBITS,
                            timeout=0)

def sigint_handler(signal, frame):
    """
    Funcion que maneja la señal SIGINT.

    Parameters:
    signal: Señal recibida.
    frame: Frame actual.

    Returns:
    None
    """
    print("\nSeñal SIGINT recibida. Cerrando el programa.")
    if 'serial_port' in globals():
        serial_port.close()
    sys.exit(0)

# Configurar el manejo de la señal SIGINT
signal.signal(signal.SIGINT, sigint_handler)

def code_to_bin(code):
    """
    Funcion que transforma el codigo de operacion en codigo binario

    Parameters:
    code (str): Codigo de operacion a transformar en binario

    Returns:
    str: Codigo de operacion en binario
    """
    op_codes = {
        "ADD": 0b100000,
        "SUB": 0b100010,
        "AND": 0b100100,
        "OR":  0b100101,
        "XOR": 0b100110,
        "SRA": 0b000011,
        "SRL": 0b000010,
        "NOR": 0b100111
    }
    return op_codes.get(code, "100000")

def write_to_fpga(data_to_send):
    """
	Funcion que escribe un string en la FPGA.

	Parameters:
	data (str): String a escribir en la FPGA.

	Returns:
	None
	"""
    data_to_send = int(data_to_send).to_bytes(1, 'big')
    serial_port.write(data_to_send)
    time.sleep(0.05)

def read_from_fpga():
    """
	Funcion que lee un byte de la FPGA.

	Parameters:
	None

	Returns:
	int: Byte leido desde la FPGA.
	"""
    return int.from_bytes(serial_port.read(), byteorder='big')

def check_valid_opcode(op_code):
    """
    Verifica si el codigo de operacion ingresado es valido.

    Parameters:
    op_code (str): Cdigo de operacion a verificar.

    Returns:
    None
    """
    valid_op_codes = ["ADD", "SUB", "AND", "OR", "XOR", "SRA", "SRL", "NOR"]
    if op_code not in valid_op_codes:
        print("El codigo de operacion ingresado no es valido.")
        sys.exit(1)

def check_valid_operand(operand):
    """
    Verifica si el operando ingresado es válido.

    Parameters:
    operand (str): Operando a verificar.

    Returns:
    bool: True si el operando es válido, False en caso contrario.
    """
    try:
        value = int(operand)
        if -128 <= value <= 127:
            return True
        else:
            print("El operando ingresado no es representable en 8 bits. Intente nuevamente.")
            sys.exit(1)
    except (ValueError, OverflowError):
        print("El operando ingresado no es valido o es muy grande. Intente nuevamente.")
        sys.exit(1)


while True:
    # Ingreso de codigo de operacion
    op_code = input("Ingrese un codigo de operacion entre los siguientes:\
 ADD, SUB, AND, OR, XOR, SRA, SRL, NOR: \n\
>> ")
    op_code = op_code.upper()
    check_valid_opcode(op_code)
    op_code = code_to_bin(op_code)
    write_to_fpga(op_code) # Enviando el codigo de operacion al arduino

	# Ingreso de operando A
    data_a = input("Ingrese el operando A:\n>> ")
    print(f"El operando A es {data_a}")
    check_valid_operand(data_a)
    write_to_fpga(data_a) # Enviando el operando A al arduino

	# Ingreso de operando B
    data_b = input("Ingrese el operando B:\n>> ")
    print(f"El operando B es {data_b}")
    check_valid_operand(data_b)
    write_to_fpga(data_b) # Enviando el operando B al arduino

    # Lectura de respuesta del arduino
    data = read_from_fpga()
    print(f"Resultado:\n>> {data}")
    print("==================================")
