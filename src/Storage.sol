// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Storage {
    uint256 private value;

    // Set a new value
    function set(uint256 _value) public {
        value = _value;
    }

    // Get the current value
    function get() public view returns (uint256) {
        return value;
    }
}
