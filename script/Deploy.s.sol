// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/NotesFactory.sol";

contract Deploy is Script {
    function run() external returns (NotesFactory) {
        vm.startBroadcast();
        NotesFactory notesFactory = new NotesFactory();
        vm.stopBroadcast();
        return notesFactory;
    }
}
