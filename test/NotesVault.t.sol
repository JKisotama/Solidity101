// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/NotesVault.sol";

contract NotesVaultTest is Test {
    NotesVault notesVault;
    address admin = address(this);
    address minter = address(0x1);
    address nonMinter = address(0x2);
    address anotherUser = address(0x3);

    function setUp() public {
        notesVault = new NotesVault();
        notesVault.grantMinterRole(minter);
    }

    // Test 1: Test the override logic - note limit
    function testCannotCreateMoreThanMaxNotes() public {
        vm.startPrank(minter);
        for (uint256 i = 0; i < notesVault.MAX_NOTES_PER_USER(); i++) {
            notesVault.createNote("Title", "Content");
        }
        vm.expectRevert("Max notes limit reached");
        notesVault.createNote("One too many", "Content");
        vm.stopPrank();
    }

    // Test 2: Test RBAC - minter can create notes
    function testMinterCanCreateNote() public {
        vm.startPrank(minter);
        notesVault.createNote("Minter Note", "Content");
        Notes.Note memory note = notesVault.getNote(minter, 0);
        assertEq(note.title, "Minter Note");
        vm.stopPrank();
    }

    // Test 3: Test RBAC - non-minter cannot create notes
    function testNonMinterCannotCreateNote() public {
        vm.startPrank(nonMinter);
        vm.expectRevert("Caller is not a minter");
        notesVault.createNote("Should Fail", "Content");
        vm.stopPrank();
    }

    // Test 4: Test RBAC - admin can grant minter role
    function testAdminCanGrantMinterRole() public {
        vm.prank(admin);
        notesVault.grantMinterRole(anotherUser);
        assertTrue(notesVault.hasRole(notesVault.MINTER_ROLE(), anotherUser));
    }

    // Test 5: Test RBAC - admin can revoke minter role
    function testAdminCanRevokeMinterRole() public {
        // First, grant the role to make sure it's there
        vm.prank(admin);
        notesVault.grantMinterRole(anotherUser);
        assertTrue(notesVault.hasRole(notesVault.MINTER_ROLE(), anotherUser));

        // Then, revoke it
        vm.prank(admin);
        notesVault.revokeMinterRole(anotherUser);
        assertFalse(notesVault.hasRole(notesVault.MINTER_ROLE(), anotherUser));
    }

    // Test 6: Test RBAC - non-admin cannot grant roles
    function testNonAdminCannotGrantRole() public {
        vm.startPrank(nonMinter);
        vm.expectRevert("Caller is not an admin");
        notesVault.grantMinterRole(anotherUser);
        vm.stopPrank();
    }
}
