// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/NotesFactory.sol";
import "../src/NotesRegistry.sol";

contract NotesRegistryTest is Test {
    NotesFactory notesFactory;
    NotesRegistry notesRegistry;
    address user1 = address(0x1);

    function setUp() public {
        notesFactory = new NotesFactory();
        notesRegistry = new NotesRegistry(address(notesFactory));
    }

    function testUpdateRegistry() public {
        vm.startPrank(user1);
        notesFactory.createNoteContract();
        notesFactory.createNoteContract();
        vm.stopPrank();

        notesRegistry.updateRegistry();

        address[] memory deployedNotesFromFactory = notesFactory.getDeployedNotes();
        address[] memory deployedNotesFromRegistry = notesRegistry.getRegistry();

        assertEq(deployedNotesFromRegistry.length, 2);
        assertEq(deployedNotesFromRegistry.length, deployedNotesFromFactory.length);
        assertEq(deployedNotesFromRegistry[0], deployedNotesFromFactory[0]);
        assertEq(deployedNotesFromRegistry[1], deployedNotesFromFactory[1]);
    }
}
