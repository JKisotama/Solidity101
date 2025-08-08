// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/Note.sol";

contract NoteManagerTest is Test {
    NoteManager noteManager;

    address test1 = address(0x123);
    address test2 = address(0x456);

    function setUp() public {
        noteManager = new NoteManager();
    }

    function testCreateAndReadNote() public {
        vm.prank(test1);
        noteManager.createNote("Hello World");

        NoteManager.Note memory note = noteManager.getNote(1);
        assertEq(note.id, 1);
        assertEq(note.content, "Hello World");
        assertEq(note.author, test1);
    }

    function testUpdateNote() public {
        vm.prank(test1);
        noteManager.createNote("Old Content");

        vm.prank(test1);
        noteManager.updateNote(1, "New Content");

        NoteManager.Note memory note = noteManager.getNote(1);
        assertEq(note.content, "New Content");
    }

    function testDeleteNote() public {
        vm.prank(test1);
        noteManager.createNote("Temp");

        vm.prank(test1);
        noteManager.deleteNote(1);

        vm.expectRevert(bytes("Note not found"));
        noteManager.getNote(1);
    }
    
    function testCannotUpdateOthersNote() public {
        vm.prank(test1);
        noteManager.createNote("Test1 Note");

        vm.prank(test2);
        vm.expectRevert(bytes("Not your note"));
        noteManager.updateNote(1, "Test233 tries");
    }
}
