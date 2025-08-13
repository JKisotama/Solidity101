// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/Note.sol";

contract DeployNotes is Script {
    function run() external returns (Notes) {
        // The --private-key flag in the command sets msg.sender for the broadcast.
        vm.startBroadcast();

        Notes notes = new Notes();
        console.log("Notes contract deployed to:", address(notes));
        console.log("Owner (deployer) is:", notes.owner());

        vm.stopBroadcast();
        return notes;
    }
}

contract InteractWithNotes is Script {
    function run(address contractAddress) external {
        // The --private-key flag in the command sets msg.sender for the broadcast.
        address user = msg.sender;
        
        console.log("Interacting with Notes contract at:", contractAddress);
        console.log("Using user account:", user);

        Notes notes = Notes(contractAddress);

        // Bắt đầu tương tác với tư cách là 'user'
        vm.startBroadcast();

        console.log("Creating a new note...");
        notes.createNote("My First Note", "This is the content of my first note.");
        
        Notes.Note memory myNote = notes.getNote(user, 0);
        console.log("Retrieved Note 0 Title:", myNote.title);

        console.log("Updating the note...");
        notes.updateNote(0, "My Updated Note", "The content has been updated.");

        myNote = notes.getNote(user, 0);
        console.log("Retrieved Updated Note 0 Title:", myNote.title);

        vm.stopBroadcast();
    }
}
