// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import {FantasyPlayerNFT} from "../src/FantasyPlayerNFT.sol";
import {SavePlayers} from "./SavePlayers.s.sol";

contract MintBatch is Script {
    uint256 constant BATCH_SIZE = 20;

    function run() external {
        /* ─── 1. Credenciales & contratos ─────────────────────────── */
        uint256 pk = vm.envUint("PRIVATE_KEY"); // tu clave
        address nftAddr = vm.envAddress("NFT_CONTRACT_ADDRESS");
        address receiver = vm.addr(pk); // dueño de los NFT

        FantasyPlayerNFT nft = FantasyPlayerNFT(nftAddr);
        SavePlayers.PlayerData[] memory p = SavePlayers.getPlayers();

        /* ─── 2. Elegir de dónde a dónde mintear ──────────────────── */
        uint256 start = vm.envOr("START_INDEX", nft.getNextTokenId());
        uint256 end = start + BATCH_SIZE;
        if (end > p.length) end = p.length; // no pasar del array

        require(start < end, "Nada que mintear (START_INDEX >= total)");

        /* ─── 3. Mint en broadcast ────────────────────────────────── */
        vm.startBroadcast(pk);

        for (uint256 i = start; i < end; ++i) {
            // salta entradas vacías (por si amplías la lista en el futuro)
            if (bytes(p[i].name).length == 0) continue;

            try nft.mintPlayer(receiver, p[i].name, p[i].team) {
                console2.log(" Mint %s (%s) id %d", p[i].name, p[i].team, i);
            } catch Error(string memory reason) {
                console2.log(" Fallo id %d  %s", i, reason);
            } catch {
                console2.log(" Fallo id %d (error desconocido)", i);
            }
        }

        vm.stopBroadcast();
    }
}
