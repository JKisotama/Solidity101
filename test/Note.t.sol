// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/Note.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";

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
        assertEq(note1.id, 0);
        assertEq(note2.id, 0);
        assertEq(uint256(note1.status), uint256(Notes.Status.Active));
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
        assertEq(uint256(note.status), uint256(Notes.Status.Archived));
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
        emit log_named_uint("Gas used for createNote (optimized)", gasUsed);
        vm.stopPrank();
    }

    function testGasUpdateNote() public {
        vm.startPrank(user1);
        notes.createNote("Old", "Content");
        uint256 gasStart = gasleft();
        notes.updateNote(0, "New", "Updated content");
        uint256 gasUsed = gasStart - gasleft();
        emit log_named_uint("Gas used for updateNote (optimized)", gasUsed);
        vm.stopPrank();
    }

    function testGasDeleteNote() public {
        vm.startPrank(user1);
        notes.createNote("To Delete", "Bye");
        uint256 gasStart = gasleft();
        notes.deleteNote(0);
        uint256 gasUsed = gasStart - gasleft();
        emit log_named_uint("Gas used for deleteNote (optimized)", gasUsed);
        vm.stopPrank();
    }

    function testGasBatchCreateNotes() public {
        vm.startPrank(user1);
        string[] memory titles = new string[](3);
        string[] memory contents = new string[](3);
        titles[0] = "Title1";
        titles[1] = "Title2";
        titles[2] = "Title3";
        contents[0] = "Content1";
        contents[1] = "Content2";
        contents[2] = "Content3";

        uint256 gasStart = gasleft();
        notes.createMultipleNotes(titles, contents);
        uint256 gasUsed = gasStart - gasleft();
        emit log_named_uint("Gas used for batch create (3 notes)", gasUsed);
        vm.stopPrank();
    }
    // viem

    function testFuzzCreateNote(string memory title, string memory content) public {
        vm.startPrank(user1);
        notes.createNote(title, content);
        Notes.Note memory note = notes.getNote(user1, 0);
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
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, user1));
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
        notes.transferOwnership(newOwner);

        assertEq(notes.owner(), newOwner);

        // Old owner cannot transfer ownership anymore
        vm.startPrank(deployer);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, deployer));
        notes.transferOwnership(user1);
        vm.stopPrank();
    }

    function testGetBalance() public {
        vm.deal(address(notes), 2 ether);
        uint256 balance = notes.getBalance();
        assertEq(balance, 2 ether);
    }

    function testBatchOperations() public {
        vm.startPrank(user1);

        string[] memory titles = new string[](2);
        string[] memory contents = new string[](2);
        titles[0] = "Batch Title 1";
        titles[1] = "Batch Title 2";
        contents[0] = "Batch Content 1";
        contents[1] = "Batch Content 2";

        notes.createMultipleNotes(titles, contents);

        Notes.Note memory note1 = notes.getNote(user1, 0);
        Notes.Note memory note2 = notes.getNote(user1, 1);

        assertEq(note1.title, "Batch Title 1");
        assertEq(note2.title, "Batch Title 2");
        assertEq(note1.id, 0);
        assertEq(note2.id, 1);

        vm.stopPrank();
    }
}
