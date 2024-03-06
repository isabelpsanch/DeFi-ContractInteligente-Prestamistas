pragma solidity ^0.8.0;

contract PrestamoDescentralizado {
    address public socioPrincipal;

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

    modifier soloSocioPrincipal() {
        require(msg.sender == socioPrincipal, "Solo el socio principal puede ejecutar esta función");
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
        socioPrincipal = msg.sender;
    }

    function altaPrestamista(address _nuevoPrestamista) external soloSocioPrincipal {
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
        uint tiempoLimite = tiempoSolicitud + _plazo * 1 days;

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
        require(!prestamo.aprobado, "El préstamo ya ha sido aprobado");

        prestamo.aprobado = true;

        emit PrestamoAprobado(_id);
    }

    function reembolsarPrestamo(uint _id) external soloClienteRegistrado {
        Prestamo storage prestamo = clientes[msg.sender].prestamos[_id];
        require(prestamo.aprobado, "El préstamo no ha sido aprobado");
        require(!prestamo.reembolsado, "El préstamo ya ha sido reembolsado");
        require(block.timestamp <= prestamo.tiempoLimite, "El plazo de reembolso ha expirado");

        prestamo.reembolsado = true;

        emit PrestamoReembolsado(_id);
    }

    function liquidarGarantia(address _cliente, uint _id) external soloEmpleadoPrestamista {
        Prestamo storage prestamo = clientes[_cliente].prestamos[_id];
        require(prestamo.aprobado, "El préstamo no ha sido aprobado");
        require(!prestamo.liquidado, "La garantía del préstamo ya ha sido liquidada");
        require(block.timestamp > prestamo.tiempoLimite, "El plazo de reembolso no ha expirado");

        prestamo.liquidado = true;
        clientes[_cliente].saldoGarantia -= prestamo.monto;

        emit GarantiaLiquidada(_id);
    }

    function obtenerPrestamosPorPrestatario(address _prestatario) external view returns (uint[] memory) {
        return clientes[_prestatario].prestamoIds;
    }

    function obtenerDetalleDePrestamo(address _prestatario, uint _id) external view returns (Prestamo memory) {
        return clientes[_prestatario].prestamos[_id];
    }
}
