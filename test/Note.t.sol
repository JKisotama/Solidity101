// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/Note.sol";

contract NotesTest is Test {
    Notes notes;

    function setUp() public {
        notes = new Notes();
    }

    function testCreateNote() public {
        notes.createNote("First", "Test1");
        Notes.Note memory note = notes.getNote(0);
        assertEq(note.id, 0);
        assertEq(note.title, "First");
        assertEq(note.content, "Test1");
        assertEq(uint(note.status), uint(Notes.Status.Active));
        assertTrue(notes.noteExists(0));
    }

    function testUpdateNote() public {
        notes.createNote("Old", "Content");
        notes.updateNote(0, "New", "Updated content");
        Notes.Note memory note = notes.getNote(0);
        assertEq(note.title, "New");
        assertEq(note.content, "Updated content");
    }

    function testArchiveNote() public {
        notes.createNote("To Archive", "Some content");
        notes.archiveNote(0);
        Notes.Note memory note = notes.getNote(0);
        assertEq(uint(note.status), uint(Notes.Status.Archived));
    }

    function testDeleteNote() public {
        notes.createNote("To Delete", "Bye");
        notes.deleteNote(0);
        assertFalse(notes.noteExists(0));
        vm.expectRevert("Note does not exist");
        notes.getNote(0);
    }

    function testNoteExists() public {
        notes.createNote("A", "B");
        assertTrue(notes.noteExists(0));
        notes.deleteNote(0);
        assertFalse(notes.noteExists(0));
    }

    function testRevertUpdateNonExistent() public {
        vm.expectRevert("Note does not exist");
        notes.updateNote(42, "X", "Y");
    }

    function testRevertArchiveNonExistent() public {
        vm.expectRevert("Note does not exist");
        notes.archiveNote(42);
    }

    function testRevertDeleteNonExistent() public {
        vm.expectRevert("Note does not exist");
        notes.deleteNote(42);
    }

    function testRevertUpdateArchived() public {
        notes.createNote("A", "B");
        notes.archiveNote(0);
        vm.expectRevert("Note is archived");
        notes.updateNote(0, "C", "D");
    }

    function testGasCreateNote() public {
        uint256 gasStart = gasleft();
        notes.createNote("Gas", "Test");
        uint256 gasUsed = gasStart - gasleft();
        emit log_named_uint("Gas used for createNote", gasUsed);
    }

    function testFuzzCreateNote(string memory title, string memory content) public {
        notes.createNote(title, content);
        Notes.Note memory note = notes.getNote(0);
        assertEq(note.title, title);
        assertEq(note.content, content);
    }
}
