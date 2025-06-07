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
    /*───────────────  CUSTOM ERRORS  ───────────────*/
    error NotEnrolled();
    error InvalidPlayerId(uint256 id);
    error PlayerAlreadyPicked(uint256 id);
    error WrongStatus(Status current, Status expected);
    error PlayerDoesNotExist(uint256 id);
    error LengthMismatch();
    error WrongEntryFee(uint256 sent, uint256 required);
    error AlreadyEnrolled();
    error TeamAlreadyPicked();
    error EmptyTeamName();
    error TeamNotRegistered();
    error NoWinnerFound();
    error TransferFailed();

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
    event JugadoresSeleccionados(
        address indexed usuario,
        string nombreEquipo,
        uint256[5] jugadores
    );
    event EstadisticasActualizadas(
        uint256 indexed jugadorId,
        uint256 nuevaPuntuacion
    );
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
        if (!UsuariosInscritos[msg.sender]) revert NotEnrolled();
        _;
    }

    modifier jugadoresDisponibles(uint256[5] memory _jugadores) {
        uint256 disponibles = jugadores.length; // ← lectura única
        uint256 len = _jugadores.length;

        for (uint256 i; i < len; ) {
            uint256 id = _jugadores[i]; // ← variable local
            if (id >= disponibles) revert InvalidPlayerId(id);
            if (jugadorElegido[id]) revert PlayerAlreadyPicked(id);
            unchecked {
                ++i;
            }
        }
        _;
    }

    modifier enEstado(Status _estado) {
        if (gameStatus != _estado) revert WrongStatus(gameStatus, _estado);
        _;
    }

    /*────────────────────── ADMIN (DEFAULT_ADMIN_ROLE) ─*/

    function iniciarJornada()
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
        enEstado(Status.JornadaSinComenzar)
    {
        gameStatus = Status.JornadaEnCurso;
        emit EstadoJornadaActualizado(gameStatus);
    }

    function finalizarJornada()
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
        enEstado(Status.JornadaEnCurso)
    {
        gameStatus = Status.JornadaFinalizada;
        emit EstadoJornadaActualizado(gameStatus);
    }

    function resetJornada()
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
        enEstado(Status.JornadaFinalizada)
    {
        uint256 teamCount = fantasyTeams.length; // ← cache
        for (uint256 i; i < teamCount; ) {
            address owner_ = fantasyTeams[i].owner; // ← lectura única
            delete equipos[owner_];
            UsuariosInscritos[owner_] = false;
            unchecked {
                ++i;
            }
        }
        delete fantasyTeams;

        uint256 playerCount = jugadores.length; // ← cache
        for (uint256 i; i < playerCount; ) {
            jugadorElegido[i] = false;
            unchecked {
                ++i;
            }
        }
        gameStatus = Status.JornadaSinComenzar;
        emit JornadaReiniciada();
        emit EstadoJornadaActualizado(gameStatus);
    }

    function cargarJugadoresDisponibles()
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        uint256 total = fantasyPlayerNFT.getNextTokenId();
        delete jugadores;

        for (uint256 i = 0; i < total; i++) {
            try fantasyPlayerNFT.ownerOf(i) returns (address) {
                // El token existe, podemos copiarlo
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
            } catch {
                // hueco: token i aún no existe; lo saltamos
            }
        }
    }

    /// @notice Concede ORACLE_ROLE a `oracle`
    function setOracle(address oracle) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(ORACLE_ROLE, oracle);
    }

    function actualizarPuntuacionesDeTodos()
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
        enEstado(Status.JornadaFinalizada)
    {
        uint256 teamCount = fantasyTeams.length;
        for (uint256 i; i < teamCount; ) {
            address owner_ = fantasyTeams[i].owner; // ← lectura única
            uint256 puntos = calcularPuntuacionEquipo(owner_);
            equipos[owner_].puntuacionEquipo = puntos;
            unchecked {
                ++i;
            }
        }
    }

    function distribuirPremio()
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
        enEstado(Status.JornadaFinalizada)
        nonReentrant
    {
        address ganador;
        uint256 maxPuntos;

        uint256 teamCount = fantasyTeams.length; // ← cache
        for (uint256 i; i < teamCount; ) {
            address owner_ = fantasyTeams[i].owner; // ← lectura única
            uint256 puntos = calcularPuntuacionEquipo(owner_);
            if (puntos > maxPuntos) {
                maxPuntos = puntos;
                ganador = owner_;
            }
            unchecked {
                ++i;
            }
        }
        if (ganador == address(0)) revert NoWinnerFound();
        uint256 premio = (address(this).balance * 80) / 100;
        (bool success, ) = payable(ganador).call{value: premio}("");
        if (!success) revert TransferFailed();
        emit PremioDistribuido(ganador, premio);
    }

    function withdraw() external onlyRole(DEFAULT_ADMIN_ROLE) nonReentrant {
        uint256 retiro = (address(this).balance * 20) / 100;
        (bool success, ) = payable(msg.sender).call{value: retiro}("");
        if (!success) revert TransferFailed();
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
        if (_tokenId >= jugadores.length) revert PlayerDoesNotExist(_tokenId);
        JugadorStruct.Jugador storage j = jugadores[_tokenId];

        j.goles = uint8(_goles);
        j.asistencias = uint8(_asistencias);
        j.paradas = uint8(_paradas);
        j.penaltisParados = uint8(_penaltisParados);
        j.despejes = uint8(_despejes);
        j.minutosJugados = uint8(_minutosJugados);
        j.porteriaCero = _porteriaCero;
        j.tarjetasAmarillas = uint8(_tarjetasAmarillas);
        j.tarjetasRojas = uint8(_tarjetasRojas);
        j.ganoPartido = _ganoPartido;

        j.puntuacion = calcularPuntuacion(j);
        emit EstadisticasActualizadas(_tokenId, uint256(j.puntuacion));
    }

    /// @notice Actualiza estadísticas de un jugador usando datos empaquetados en uint32
    function actualizarStatsPacked32(
        uint256 _tokenId,
        uint32 data
    ) external onlyRole(ORACLE_ROLE) {
        if (_tokenId >= jugadores.length) revert PlayerDoesNotExist(_tokenId);

        JugadorStruct.Jugador storage j = jugadores[_tokenId];
        _desempaquetarYActualizar(j, data);

        j.puntuacion = calcularPuntuacion(j);
        emit EstadisticasActualizadas(_tokenId, uint256(j.puntuacion));
    }

    /// @notice Actualiza múltiples jugadores con arrays de ids y datos empaquetados
    function actualizarStatsBatchPacked32(
        uint256[] calldata ids,
        uint32[] calldata datos
    ) external onlyRole(ORACLE_ROLE) {
        if (ids.length != datos.length) revert LengthMismatch();
        for (uint256 i = 0; i < ids.length; i++) {
            uint256 _tokenId = ids[i];
            uint32 data = datos[i];

            require(_tokenId < jugadores.length, "Jugador no existe");
            JugadorStruct.Jugador storage j = jugadores[_tokenId];
            _desempaquetarYActualizar(j, data);

            j.puntuacion = calcularPuntuacion(j);
            emit EstadisticasActualizadas(_tokenId, uint256(j.puntuacion));
        }
    }

    /// @dev Desempaqueta un uint32 en el struct Jugador
    function _desempaquetarYActualizar(
        JugadorStruct.Jugador storage j,
        uint32 data
    ) internal {
        j.goles = uint8(data & 0x0F);
        j.asistencias = uint8((data >> 4) & 0x0F);
        j.paradas = uint8((data >> 8) & 0x1F);
        j.penaltisParados = uint8((data >> 13) & 0x07);
        j.despejes = uint8((data >> 16) & 0x3F);
        uint8 minutosQ = uint8((data >> 22) & 0x1F);
        j.minutosJugados = minutosQ * 3;
        j.tarjetasAmarillas = uint8((data >> 27) & 0x03);
        j.tarjetasRojas = uint8((data >> 29) & 0x01);
        j.porteriaCero = ((data >> 30) & 1) == 1;
        j.ganoPartido = ((data >> 31) & 1) == 1;
    }

    /*────────────────────── PÚBLICO / VIEW ──────────────*/

    function pagarEntrada() external payable nonReentrant {
        if (msg.value != ENTRY_FEE) revert WrongEntryFee(msg.value, ENTRY_FEE);
        if (UsuariosInscritos[msg.sender]) revert AlreadyEnrolled();
        UsuariosInscritos[msg.sender] = true;
        emit EntradaPagada(msg.sender);
    }

    function seleccionarJugadores(
        string memory _nombreEquipo,
        uint256[5] memory _jugadores
    ) external onlyInscrito jugadoresDisponibles(_jugadores) {
        if (equipos[msg.sender].seleccionado) revert TeamAlreadyPicked();
        if (bytes(_nombreEquipo).length == 0) revert EmptyTeamName();
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

    function calcularPuntuacionEquipo(
        address _jugador
    ) public view returns (uint256 total) {
        if (!equipos[_jugador].seleccionado) revert TeamNotRegistered();
        uint256[5] storage ids = equipos[_jugador].jugadores; // ← storage → memoria
        uint256 len = ids.length;

        for (uint256 i; i < len; ) {
            total += jugadores[ids[i]].puntuacion; // una sola lectura por vuelta
            unchecked {
                ++i;
            }
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

    function calcularPuntuacion(
        JugadorStruct.Jugador memory j
    ) internal pure returns (uint16 p) {
        if (j.ganoPartido) p += 3;

        p += uint16(uint256(j.goles) * 4);
        p += uint16(uint256(j.asistencias) * 3);
        p += uint16(uint256(j.paradas) * 1);
        p += uint16(uint256(j.penaltisParados) * 5);
        p += uint16(uint256(j.despejes) * 1);

        if (j.minutosJugados >= 30) {
            p += (j.minutosJugados >= 60) ? 2 : 1;
        }
        if (j.porteriaCero) p += 3;

        p -= uint16(uint256(j.tarjetasAmarillas) * 1);
        p -= uint16(uint256(j.tarjetasRojas) * 3);
    }

    /*────────────────────── ERC165 ──────────────────────*/
    function supportsInterface(
        bytes4 interfaceId
    ) public view override(AccessControl) returns (bool) {
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
