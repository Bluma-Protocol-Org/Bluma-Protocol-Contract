// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {BlumaProtocol} from "../src/BlumaProtocol.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract DeployScript is Script {
    BlumaProtocol blumaProtocol;
    ERC1967Proxy proxy;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        // Deploy the implementation contract
        BlumaProtocol implementation = new BlumaProtocol();

        // Deploy the proxy and initialize the contract through the proxy
        proxy = new ERC1967Proxy(
            address(implementation),
            abi.encodeWithSelector(implementation.initialize.selector, msg.sender)
        );

        // Log the addresses of the proxy and the implementation contract
        console.log("Proxy Address:", address(proxy));
        console.log("Bluma Protocol Implementation Address:", address(implementation));

        vm.stopBroadcast();
    }
}
