// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/NoteArray.sol";

contract NotesArrayTest is Test {
    NotesArray notesArray;
    address user1 = address(0x1);
    address user2 = address(0x2);

    function setUp() public {
        notesArray = new NotesArray();
    }

    function testCreateNote() public {
        vm.startPrank(user1);
        notesArray.createNote("First", "Test1");
        NotesArray.Note memory note = notesArray.getNote(0);
        assertEq(note.id, 0);
        assertEq(note.title, "First");
        assertEq(note.content, "Test1");
        assertEq(uint256(note.status), uint256(NotesArray.Status.Active));
        assertTrue(notesArray.noteExists(0));
        vm.stopPrank();
    }

    function testUpdateNote() public {
        vm.startPrank(user1);
        notesArray.createNote("Old", "Content");
        notesArray.updateNote(0, "New", "Updated content");
        NotesArray.Note memory note = notesArray.getNote(0);
        assertEq(note.title, "New");
        assertEq(note.content, "Updated content");
        vm.stopPrank();
    }

    function testArchiveNote() public {
        vm.startPrank(user1);
        notesArray.createNote("To Archive", "Some content");
        notesArray.archiveNote(0);
        NotesArray.Note memory note = notesArray.getNote(0);
        assertEq(uint256(note.status), uint256(NotesArray.Status.Archived));
        vm.stopPrank();
    }

    function testDeleteNote() public {
        vm.startPrank(user1);
        notesArray.createNote("To Delete", "Bye");
        notesArray.deleteNote(0);
        assertFalse(notesArray.noteExists(0));
        vm.expectRevert("Note does not exist");
        notesArray.getNote(0);
        vm.stopPrank();
    }

    function testNoteExists() public {
        vm.startPrank(user1);
        notesArray.createNote("A", "B");
        assertTrue(notesArray.noteExists(0));
        notesArray.deleteNote(0);
        assertFalse(notesArray.noteExists(0));
        vm.stopPrank();
    }

    function testRevertUpdateNonExistent() public {
        vm.startPrank(user1);
        vm.expectRevert("Note does not exist");
        notesArray.updateNote(42, "X", "Y");
        vm.stopPrank();
    }

    function testRevertArchiveNonExistent() public {
        vm.startPrank(user1);
        vm.expectRevert("Note does not exist");
        notesArray.archiveNote(42);
        vm.stopPrank();
    }

    function testRevertDeleteNonExistent() public {
        vm.startPrank(user1);
        vm.expectRevert("Note does not exist");
        notesArray.deleteNote(42);
        vm.stopPrank();
    }

    function testRevertUpdateArchived() public {
        vm.startPrank(user1);
        notesArray.createNote("A", "B");
        notesArray.archiveNote(0);
        vm.expectRevert("Note is archived");
        notesArray.updateNote(0, "C", "D");
        vm.stopPrank();
    }

    function testGasCreateNote() public {
        vm.startPrank(user1);
        uint256 gasStart = gasleft();
        notesArray.createNote("Gas", "Test");
        uint256 gasUsed = gasStart - gasleft();
        emit log_named_uint("Gas used for createNote (array)", gasUsed);
        vm.stopPrank();
    }

    function testGasUpdateNote() public {
        vm.startPrank(user1);
        notesArray.createNote("Old", "Content");
        uint256 gasStart = gasleft();
        notesArray.updateNote(0, "New", "Updated content");
        uint256 gasUsed = gasStart - gasleft();
        emit log_named_uint("Gas used for updateNote (array)", gasUsed);
        vm.stopPrank();
    }

    function testGasDeleteNote() public {
        vm.startPrank(user1);
        notesArray.createNote("To Delete", "Bye");
        uint256 gasStart = gasleft();
        notesArray.deleteNote(0);
        uint256 gasUsed = gasStart - gasleft();
        emit log_named_uint("Gas used for deleteNote (array)", gasUsed);
        vm.stopPrank();
    }

    function testFuzzCreateNote(string memory title, string memory content) public {
        vm.startPrank(user1);
        notesArray.createNote(title, content);
        NotesArray.Note memory note = notesArray.getNote(0);
        assertEq(note.title, title);
        assertEq(note.content, content);
        vm.stopPrank();
    }
}
