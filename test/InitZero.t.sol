// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../tests_extra/InitZero.sol";

contract InitZeroTest is Test {
    InitZero initZero;

    function setUp() public {
        initZero = new InitZero();
    }

    function testGasExplicitInit() public {
        initZero.explicitInit();
    }

    function testGasImplicitInit() public {
        initZero.implicitInit();
    }
}
