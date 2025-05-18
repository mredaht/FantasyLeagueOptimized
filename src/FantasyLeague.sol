// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {FantasyPlayerNFT} from "./FantasyPlayerNFT.sol";
import {JugadorStruct} from "./JugadorStruct.sol";

/// @title FantasyLeague
/// @notice Gestiona la liga fantasy, equipos y reparto de premios
contract FantasyLeague is Ownable, AccessControl, ReentrancyGuard {
    using JugadorStruct for JugadorStruct.Jugador;

    /*────────────────────── ROLES ──────────────────────*/
    bytes32 public constant ORACLE_ROLE = keccak256("ORACLE_ROLE");

    /*────────────────────── ENUMS ───────────────────────*/
    enum Status {
        JornadaSinComenzar,
        JornadaEnCurso,
        JornadaFinalizada
    }

    /*────────────────────── STRUCTS ─────────────────────*/
    struct Equipo {
        address payable owner;
        string nombre;
        uint256[5] jugadores;
        uint256 puntuacionEquipo;
        bool seleccionado;
    }

    /*────────────────────── EVENTOS ─────────────────────*/
    event EntradaPagada(address indexed usuario);
    event JugadoresSeleccionados(address indexed usuario, string nombreEquipo, uint256[5] jugadores);
    event EstadisticasActualizadas(uint256 indexed jugadorId, uint256 nuevaPuntuacion);
    event PremioDistribuido(address indexed ganador, uint256 cantidad);
    event EstadoJornadaActualizado(Status nuevoEstado);
    event JornadaReiniciada();
    event RetiroDeFondos(address indexed admin, uint256 cantidad);

    /*────────────────────── ESTADO ──────────────────────*/
    FantasyPlayerNFT public fantasyPlayerNFT;
    Status public gameStatus = Status.JornadaSinComenzar;

    JugadorStruct.Jugador[] public jugadores;
    Equipo[] private fantasyTeams;

    uint256 private constant ENTRY_FEE = 0.1 ether;

    mapping(address => Equipo) public equipos;
    mapping(address => bool) public UsuariosInscritos;
    mapping(uint256 => bool) public jugadorElegido;

    /*────────────────────── CONSTRUCTOR ─────────────────*/
    constructor(address _fantasyPlayerNFT) {
        fantasyPlayerNFT = FantasyPlayerNFT(_fantasyPlayerNFT);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /*────────────────────── MODIFIERS ───────────────────*/
    modifier onlyInscrito() {
        require(UsuariosInscritos[msg.sender], "No has pagado la entrada!!");
        _;
    }

    modifier jugadoresDisponibles(uint256[5] memory _jugadores) {
        for (uint256 i = 0; i < _jugadores.length; i++) {
            require(_jugadores[i] < jugadores.length, "ID de jugador invalido");
            require(!jugadorElegido[_jugadores[i]], "Jugador ya seleccionado");
        }
        _;
    }

    modifier enEstado(Status _estado) {
        require(gameStatus == _estado, "Estado invalido para esta accion");
        _;
    }

    /*────────────────────── ADMIN (DEFAULT_ADMIN_ROLE) ─*/

    function iniciarJornada() external onlyRole(DEFAULT_ADMIN_ROLE) enEstado(Status.JornadaSinComenzar) {
        gameStatus = Status.JornadaEnCurso;
        emit EstadoJornadaActualizado(gameStatus);
    }

    function finalizarJornada() external onlyRole(DEFAULT_ADMIN_ROLE) enEstado(Status.JornadaEnCurso) {
        gameStatus = Status.JornadaFinalizada;
        emit EstadoJornadaActualizado(gameStatus);
    }

    function resetJornada() external onlyRole(DEFAULT_ADMIN_ROLE) enEstado(Status.JornadaFinalizada) {
        for (uint256 i = 0; i < fantasyTeams.length; i++) {
            delete equipos[fantasyTeams[i].owner];
            UsuariosInscritos[fantasyTeams[i].owner] = false;
        }
        delete fantasyTeams;
        for (uint256 i = 0; i < jugadores.length; i++) {
            jugadorElegido[i] = false;
        }
        gameStatus = Status.JornadaSinComenzar;
        emit JornadaReiniciada();
        emit EstadoJornadaActualizado(gameStatus);
    }

    function cargarJugadoresDisponibles() external onlyRole(DEFAULT_ADMIN_ROLE) {
        uint256 totalJugadores = fantasyPlayerNFT.getNextTokenId();
        delete jugadores;
        for (uint256 i = 0; i < totalJugadores; i++) {
            JugadorStruct.Jugador memory p = fantasyPlayerNFT.getPlayer(i);
            jugadores.push(
                JugadorStruct.Jugador({
                    id: p.id,
                    nombre: p.nombre,
                    equipo: p.equipo,
                    puntuacion: 0,
                    goles: 0,
                    asistencias: 0,
                    paradas: 0,
                    penaltisParados: 0,
                    despejes: 0,
                    minutosJugados: 0,
                    porteriaCero: false,
                    tarjetasAmarillas: 0,
                    tarjetasRojas: 0,
                    ganoPartido: false
                })
            );
        }
    }

    /// @notice Concede ORACLE_ROLE a `oracle`
    function setOracle(address oracle) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(ORACLE_ROLE, oracle);
    }

    function actualizarPuntuacionesDeTodos() external onlyRole(DEFAULT_ADMIN_ROLE) enEstado(Status.JornadaFinalizada) {
        for (uint256 i = 0; i < fantasyTeams.length; i++) {
            address addr = fantasyTeams[i].owner;
            uint256 puntos = calcularPuntuacionEquipo(addr);
            equipos[addr].puntuacionEquipo = puntos;
        }
    }

    function distribuirPremio() external onlyRole(DEFAULT_ADMIN_ROLE) enEstado(Status.JornadaFinalizada) nonReentrant {
        address ganador;
        uint256 maxPuntos = 0;
        for (uint256 i = 0; i < fantasyTeams.length; i++) {
            address addr = fantasyTeams[i].owner;
            uint256 puntos = calcularPuntuacionEquipo(addr);
            if (puntos > maxPuntos) {
                maxPuntos = puntos;
                ganador = addr;
            }
        }
        require(ganador != address(0), "No hay ganador");
        uint256 premio = (address(this).balance * 80) / 100;
        (bool success,) = payable(ganador).call{value: premio}("");
        require(success, "Transferencia al ganador fallida");
        emit PremioDistribuido(ganador, premio);
    }

    function withdraw() external onlyRole(DEFAULT_ADMIN_ROLE) nonReentrant {
        uint256 retiro = (address(this).balance * 20) / 100;
        (bool success,) = payable(msg.sender).call{value: retiro}("");
        require(success, "Transferencia fallida");
        emit RetiroDeFondos(msg.sender, retiro);
    }

    /*────────────────────── ORACLE ──────────────────────*/

    function actualizarEstadisticas(
        uint256 _tokenId,
        uint256 _goles,
        uint256 _asistencias,
        uint256 _paradas,
        uint256 _penaltisParados,
        uint256 _despejes,
        uint256 _minutosJugados,
        bool _porteriaCero,
        uint256 _tarjetasAmarillas,
        uint256 _tarjetasRojas,
        bool _ganoPartido
    ) external onlyRole(ORACLE_ROLE) {
        require(_tokenId < jugadores.length, "Jugador no existe");
        JugadorStruct.Jugador storage jugador = jugadores[_tokenId];
        jugador.goles = _goles;
        jugador.asistencias = _asistencias;
        jugador.paradas = _paradas;
        jugador.penaltisParados = _penaltisParados;
        jugador.despejes = _despejes;
        jugador.minutosJugados = _minutosJugados;
        jugador.porteriaCero = _porteriaCero;
        jugador.tarjetasAmarillas = _tarjetasAmarillas;
        jugador.tarjetasRojas = _tarjetasRojas;
        jugador.ganoPartido = _ganoPartido;
        jugador.puntuacion = calcularPuntuacion(jugador);
        emit EstadisticasActualizadas(_tokenId, jugador.puntuacion);
    }

    /*────────────────────── PÚBLICO / VIEW ──────────────*/

    function pagarEntrada() external payable nonReentrant {
        require(msg.value == ENTRY_FEE, "La entrada cuesta 0.1 ether");
        require(!UsuariosInscritos[msg.sender], "Ya estas inscrito en la jornada");
        UsuariosInscritos[msg.sender] = true;
        emit EntradaPagada(msg.sender);
    }

    function seleccionarJugadores(string memory _nombreEquipo, uint256[5] memory _jugadores)
        external
        onlyInscrito
        jugadoresDisponibles(_jugadores)
    {
        require(!equipos[msg.sender].seleccionado, "Ya seleccionaste tus jugadores");
        require(bytes(_nombreEquipo).length > 0, "El nombre del equipo no puede estar vacio");
        for (uint256 i = 0; i < _jugadores.length; i++) {
            jugadorElegido[_jugadores[i]] = true;
        }
        equipos[msg.sender] = Equipo({
            owner: payable(msg.sender),
            nombre: _nombreEquipo,
            jugadores: _jugadores,
            puntuacionEquipo: 0,
            seleccionado: true
        });
        fantasyTeams.push(equipos[msg.sender]);
        emit JugadoresSeleccionados(msg.sender, _nombreEquipo, _jugadores);
    }

    function calcularPuntuacionEquipo(address _jugador) public view returns (uint256 total) {
        require(equipos[_jugador].seleccionado, "El jugador no tiene equipo");
        uint256[5] memory ids = equipos[_jugador].jugadores;
        for (uint256 i = 0; i < ids.length; i++) {
            total += jugadores[ids[i]].puntuacion;
        }
    }

    function getEquipo() external view returns (Equipo memory) {
        require(equipos[msg.sender].seleccionado, "No has registrado equipo");
        return equipos[msg.sender];
    }

    function getEquiposInscritos() external view returns (Equipo[] memory) {
        return fantasyTeams;
    }

    function getEstadoActual() external view returns (Status) {
        return gameStatus;
    }

    /*────────────────────── UTILIDADES ──────────────────*/

    function calcularPuntuacion(JugadorStruct.Jugador memory jugador) internal pure returns (uint256 puntuacion) {
        if (jugador.ganoPartido) puntuacion += 3;
        puntuacion += jugador.goles * 4;
        puntuacion += jugador.asistencias * 3;
        puntuacion += jugador.paradas * 1;
        puntuacion += jugador.penaltisParados * 5;
        puntuacion += jugador.despejes * 1;
        if (jugador.minutosJugados >= 30) {
            puntuacion += (jugador.minutosJugados >= 60) ? 2 : 1;
        }
        if (jugador.porteriaCero) puntuacion += 3;
        puntuacion -= jugador.tarjetasAmarillas * 1;
        puntuacion -= jugador.tarjetasRojas * 3;
    }

    /*────────────────────── ERC165 ──────────────────────*/
    function supportsInterface(bytes4 interfaceId) public view override(AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /*────────────────────── SEGURIDAD ───────────────────*/
    receive() external payable {
        revert("No se aceptan pagos directos");
    }

    fallback() external payable {
        revert("Funcion no reconocida");
    }
}
