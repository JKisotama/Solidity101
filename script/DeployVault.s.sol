// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/NotesVault.sol";

contract DeployVault is Script {
    function run() external returns (NotesVault) {
        // Address to be granted the MINTER_ROLE
        address minterAddress = vm.envAddress("MINTER_ADDRESS");

        vm.startBroadcast();
        NotesVault notesVault = new NotesVault();
        notesVault.grantMinterRole(minterAddress);
        vm.stopBroadcast();

        return notesVault;
    }
}
