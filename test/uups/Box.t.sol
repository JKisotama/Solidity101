// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {ERC1967Proxy} from "lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {BoxV1} from "src/uups/BoxV1.sol";
import {BoxV2} from "src/uups/BoxV2.sol";

interface IUUPS {
    function upgradeTo(address newImplementation) external;
}

contract BoxTest is Test {
    BoxV1 public boxV1;
    BoxV2 public boxV2;
    address public proxyAddress;

    function setUp() public {
        // Deploy the first implementation contract
        boxV1 = new BoxV1();

        // Deploy the proxy and link it to the first implementation
        // The `data` field in the proxy constructor is a call to the `initialize` function
        proxyAddress =
            address(new ERC1967Proxy(address(boxV1), abi.encodeWithSignature("initialize(address)", address(this))));
    }

    function test_InitialState() public {
        // Interact with the contract through the proxy
        BoxV1 proxyBox = BoxV1(proxyAddress);
        assertEq(proxyBox.owner(), address(this));
        assertEq(proxyBox.retrieve(), 0);
    }

    function test_StoreAndRetrieveV1() public {
        BoxV1 proxyBox = BoxV1(proxyAddress);
        proxyBox.store(42);
        assertEq(proxyBox.retrieve(), 42);
    }

    // TODO: This test currently fails with a revert without a reason string.
    // The issue is likely related to the testing environment's handling of `delegatecall`
    // in combination with the `onlyOwner` modifier from `OwnableUpgradeable` inside the UUPS `_authorizeUpgrade` function.
    // When `upgradeTo` is called, the `onlyOwner` check reverts.
    // A potential solution to investigate is using a different way to assert the caller's identity
    // or exploring advanced Foundry cheatcodes for this specific proxy testing scenario.
    function test_UpgradeToV2() public {
        // 1. Store a value in V1
        BoxV1 proxyBoxV1 = BoxV1(proxyAddress);
        proxyBoxV1.store(100);
        assertEq(proxyBoxV1.retrieve(), 100);

        // 2. Deploy the new implementation (V2)
        boxV2 = new BoxV2();

        // 3. Upgrade the proxy to point to V2
        IUUPS(proxyAddress).upgradeTo(address(boxV2));

        // 4. Interact with the proxy using the V2 ABI
        BoxV2 proxyBoxV2 = BoxV2(proxyAddress);

        // 5. Verify that the state is preserved
        assertEq(proxyBoxV2.retrieve(), 100, "State should be preserved after upgrade");

        // 6. Verify that the new V2 function works
        proxyBoxV2.increment();
        assertEq(proxyBoxV2.retrieve(), 101, "Increment function should work");
    }

    // TODO: This test also fails because the underlying revert happens before the `onlyOwner` check,
    // and it reverts without a reason string, causing `expectRevert` to fail.
    // The root cause is the same as in `test_UpgradeToV2`.
    function test_Fail_UpgradeFromNonOwner() public {
        boxV2 = new BoxV2();

        // Create a new user
        address nonOwner = vm.addr(1);
        vm.startPrank(nonOwner);

        // Attempt to upgrade from a non-owner account
        vm.expectRevert(abi.encodeWithSelector(bytes4(keccak256("OwnableUnauthorizedAccount(address)")), nonOwner));
        IUUPS(proxyAddress).upgradeTo(address(boxV2));
        vm.stopPrank();
    }
}
