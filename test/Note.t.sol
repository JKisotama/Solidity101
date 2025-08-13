// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/Note.sol";

contract NotesTest is Test {
    Notes notes;
    address user1 = address(0x1);
    address user2 = address(0x2);

    receive() external payable {}

    function setUp() public {
        notes = new Notes();
    }

    function testCreateNoteForMultipleUsers() public {
        vm.startPrank(user1);
        notes.createNote("A", "B");
        vm.stopPrank();
        vm.startPrank(user2);
        notes.createNote("C", "D");
        vm.stopPrank();

        Notes.Note memory note1 = notes.getNote(user1, 0);
        Notes.Note memory note2 = notes.getNote(user2, 0);

        assertEq(note1.title, "A");
        assertEq(note2.title, "C");
    }

    function testUpdateNote() public {
        vm.startPrank(user1);
        notes.createNote("Old", "Content");
        notes.updateNote(0, "New", "Updated content");
        Notes.Note memory note = notes.getNote(user1, 0);
        assertEq(note.title, "New");
        assertEq(note.content, "Updated content");
        vm.stopPrank();
    }

    function testArchiveNote() public {
        vm.startPrank(user1);
        notes.createNote("To Archive", "Some content");
        notes.archiveNote(0);
        Notes.Note memory note = notes.getNote(user1, 0);
        assertEq(uint(note.status), uint(Notes.Status.Archived));
        vm.stopPrank();
    }

    function testDeleteNote() public {
        vm.startPrank(user1);
        notes.createNote("To Delete", "Bye");
        notes.deleteNote(0);
        assertFalse(notes.noteExists(user1, 0));
        vm.expectRevert("Note does not exist");
        notes.getNote(user1, 0);
        vm.stopPrank();
    }

    function testNoteExists() public {
        vm.startPrank(user1);
        notes.createNote("A", "B");
        assertTrue(notes.noteExists(user1, 0));
        notes.deleteNote(0);
        assertFalse(notes.noteExists(user1, 0));
        vm.stopPrank();
    }

    function testRevertUpdateNonExistent() public {
        vm.startPrank(user1);
        vm.expectRevert("Note does not exist");
        notes.updateNote(42, "X", "Y");
        vm.stopPrank();
    }

    function testRevertArchiveNonExistent() public {
        vm.startPrank(user1);
        vm.expectRevert("Note does not exist");
        notes.archiveNote(42);
        vm.stopPrank();
    }

    function testRevertDeleteNonExistent() public {
        vm.startPrank(user1);
        vm.expectRevert("Note does not exist");
        notes.deleteNote(42);
        vm.stopPrank();
    }

    function testRevertUpdateArchived() public {
        vm.startPrank(user1);
        notes.createNote("A", "B");
        notes.archiveNote(0);
        vm.expectRevert("Note is archived");
        notes.updateNote(0, "C", "D");
        vm.stopPrank();
    }

    function testGasCreateNote() public {
        vm.startPrank(user1);
        uint256 gasStart = gasleft();
        notes.createNote("Gas", "Test");
        uint256 gasUsed = gasStart - gasleft();
        emit log_named_uint("Gas used for createNote (mapping-mapping)", gasUsed);
        vm.stopPrank();
    }

    function testFuzzCreateNote(address user, string memory title, string memory content) public {
        vm.startPrank(user);
        notes.createNote(title, content);
        Notes.Note memory note = notes.getNote(user, 0);
        assertEq(note.title, title);
        assertEq(note.content, content);
        vm.stopPrank();
    }

    function testCannotUpdateOthersNote() public {
        vm.startPrank(user1);
        notes.createNote("User1's Note", "Content");
        vm.stopPrank();

        vm.startPrank(user2);
        vm.expectRevert("Note does not exist");
        notes.updateNote(0, "New Title", "New Content");
        vm.stopPrank();
    }

    function testCannotDeleteOthersNote() public {
        vm.startPrank(user1);
        notes.createNote("User1's Note", "Content");
        vm.stopPrank();

        vm.startPrank(user2);
        vm.expectRevert("Note does not exist");
        notes.deleteNote(0);
        vm.stopPrank();
    }

    function testCannotArchiveOthersNote() public {
        vm.startPrank(user1);
        notes.createNote("User1's Note", "Content");
        vm.stopPrank();

        vm.startPrank(user2);
        vm.expectRevert("Note does not exist");
        notes.archiveNote(0);
        vm.stopPrank();
    }

    function testWithdraw() public {
        address deployer = address(this);
        assertEq(notes.owner(), deployer);

        // Test that a non-owner cannot withdraw
        vm.startPrank(user1);
        vm.expectRevert("UNAUTHORIZED");
        notes.withdraw();
        vm.stopPrank();
    }

    function testOwnerCanWithdraw() public {
        address deployer = address(this);
        // Test that the owner can withdraw
        vm.deal(address(notes), 1 ether);
        uint256 balanceBefore = deployer.balance;
        vm.prank(deployer);
        notes.withdraw();
        assertEq(deployer.balance, balanceBefore + 1 ether);
    }

    function testTransferOwnership() public {
        address deployer = address(this);
        address newOwner = user2;

        vm.prank(deployer);
        vm.expectEmit(true, true, true, true);
        emit Notes.OwnershipTransferred(deployer, newOwner);
        notes.transferOwnership(newOwner);

        assertEq(notes.owner(), newOwner);

        // Old owner cannot transfer ownership anymore
        vm.startPrank(deployer);
        vm.expectRevert("UNAUTHORIZED");
        notes.transferOwnership(user1);
        vm.stopPrank();
    }
}
