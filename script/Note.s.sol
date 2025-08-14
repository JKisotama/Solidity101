// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/Note.sol";

contract DeployNotes is Script {
    function run() external returns (Notes) {
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
        address user = msg.sender;

        console.log("Interacting with Notes contract at:", contractAddress);
        console.log("Using user account:", user);

        Notes notes = Notes(contractAddress);

        vm.startBroadcast();

        console.log("Creating a new note...");
        notes.createNote("My First Note", "This is the content of my first note.");

        Notes.Note memory myNote = notes.getNote(user, 0);
        console.log("Retrieved Note 0 Title:", myNote.title);
        console.log("Note ID:", myNote.id);
        console.log("Note Timestamp:", myNote.timestamp);

        console.log("Updating the note...");
        notes.updateNote(0, "My Updated Note", "The content has been updated.");

        myNote = notes.getNote(user, 0);
        console.log("Retrieved Updated Note 0 Title:", myNote.title);

        console.log("Creating multiple notes in batch...");
        string[] memory titles = new string[](2);
        string[] memory contents = new string[](2);
        titles[0] = "Batch Note 1";
        titles[1] = "Batch Note 2";
        contents[0] = "Batch content 1";
        contents[1] = "Batch content 2";

        notes.createMultipleNotes(titles, contents);

        Notes.Note memory batchNote1 = notes.getNote(user, 1);
        Notes.Note memory batchNote2 = notes.getNote(user, 2);
        console.log("Batch Note 1 Title:", batchNote1.title);
        console.log("Batch Note 2 Title:", batchNote2.title);

        console.log("Archiving note 0...");
        notes.archiveNote(0);
        myNote = notes.getNote(user, 0);
        console.log("Note 0 status after archive:", uint256(myNote.status));

        console.log("Deleting note 1...");
        notes.deleteNote(1);
        bool exists = notes.noteExists(user, 1);
        console.log("Note 1 exists after delete:", exists);

        console.log("Next note ID for user:", notes.nextNoteId(user));

        vm.stopBroadcast();
    }
}
