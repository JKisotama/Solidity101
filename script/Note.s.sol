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
        notes.updateNote(0, "First Note Updated", "Updated content");
        notes.archiveNote(1);
        notes.deleteNote(0);

        bool exists0 = notes.noteExists(0);
        bool exists1 = notes.noteExists(1);
        console.log("Note 0 exists:", exists0);
        console.log("Note 1 exists:", exists1);

        vm.stopBroadcast();
    }
}
