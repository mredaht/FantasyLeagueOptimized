// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../tests_extra/GasCompareLocalVariable.sol";

contract GasCompareTest is Test {
    GasCompare gasCompare;

    function setUp() public {
        gasCompare = new GasCompare();
    }

    function testGasSumaSinCache() public view {
        gasCompare.sumaSinCache();
    }

    function testGasSumaConCache() public view {
        gasCompare.sumaConCache();
    }
}
