// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

contract GasVisibility {
    uint256 public dummy;

    function writeExternal(uint256 a) external {
        dummy = a;
    }

    function writePublic(uint256 a) public {
        dummy = a;
    }
}
