// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./Note.sol";
import "openzeppelin-contracts/contracts/access/AccessControl.sol";

contract NotesVault is Notes, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    uint256 public constant MAX_NOTES_PER_USER = 10;

    // We override the constructor to set up roles
    constructor() {
        // The deployer gets the ADMIN_ROLE by default
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        // The deployer also gets the MINTER_ROLE initially
        _grantRole(MINTER_ROLE, msg.sender);
    }

    // Override the createNote function
    function createNote(string calldata _title, string calldata _content) public override {
        // Check 1: Enforce RBAC
        require(hasRole(MINTER_ROLE, msg.sender), "Caller is not a minter");

        // Check 2: Add new logic (limit number of notes)
        require(nextId[msg.sender] < MAX_NOTES_PER_USER, "Max notes limit reached");

        // Call the original function from the parent contract
        super.createNote(_title, _content);
    }

    // Allow admins to grant the minter role
    function grantMinterRole(address _minter) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not an admin");
        _grantRole(MINTER_ROLE, _minter);
    }

    // Allow admins to revoke the minter role
    function revokeMinterRole(address _minter) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not an admin");
        _revokeRole(MINTER_ROLE, _minter);
    }
}
