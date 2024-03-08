// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PrestamoDescentralizado {
    address public administrador;

    struct Prestamo {
        uint id;
        address prestatario;
        uint monto;
        uint plazo;
        uint tiempoSolicitud;
        uint tiempoLimite;
        bool aprobado;
        bool reembolsado;
        bool liquidado;
    }

    struct Cliente {
        bool activado;
        uint saldoGarantia;
        mapping(uint => Prestamo) prestamos;
        uint[] prestamoIds;
    }

    mapping(address => Cliente) public clientes;
    mapping(address => bool) public empleadosPrestamista;

    event SolicitudPrestamo(uint indexed id, address indexed prestatario, uint monto, uint plazo);
    event PrestamoAprobado(uint indexed id);
    event PrestamoReembolsado(uint indexed id);
    event GarantiaLiquidada(uint indexed id);

    modifier soloAdministrador() {
        require(msg.sender == administrador, "Solo el administrador puede ejecutar esta funcion");
        _;
    }

    modifier soloEmpleadoPrestamista() {
        require(empleadosPrestamista[msg.sender], "Requiere que el remitente sea un empleado con el rol de prestamista");
        _;
    }

    modifier soloClienteRegistrado() {
        require(clientes[msg.sender].activado, "Requiere que el remitente sea un cliente registrado y activo");
        _;
    }

    constructor() {
        administrador = msg.sender;
    }

    function altaPrestamista(address _nuevoPrestamista) external soloAdministrador {
        empleadosPrestamista[_nuevoPrestamista] = true;
    }

    function altaCliente(address _nuevoCliente) external soloEmpleadoPrestamista {
        clientes[_nuevoCliente].activado = true;
    }

    function depositarGarantia() external soloClienteRegistrado payable {
        clientes[msg.sender].saldoGarantia += msg.value;
    }

    function solicitarPrestamo(uint _monto, uint _plazo) external soloClienteRegistrado {
        uint tiempoSolicitud = block.timestamp;
        uint tiempoLimite = tiempoSolicitud + _plazo;

        Prestamo memory nuevoPrestamo = Prestamo({
            id: clientes[msg.sender].prestamoIds.length,
            prestatario: msg.sender,
            monto: _monto,
            plazo: _plazo,
            tiempoSolicitud: tiempoSolicitud,
            tiempoLimite: tiempoLimite,
            aprobado: false,
            reembolsado: false,
            liquidado: false
        });

        clientes[msg.sender].prestamos[nuevoPrestamo.id] = nuevoPrestamo;
        clientes[msg.sender].prestamoIds.push(nuevoPrestamo.id);

        emit SolicitudPrestamo(nuevoPrestamo.id, msg.sender, _monto, _plazo);
    }

    function aprobarPrestamo(address _cliente, uint _id) external soloEmpleadoPrestamista {
        Prestamo storage prestamo = clientes[_cliente].prestamos[_id];
        require(!prestamo.aprobado, "El prestamo ya ha sido aprobado");

        prestamo.aprobado = true;

        emit PrestamoAprobado(_id);
    }

    function reembolsarPrestamo(uint _id) external soloClienteRegistrado {
        Prestamo storage prestamo = clientes[msg.sender].prestamos[_id];
        require(prestamo.aprobado, "El prestamo no ha sido aprobado");
        require(!prestamo.reembolsado, "El prestamo ya ha sido reembolsado");
        require(block.timestamp <= prestamo.tiempoLimite, "El plazo de reembolso ha expirado");

        // Transferir garantía al administrador
        uint garantiaTransferida = prestamo.monto;
        require(clientes[msg.sender].saldoGarantia >= garantiaTransferida, "Saldo de garantia insuficiente");
        clientes[msg.sender].saldoGarantia -= garantiaTransferida;
        payable(administrador).transfer(garantiaTransferida);

        prestamo.reembolsado = true;

        emit PrestamoReembolsado(_id);
    }

    function liquidarGarantia(address _cliente, uint _id) external soloEmpleadoPrestamista {
        Prestamo storage prestamo = clientes[_cliente].prestamos[_id];
        require(prestamo.aprobado, "El prestamo no ha sido aprobado");
        require(!prestamo.liquidado, "La garantia del prestamo ya ha sido liquidada");
        require(block.timestamp > prestamo.tiempoLimite, "El plazo de reembolso no ha expirado");
        require(!prestamo.reembolsado, "El prestamo no ha sido reembolsado");

        // Transferir garantía al prestamista
        uint garantiaTransferida = prestamo.monto;
        require(clientes[_cliente].saldoGarantia >= garantiaTransferida, "Saldo de garantia insuficiente");
        clientes[_cliente].saldoGarantia -= garantiaTransferida;
        prestamo.liquidado = true;

        emit GarantiaLiquidada(_id);
    }
}

//Comprobado en Remix.