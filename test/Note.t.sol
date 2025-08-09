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
}
