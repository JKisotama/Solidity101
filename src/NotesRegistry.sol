// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface INotesFactory {
    function getDeployedNotes() external view returns (address[] memory);
}
// ABI interaction with NotesFactory
contract NotesRegistry {
    INotesFactory public notesFactory;
    address[] public allNotesContracts;

    constructor(address _factoryAddress) {
        notesFactory = INotesFactory(_factoryAddress);
    }

    function updateRegistry() public {
        allNotesContracts = notesFactory.getDeployedNotes();
    }

    function getRegistry() public view returns (address[] memory) {
        return allNotesContracts;
    }
}
