// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Logger {
    event Message(address indexed sender, string message);

    function logMessage(string memory _message) public {
        // `msg.sender` is the address of the account that called this function.
        // The `emit` keyword is used to fire the event.
        emit Message(msg.sender, _message);
    }
}
