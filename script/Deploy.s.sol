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

        BlumaProtocol implementation = new BlumaProtocol();
        // Deploy the proxy and initialize the contract through the proxy
        proxy = new ERC1967Proxy(
            address(implementation),
            abi.encodeCall(
                implementation.initialize,( msg.sender))
        );
        // Attach the MyToken interface to the deployed proxy
        console.log("Proxy Address", address(proxy));
        console.log("Bluma Protocol address", address(implementation));

        vm.stopBroadcast();
    }
}


// forge create --rpc-url https://rpctest.meter.io  --private-key ef257f59dc15ea8d0cfa7f5a177fb173b3125a3d79e6c13eb1e88831e40dc62c src/BlumaProtocol.sol:BlumaProtocol




