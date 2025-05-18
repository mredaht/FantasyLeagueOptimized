// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import {FantasyLeague} from "../src/FantasyLeague.sol";

contract DeployLeague is Script {
    function run() external {
        address nft = vm.envAddress("NFT_CONTRACT_ADDRESS");
        address oracle = vm.envAddress("ORACLE_ADDRESS");

        vm.startBroadcast(); // usa PRIVATE_KEY
        FantasyLeague league = new FantasyLeague(nft);

        // concede ORACLE_ROLE
        bytes32 ROLE = league.ORACLE_ROLE();
        league.grantRole(ROLE, oracle);

        // importa los jugadores ya minteados
        league.cargarJugadoresDisponibles();
        vm.stopBroadcast();

        console2.log("FantasyLeague:", address(league));
    }
}
