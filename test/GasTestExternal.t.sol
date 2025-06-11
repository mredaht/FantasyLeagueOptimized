// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../tests_extra/GasVisibility.sol";

contract GasTestExternal is Test {
    GasVisibility gasTest;

    function setUp() public {
        gasTest = new GasVisibility();
    }

    function testGasWriteExternal() public {
        gasTest.writeExternal(42);
    }

    function testGasWritePublic() public {
        gasTest.writePublic(42);
    }
}
