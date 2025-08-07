// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/Storage.sol";

contract StorageScript is Script {
    function run() external {
        // Chạy lệnh trong môi trường local (không deploy lên mạng)
        vm.startBroadcast();

        Storage s = new Storage();
        s.set(99);
        uint256 result = s.get();

        console.log("Stored value:", result); // → 99

        vm.stopBroadcast();
    }
}
