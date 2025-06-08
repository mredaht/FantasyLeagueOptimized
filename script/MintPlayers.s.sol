// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/FantasyPlayerNFT.sol"; // ajusta el path si es distinto
import "./SavePlayers.s.sol"; // la librería con los jugadores

contract MintPlayers is Script {
    function run() external {
        /*─────────────────── Configuración via env ───────────────────*/
        uint256 pk = vm.envUint("PRIVATE_KEY"); // clave del owner del NFT
        address nftAddr = vm.envAddress("NFT_CONTRACT_ADDRESS"); // contrato FantasyPlayerNFT
        address receiver = vm.envAddress("RECEIVER"); // quién recibe los nuevos NFTs

        /*─────────────────── Preparación ─────────────────────────────*/
        FantasyPlayerNFT nft = FantasyPlayerNFT(nftAddr);
        SavePlayers.PlayerData[] memory players = SavePlayers.getPlayers();
        uint256 minted = nft.getNextTokenId();

        console2.log("Ya hay creados :", minted);
        console2.log("Total objetivo :", players.length);

        require(minted <= players.length, "Hay mas mintados que en la lista");

        /*─────────────────── Mint de los que faltan ─────────────────*/
        vm.startBroadcast(pk);

        for (uint256 i = 79; i < 130; i++) {
            nft.mintPlayer(receiver, players[i].name, players[i].team);
            console2.log("Mint", i, players[i].name, players[i].team);
        }

        vm.stopBroadcast();

        console2.log(
            " Proceso completado. NFTs totales:",
            nft.getNextTokenId()
        );
    }
}
