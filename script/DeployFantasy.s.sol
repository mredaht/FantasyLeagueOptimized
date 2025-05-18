// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/FantasyPlayerNFT.sol";
import "../src/FantasyLeague.sol";
import "./SavePlayers.s.sol"; // Importamos la librería

contract DeployFantasy is Script {
    function run() external {
        vm.startBroadcast();

        // 1. Desplegar el contrato de jugadores NFT
        FantasyPlayerNFT fantasyPlayerNFT = new FantasyPlayerNFT();
        console.log("FantasyPlayerNFT deployed at:", address(fantasyPlayerNFT));

        // 2. Obtener jugadores desde SavePlayers (sin necesidad de instanciar SavePlayers)
        SavePlayers.PlayerData[] memory players = SavePlayers.getPlayers();

        // 3. Mintear jugadores
        for (uint256 i = 0; i < 130; i++) {
            fantasyPlayerNFT.mintPlayer(msg.sender, players[i].name, players[i].team);
        }

        console.log("Todos los jugadores han sido minteados");

        // 4. Desplegar el contrato FantasyLeague
        FantasyLeague fantasyLeague = new FantasyLeague(address(fantasyPlayerNFT));
        console.log("FantasyLeague deployed at:", address(fantasyLeague));

        // 5. Cargar jugadores en la liga
        fantasyLeague.cargarJugadoresDisponibles();
        console.log("Jugadores cargados en FantasyLeague");

        vm.stopBroadcast();
    }
}
