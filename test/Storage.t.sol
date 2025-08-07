// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/Storage.sol";

contract StorageTest is Test {
    Storage public storageContract;

    function setUp() public {
        storageContract = new Storage();
    }

    function testInitialValueIsZero() public view {
        uint256 val = storageContract.get();
        assertEq(val, 0);
    }

    function testSetValue() public {
        storageContract.set(42);
        uint256 val = storageContract.get();
        assertEq(val, 42);
    }
}
