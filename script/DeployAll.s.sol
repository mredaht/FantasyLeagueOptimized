// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/FantasyPlayerNFT.sol";
import "../src/FantasyLeague.sol";

contract DeployAll is Script {
    function run()
        external
        returns (FantasyPlayerNFT nft, FantasyLeague league)
    {
        uint256 pk = vm.envUint("PRIVATE_KEY"); // tu clave

        vm.startBroadcast(pk);

        nft = new FantasyPlayerNFT();
        league = new FantasyLeague(address(nft));

        // Transferir la propiedad del NFT al mismo deployer (opcional)
        nft.transferOwnership(vm.addr(pk));

        vm.stopBroadcast();

        console2.log("NFT    :", address(nft));
        console2.log("League :", address(league));
    }
}
