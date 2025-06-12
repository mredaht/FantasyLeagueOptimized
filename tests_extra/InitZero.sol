// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

contract InitZero {
    function explicitInit() external pure returns (uint256) {
        uint256 x = 0; // inicialización explícita
        return x + 1;
    }

    function implicitInit() external pure returns (uint256) {
        uint256 x; // por defecto es 0
        return x + 1;
    }
}
