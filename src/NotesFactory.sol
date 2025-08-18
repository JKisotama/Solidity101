// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./Note.sol";

contract NotesFactory {
    event NotesContractCreated(address indexed owner, address indexed notesAddress);

    address[] public deployedNotes;

    function createNoteContract() public {
        Notes newNotesContract = new Notes();
        newNotesContract.transferOwnership(msg.sender);
        deployedNotes.push(address(newNotesContract));
        emit NotesContractCreated(msg.sender, address(newNotesContract));
    }

    function getDeployedNotes() public view returns (address[] memory) {
        return deployedNotes;
    }
}
