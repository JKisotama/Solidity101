// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/NotesFactory.sol";
import "../src/Note.sol";

contract NotesFactoryTest is Test {
    NotesFactory notesFactory;
    address user1 = address(0x1);

    function setUp() public {
        notesFactory = new NotesFactory();
    }

    function testCreateNoteContract() public {
        vm.startPrank(user1);
        notesFactory.createNoteContract();
        vm.stopPrank();

        address[] memory deployedNotes = notesFactory.getDeployedNotes();
        assertEq(deployedNotes.length, 1);

        Notes notesContract = Notes(deployedNotes[0]);
        assertEq(notesContract.owner(), user1);
    }

    function testGetDeployedNotes() public {
        vm.startPrank(user1);
        notesFactory.createNoteContract();
        notesFactory.createNoteContract();
        vm.stopPrank();

        address[] memory deployedNotes = notesFactory.getDeployedNotes();
        assertEq(deployedNotes.length, 2);
    }
}
