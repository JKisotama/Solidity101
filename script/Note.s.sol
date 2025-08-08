// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/Note.sol";

contract NoteScript is Script {
    function run() external {
        vm.startBroadcast();

        NoteManager noteManager = new NoteManager();
        noteManager.createNote("My first note");
        noteManager.createNote("My second note");

        vm.stopBroadcast();
    }
}
