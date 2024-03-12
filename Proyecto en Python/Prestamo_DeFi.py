import json
from web3 import Web3

# Conexión a Ganache
ganache_url = "http://127.0.0.1:7545"
web3 = Web3(Web3.HTTPProvider(ganache_url))

# Dirección y ABI del contrato inteligente
contract_address = "0x02913f29016a99c508448c37c197c12921368f5582a1e4d652ffebe6a88abadb"
contract_abi = json.loads('{"constant":true,"inputs":[],"name":"getBalance","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_value","type":"uint256"}],"name":"withdraw","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"}')

# Carga del contrato inteligente
contract = web3.eth.contract(address=contract_address, abi=contract_abi)

# Función para solicitar un préstamo
def solicitar_prestamo():
    # Lógica para solicitar un préstamo
    pass

# Función para aprobar un préstamo
def aprobar_prestamo():
    # Lógica para aprobar un préstamo
    pass

# Función para depositar garantía
def depositar_garantia():
    # Lógica para depositar garantía
    pass

# Función para liquidar garantía
def liquidar_garantia():
    # Lógica para liquidar garantía
    pass

# Función para reembolsar préstamo
def reembolsar_prestamo():
    # Lógica para reembolsar préstamo
    pass

# Menú interactivo en consola
def menu():
    while True:
        print("1. Solicitar préstamo")
        print("2. Aprobar préstamo")
        print("3. Depositar garantía")
        print("4. Liquidar garantía")
        print("5. Reembolsar préstamo")
        print("6. Salir")
        
        opcion = input("Seleccione una opción: ")
        
        if opcion == "1":
            solicitar_prestamo()
        elif opcion == "2":
            aprobar_prestamo()
        elif opcion == "3":
            depositar_garantia()
        elif opcion == "4":
            liquidar_garantia()
        elif opcion == "5":
            reembolsar_prestamo()
        elif opcion == "6":
            print("Saliendo...")
            break
        else:
            print("Opción inválida")

# Ejecutar el menú interactivo
menu()
