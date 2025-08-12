// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/Note.sol";

contract NotesScript is Script {
    function run() external {
        vm.startBroadcast();
        Notes notes = new Notes();
        console.log("Deployed at:", address(notes));
        vm.stopBroadcast();

        address user1 = address(0x1);
        address user2 = address(0x2);

        // User 1
        vm.startBroadcast(user1);
        notes.createNote("User1 Note", "Content1");
        notes.createNote("User1 Note2", "Content2");
        notes.updateNote(0, "User1 Note Updated", "Updated content");
        notes.archiveNote(1);
        notes.deleteNote(0);
        vm.stopBroadcast();

        // User 2
        vm.startBroadcast(user2);
        notes.createNote("User2 Note", "Content3");
        vm.stopBroadcast();

        bool exists1_0 = notes.noteExists(user1, 0);
        bool exists1_1 = notes.noteExists(user1, 1);
        bool exists2_0 = notes.noteExists(user2, 0);
        console.log("User1 Note 0 exists:", exists1_0);
        console.log("User1 Note 1 exists:", exists1_1);
        console.log("User2 Note 0 exists:", exists2_0);
    }
}
