// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {ERC1967Proxy} from "lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {BoxV1} from "src/uups/BoxV1.sol";

contract DeployBox is Script {
    function run() external returns (address) {
        address deployer = msg.sender;

        vm.startBroadcast();

        BoxV1 boxV1 = new BoxV1();
        console.log("BoxV1 implementation deployed at:", address(boxV1));

        bytes memory initData = abi.encodeWithSignature("initialize(address)", deployer);

        ERC1967Proxy proxy = new ERC1967Proxy(address(boxV1), initData);
        console.log("Proxy deployed at:", address(proxy));

        vm.stopBroadcast();

        return address(proxy);
    }
}
