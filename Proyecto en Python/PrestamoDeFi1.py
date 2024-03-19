from web3 import Web3
from web3.exceptions import Web3Exception
# Intentar conectarse a la red de Ganache

try:
    ganache_url = "http://localhost:7545"
    w3 = Web3(Web3.HTTPProvider(ganache_url))
    if not w3.is_connected():
        print("No se pudo conectar a Ganache. Asegúrate de que Ganache esté en funcionamiento.")
        exit()
except Exception as e:
    print(f"Error al intentar conectar con Ganache: {e}")
    exit()

print("Conectado a Ganache")

# Direccion del contrato inteligente desplegado
contract_address = "0x270f178F1f2214365028a369221519767afFC625" #
#Cambia por la dirección del contrato
# Direccion del socio principal
socio_principal_address = "0x92Cdd340BCE528C8856565F74fdEdBAc36cE78e8"
# Cambia por la dirección del socio principal
# Clave privada del socio principal (necesaria para firmar transacciones)
socio_principal_private_key = "0xbeed425931d261e31c7c907d2508b31e9f961f82ebe5d1d167213121da9cd434" # Cambia por la clave privada del socio principal
contract_abi = ('[{"inputs":[],"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"uint256","name":"id","type":"uint256"}],"name":"GarantiaLiquidada","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"uint256","name":"id","type":"uint256"}],"name":"PrestamoAprobado","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"uint256","name":"id","type":"uint256"}],"name":"PrestamoReembolsado","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"uint256","name":"id","type":"uint256"},{"indexed":true,"internalType":"address","name":"prestatario","type":"address"},{"indexed":false,"internalType":"uint256","name":"monto","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"plazo","type":"uint256"}],"name":"SolicitudPrestamo","type":"event"},{"inputs":[],"name":"administrador","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"_nuevoCliente","type":"address"}],"name":"altaCliente","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"_nuevoPrestamista","type":"address"}],"name":"altaPrestamista","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"_cliente","type":"address"},{"internalType":"uint256","name":"_id","type":"uint256"}],"name":"aprobarPrestamo","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"","type":"address"}],"name":"clientes","outputs":[{"internalType":"bool","name":"activado","type":"bool"},{"internalType":"uint256","name":"saldoGarantia","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"depositarGarantia","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[{"internalType":"address","name":"","type":"address"}],"name":"empleadosPrestamista","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"_cliente","type":"address"},{"internalType":"uint256","name":"_id","type":"uint256"}],"name":"liquidarGarantia","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"_id","type":"uint256"}],"name":"reembolsarPrestamo","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"_monto","type":"uint256"},{"internalType":"uint256","name":"_plazo","type":"uint256"}],"name":"solicitarPrestamo","outputs":[],"stateMutability":"nonpayable","type":"function"}]')
contract = w3.eth.contract(address=contract_address, abi=contract_abi)
# Funcion para enviar transaccion:

contract = w3.eth.contract(address=contract_address, abi=contract_abi)

def enviar_transaccion(w3, txn_dict, private_key):
    try:
        signed_txn = w3.eth.account.sign_transaction(txn_dict, private_key=private_key)
        txn_hash = w3.eth.send_raw_transaction(signed_txn.rawTransaction)
        txn_receipt = w3.eth.wait_for_transaction_receipt(txn_hash)
        return txn_receipt
    except Exception as e:
# Lanzar la excepción para ser capturada por la función que llama
        raise Exception(f"Error al enviar la transacción: {e}")
# Funciones de interacción con el contrato
# Función para dar de alta un prestamista por el socio principal
def alta_prestamista(nuevo_prestamista_address):
    try:
                # Verificar si el socio principal está autorizado para realizar esta acción
        if not contract.functions.empleadosPrestamista(socio_principal_address).call():
            raise Exception("El socio principal no está autorizado para dar de alta prestamistas.")
        
        # Construir la transacción
        txn_dict = contract.functions.altaPrestamista(nuevo_prestamista_address).buildTransaction({
            'chainId': 1,  # Reemplaza con el ID de la red Ethereum
            'gas': 2000000,  # Reemplaza con el límite de gas adecuado
            'gasPrice': w3.toWei('50', 'gwei'),  # Reemplaza con el precio de gas adecuado
            'nonce': w3.eth.getTransactionCount(socio_principal_address),
        })
        
        # Enviar la transacción
        txn_receipt = enviar_transaccion(w3, txn_dict, socio_principal_private_key)
        
        print("El prestamista ha sido dado de alta exitosamente por el socio principal.")
        return txn_receipt
    except Exception as e:
        print(f"Error al dar de alta el prestamista: {e}")

# Dirección del nuevo prestamista a dar de alta
nuevo_prestamista_address = "0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2"  # Reemplaza con la dirección del nuevo prestamista

# Llamar a la función para dar de alta el prestamista
alta_prestamista(nuevo_prestamista_address)
