// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/FantasyLeague.sol";
import "../src/FantasyPlayerNFT.sol";
import "openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";

contract FantasyLeagueTest is Test, IERC721Receiver {
    FantasyLeague public fantasyLeague;
    FantasyPlayerNFT public playerNFT;

    address public admin = address(this);
    address public user1 = vm.addr(1);
    address public user2 = vm.addr(2);

    function setUp() public {
        playerNFT = new FantasyPlayerNFT();
        fantasyLeague = new FantasyLeague(address(playerNFT));

        // Mintear 10 jugadores
        for (uint256 i = 0; i < 10; i++) {
            playerNFT.mintPlayer(admin, string(abi.encodePacked("Jugador", vm.toString(i))), "Equipo A");
        }

        // Cargar jugadores en el contrato principal
        fantasyLeague.cargarJugadoresDisponibles();
    }

    function testFlowCompleto() public {
        // --- PAGAR ENTRADA ---
        vm.deal(user1, 1 ether);
        vm.prank(user1);
        fantasyLeague.pagarEntrada{value: 0.1 ether}();

        vm.deal(user2, 1 ether);
        vm.prank(user2);
        fantasyLeague.pagarEntrada{value: 0.1 ether}();

        // --- SELECCIONAR JUGADORES ---
        uint256[5] memory ids1 = [uint256(0), 1, 2, 3, 4];
        vm.prank(user1);
        fantasyLeague.seleccionarJugadores("EquipoUser1", ids1);

        uint256[5] memory ids2 = [uint256(5), 6, 7, 8, 9];
        vm.prank(user2);
        fantasyLeague.seleccionarJugadores("EquipoUser2", ids2);

        // --- INICIAR JORNADA ---
        fantasyLeague.iniciarJornada();

        // --- FINALIZAR JORNADA Y CARGAR STATS ---
        fantasyLeague.finalizarJornada();

        // Cargar estadísticas para jugadores de user1 (mejor puntuación)
        for (uint256 i = 0; i < 5; i++) {
            fantasyLeague.actualizarEstadisticas(i, 1, 1, 0, 0, 0, 60, false, 0, 0, true);
        }

        // Cargar estadísticas para jugadores de user2 (puntuación baja)
        for (uint256 i = 5; i < 10; i++) {
            fantasyLeague.actualizarEstadisticas(i, 0, 0, 0, 0, 0, 60, false, 1, 0, false);
        }

        // Actualizar puntuaciones de todos
        fantasyLeague.actualizarPuntuacionesDeTodos();

        // --- DISTRIBUIR PREMIO ---
        uint256 balanceAntes = user1.balance;
        fantasyLeague.distribuirPremio();
        uint256 balanceDespues = user1.balance;

        // Comprobar que user1 recibió el 80% de 0.2 ether
        assertEq(balanceDespues - balanceAntes, 0.16 ether);
    }

    function onERC721Received(address, address, uint256, bytes calldata) external pure override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}
