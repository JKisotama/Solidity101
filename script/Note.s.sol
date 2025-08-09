// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/Note.sol";

contract NotesScript is Script {
    function run() external {
        vm.startBroadcast();

        Notes notes = new Notes();
        console.log("Deployed at:", address(notes));

        notes.createNote("First Note", "This is my first note");
        notes.createNote("Second Note", "Hello blockchain");

        Notes.Note[] memory allNotes = notes.getAllNotes();
        console.log("Total notes:", allNotes.length);

        vm.stopBroadcast();
    }
}
