// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract GasCompare {
    uint256[] public valores;

    constructor() {
        for (uint256 i = 0; i < 100; i++) {
            valores.push(i);
        }
    }

    // No optimizada: accede a valores.length en cada iteración
    function sumaSinCache() external view returns (uint256 total) {
        for (uint256 i = 0; i < valores.length; i++) {
            total += valores[i];
        }
    }

    // Optimizada: cachea valores.length una vez
    function sumaConCache() external view returns (uint256 total) {
        uint256 len = valores.length;
        for (uint256 i = 0; i < len; i++) {
            total += valores[i];
        }
    }
}
