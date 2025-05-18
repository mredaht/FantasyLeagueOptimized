// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/FantasyPlayerNFT.sol";
import "../src/FantasyLeague.sol";

contract DeployFantasyLeague is Script {
    function run() external {
        // Leer clave privada desde .env
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // Iniciar la sesión de broadcasting
        vm.startBroadcast(deployerPrivateKey);

        // Deploy del contrato de NFTs
        FantasyPlayerNFT playerNFT = new FantasyPlayerNFT();

        // Deploy de la liga con la dirección del contrato NFT
        FantasyLeague league = new FantasyLeague(address(playerNFT));

        vm.stopBroadcast();

        console.log("FantasyPlayerNFT deployed at:", address(playerNFT));
        console.log("FantasyLeague deployed at:", address(league));
    }
}
